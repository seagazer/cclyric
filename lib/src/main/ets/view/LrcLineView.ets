import { FrameNode, NodeController, RenderNode } from '@kit.ArkUI'
import { LrcLine } from '../bean/LrcLine'
import { common2D, drawing } from '@kit.ArkGraphics2D'
import { ColorHelper } from '../extensions/ColorHelper'
import { MediaLogger } from '../extensions/MediaLogger'
import { AlignMode } from '../bean/AlignMode'
import { Animator, AnimatorProvider } from './Animation'

const TAG = "[LrcLineView]"

/**
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export class LrcLineView extends NodeController {
    private context: UIContext | null = null
    private lyricLine: LrcLine
    private lyricTextView: LrcTextView | null = null
    private rootView: FrameNode | null = null
    private isEmptyLine = false
    private textSize: number = -1
    private textColor: number = -1
    private krcTextBgColor: number = -1
    private textHighlightColor: number = -1
    private mode: AlignMode = AlignMode.CENTER

    markHighlight() {
        this.lyricTextView?.markHighlight()
    }

    setAlignMode(mode: AlignMode) {
        this.lyricTextView?.setAlignMode(mode)
        this.mode = mode
    }

    public setTextSize(size: number) {
        this.textSize = size
        this.lyricTextView?.setTextSize(size)
    }

    public setTextColor(color: number) {
        this.textColor = color
        this.lyricTextView?.setTextColor(color)
    }

    public setKrcTextBgColor(color: number) {
        this.krcTextBgColor = color
        this.lyricTextView?.setKrcTextBgColor(color)
    }

    public setTextHighlightColor(color: number) {
        this.textHighlightColor = color
        this.lyricTextView?.setTextHighlightColor(color)
    }

    constructor(lyricLine: LrcLine) {
        super()
        this.lyricLine = lyricLine
        this.isEmptyLine = lyricLine.text === undefined || lyricLine.text.length <= 0
    }

    /**
     * Check the lyric text is empty or not.
     * @returns The lyric is empty or not.
     */
    isEmpty(): boolean {
        return this.isEmptyLine
    }

    /**
     * Return the lyric data of this view.
     * @returns The lyric data {@link LyricLine}.
     */
    getLyric(): LrcLine {
        return this.lyricLine
    }

    /**
     * Play the effect animation.
     * @param position The playing position of media player.
     */
    play(position: number) {
        this.lyricTextView?.update(position)
    }

    /**
     * Stop the effect animation.
     */
    stop() {
        this.lyricTextView?.stop()
    }

    aboutToResize(size: Size): void {
        if (this.isEmptyLine) {
            MediaLogger.w(TAG, "The lyric is null!")
            return
        }
        if (this.lyricTextView === null) {
            this.lyricTextView = new LrcTextView(this.context!, this.lyricLine)
            this.lyricTextView.onSizeChanged(size.width, size.height)
            if (this.textSize !== -1) {
                this.setTextSize(this.textSize)
            }
            if (this.textColor !== -1) {
                this.setTextColor(this.textColor)
            }
            if (this.krcTextBgColor !== -1) {
                this.setKrcTextBgColor(this.krcTextBgColor)
            }
            if (this.textHighlightColor !== -1) {
                this.setTextHighlightColor(this.textHighlightColor)
            }
            this.setAlignMode(this.mode)
            const renderNode = this.rootView?.getRenderNode()
            if (renderNode) {
                renderNode.appendChild(this.lyricTextView)
            }
        } else {
            this.lyricTextView.onSizeChanged(size.width, size.height)
        }
    }

    makeNode(uiContext: UIContext): FrameNode | null {
        if (this.rootView == null) {
            this.context = uiContext
            this.rootView = new FrameNode(uiContext)
        }
        return this.rootView
    }
}

class LrcTextView extends RenderNode {
    private context: UIContext
    private lyricLine: LrcLine
    private normalPen: drawing.Brush = new drawing.Brush()
    private highlightPen: drawing.Brush = new drawing.Brush()
    private font = new drawing.Font()
    private readonly defaultTextSize = 16 //vp
    private textSize: number = 0 //vp
    private textColor: common2D.Color = {
        red: 0,
        green: 0,
        blue: 0,
        alpha: 255
    }
    private textKrcBgColor: common2D.Color = {
        red: 90,
        green: 90,
        blue: 90,
        alpha: 255
    }
    private textHighlightColor: number = 0xFFFF0000
    private lyricTextBlob?: drawing.TextBlob = undefined
    private anim?: Animator = undefined
    private textWidth: number = 0
    private textHeight: number = 0
    private beginX = -1
    private beginY = -1
    private playPosition = -1
    private drawingWidth = 0
    private endPoint: common2D.Point = { x: 0, y: 0 }
    private isKrc = false
    private isHighlight = false
    private mode: AlignMode = AlignMode.CENTER
    private animDuration = 250
    private lastWordPosition = 0

    constructor(uiContext: UIContext, lyricLine: LrcLine) {
        super()
        this.context = uiContext
        this.textSize = uiContext.vp2px(this.defaultTextSize)
        this.lyricLine = lyricLine
        this.isKrc = lyricLine.wordList != undefined && lyricLine.wordList.length > 0
        this.updateConfig()
    }

    markHighlight() {
        this.isHighlight = true
        this.invalidate()
    }

    setAlignMode(mode: AlignMode) {
        if (this.mode !== mode) {
            this.mode = mode
            this.updateConfig()
        }
    }

    setTextSize(size: number) {
        this.textSize = this.context.vp2px(size)
        this.updateConfig()
    }

    setTextColor(textColor: number) {
        const colors = ColorHelper.hex2Argb(textColor) //argb
        this.textColor = {
            red: colors[1],
            green: colors[2],
            blue: colors[3],
            alpha: colors[0]
        }
        this.updateConfig()
    }

    setKrcTextBgColor(textColor: number) {
        const colors = ColorHelper.hex2Argb(textColor) //argb
        this.textKrcBgColor = {
            red: colors[1],
            green: colors[2],
            blue: colors[3],
            alpha: colors[0]
        }
        this.updateConfig()
    }

    setTextHighlightColor(textColor: number) {
        this.textHighlightColor = textColor
        this.updateConfig()
    }

    private updateConfig() {
        this.normalPen.setColor(this.textColor)
        this.font.setSize(this.textSize)
        this.lyricTextBlob = drawing.TextBlob.makeFromString(this.lyricLine.text, this.font, drawing.TextEncoding.TEXT_ENCODING_UTF8)
        const bound = this.lyricTextBlob.bounds()
        this.textWidth = bound.right - bound.left
        this.textHeight = bound.bottom - bound.top
        this.beginX = this.mode === AlignMode.CENTER ? (this.context.vp2px(this.frame.width) - this.textWidth) / 2 : 0
        this.beginY = this.context.vp2px(this.frame.height / 2) + this.textHeight / 2
        if (!this.isKrc) {
            const argb = ColorHelper.hex2Argb(this.textHighlightColor)
            this.highlightPen.setColor({
                alpha: argb[0],
                red: argb[1],
                green: argb[2],
                blue: argb[3]
            })
        }
        this.invalidate()
    }

    onSizeChanged(width: number, height: number) {
        if (this.frame.width === width && this.frame.height === height) {
            return
        }
        this.frame = {
            x: 0,
            y: 0,
            width: width,
            height: height
        }
        this.beginX = this.mode === AlignMode.CENTER ? (this.context.vp2px(this.frame.width) - this.textWidth) / 2 : 0
        this.beginY = this.context.vp2px(height) / 2 + this.textHeight / 2
        this.invalidate()
    }

    update(position: number) {
        this.isHighlight = true
        if (this.isKrc) {
            this.playPosition = position
            this.updateAnimation()
        } else {
            if (this.isHighlight) {
                return
            }
            this.invalidate()
        }
    }

    stop() {
        this.anim?.stop()
        this.anim = undefined
        this.playPosition = -1
        this.drawingWidth = 0
        this.isHighlight = false
        this.invalidate()
    }

    private animCallback = (progress: number) => {
        this.drawingWidth = progress
        this.invalidate()
    }

    private updateAnimation() {
        const wordList = this.lyricLine.wordList!
        let duration = this.animDuration
        let targetText = ""
        if (wordList.length === 1) { // single word line
            if (this.anim !== undefined) {
                MediaLogger.w(TAG, "single word line anim is running, not changed!")
                return
            }
            const word = wordList[0]
            targetText = word.text
            duration = word.endTime - word.beginTime
            if (this.anim === undefined) { //创建动画实例
                const animator = AnimatorProvider.getInstance(this.context)
                animator.setAnimationDuration(duration)
                this.anim = animator.getAnimator()
                this.anim.reset({
                    duration: duration,
                    delay: 0,
                    easing: "linear",
                    fill: 'forwards',
                    direction: "normal",
                    iterations: 1,
                    begin: 0,
                    end: this.textWidth
                })
                this.anim.addCallback(this.animCallback)
                this.anim.run()
            }
        } else { // multi words line
            let currentWordPosition = -1
            for (let i = 0; i < wordList.length; i++) {
                const word = wordList[i]
                targetText += word.text
                if (this.playPosition > word.beginTime && this.playPosition < word.endTime) {
                    if (i === this.lastWordPosition) {
                        MediaLogger.d(TAG, "word position is not changed")
                        break
                    }
                    currentWordPosition = i
                    this.lastWordPosition = i
                    duration = word.endTime - word.beginTime
                    break
                }
            }
            if (currentWordPosition < 0) { //目标word未改变，继续执行当前动画即可，无需更新
                MediaLogger.i(TAG, "word position is not changed, keep current animation")
                return
            }
            let drawTargetWidth = 0
            if (currentWordPosition === wordList.length - 1) { //最后一行，动画目标为文本view的宽度，即动画结束完全显示
                drawTargetWidth = this.textWidth
            } else { //非最后一行，动画目标为当前文本所占的宽度，即显示当前占比
                const lyricTextBlob = drawing.TextBlob.makeFromString(targetText, this.font, drawing.TextEncoding.TEXT_ENCODING_UTF8)
                const bound = lyricTextBlob.bounds()
                drawTargetWidth = bound.right - bound.left //目标占比宽度
            }
            if (this.anim === undefined) { //创建动画实例
                const animator = AnimatorProvider.getInstance(this.context)
                animator.setAnimationDuration(duration)
                this.anim = animator.getAnimator()
                this.anim.addCallback(this.animCallback)
            }
            this.anim.pause()
            this.anim.reset({
                duration: duration,
                delay: 0,
                easing: "linear",
                fill: 'forwards',
                direction: "normal",
                iterations: 1,
                begin: this.drawingWidth,
                end: drawTargetWidth
            })
            this.anim.addCallback(this.animCallback)
            this.anim.run()
        }
    }

    draw(context: DrawContext): void {
        const canvas = context.canvas
        if (this.isKrc) {
            this.drawKrc(canvas);
        } else {
            this.drawLrc(canvas)
        }
    }

    private drawLrc(canvas: drawing.Canvas) {
        const paint = this.isHighlight ? this.highlightPen : this.normalPen
        canvas.attachBrush(paint)
        canvas.drawTextBlob(this.lyricTextBlob, this.beginX, this.beginY)
        canvas.detachBrush()
    }

    private drawKrc(canvas: drawing.Canvas) {
        // draw background
        this.drawNormal(canvas);
        // draw foreground
        this.drawHighlight(canvas);
    }

    private drawNormal(canvas: drawing.Canvas) {
        if (this.isHighlight) {
            this.normalPen.setColor(this.textKrcBgColor)
        } else {
            this.normalPen.setColor(this.textColor)
        }
        canvas.attachBrush(this.normalPen)
        canvas.drawTextBlob(this.lyricTextBlob, this.beginX, this.beginY)
        canvas.detachBrush()
    }

    private drawHighlight(canvas: drawing.Canvas) {
        if (this.playPosition > 0) {
            this.endPoint.x = this.drawingWidth + this.beginX
            const shaderEffect = drawing.ShaderEffect.createLinearGradient({ x: 0, y: 0 }, this.endPoint,
                [this.textHighlightColor, this.textHighlightColor], drawing.TileMode.DECAL)
            this.highlightPen.setShaderEffect(shaderEffect)
            canvas.attachBrush(this.highlightPen)
            canvas.drawTextBlob(this.lyricTextBlob, this.beginX, this.beginY)
            canvas.detachBrush()
        }
    }
}