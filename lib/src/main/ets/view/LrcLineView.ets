import { AnimatorResult, FrameNode, NodeController, RenderNode } from '@kit.ArkUI'
import { LrcLine } from '../bean/LrcLine'
import { common2D, drawing } from '@kit.ArkGraphics2D'
import { ColorHelper } from '../extensions/ColorHelper'

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
    private textHighlightColor: number = -1

    public setTextSize(size: number) {
        this.textSize = size
        this.lyricTextView?.setTextSize(size)
    }

    public setTextColor(color: number) {
        this.textColor = color
        this.lyricTextView?.setTextColor(color)
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
        this.lyricTextView?.reset()
    }

    aboutToResize(size: Size): void {
        if (this.isEmptyLine) {
            // todo warning
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
            if (this.textHighlightColor !== -1) {
                this.setTextHighlightColor(this.textHighlightColor)
            }
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
    private textHighlightColor: number = 0xFFFF0000
    // "#ffff0000"
    private lyricTextBlob?: drawing.TextBlob = undefined
    private anim?: AnimatorResult = undefined
    private textWidth: number = 0
    private textHeight: number = 0
    private beginX = -1
    private beginY = -1
    private relativePosition = -1
    private totalDuration = 0
    private drawBeginWidth = 0
    private drawingWidth = 0
    private endPoint: common2D.Point = { x: 0, y: 0 }
    private isKrc = false
    private isHighlight = false

    constructor(uiContext: UIContext, lyricLine: LrcLine) {
        super()
        this.context = uiContext
        this.textSize = uiContext.vp2px(this.defaultTextSize)
        this.lyricLine = lyricLine
        this.isKrc = lyricLine.wordList != undefined && lyricLine.wordList.length > 0
        this.totalDuration = this.lyricLine.endTime - this.lyricLine.beginTime
        if (this.isKrc) {
            this.initAnimation()
        }
        this.updateConfig()
    }

    private initAnimation() {
        this.anim = this.context.createAnimator({
            duration: 250,
            delay: 0,
            easing: "linear",
            fill: 'forwards',
            direction: "normal",
            iterations: 1,
            begin: 0,
            end: 1
        })
        this.anim.onFrame = (progress) => {
            this.drawingWidth = progress
            this.invalidate()
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
        this.beginX = (this.context.vp2px(this.frame.width) - this.textWidth) / 2
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
        this.beginX = (this.context.vp2px(width) - this.textWidth) / 2
        this.beginY = this.context.vp2px(height) / 2 + this.textHeight / 2
        this.invalidate()
    }

    update(position: number) {
        if (this.isKrc) {
            this.relativePosition = position - this.lyricLine.beginTime
            this.updateAnimation()
        } else {
            if (this.isHighlight) {
                return
            }
            this.isHighlight = true
            this.invalidate()
        }
    }

    reset() {
        this.anim?.finish()
        this.relativePosition = -1
        this.drawBeginWidth = 0
        this.drawingWidth = 0
        this.isHighlight = false
        this.invalidate()
    }

    private updateAnimation() {
        const currentPercent = this.relativePosition / this.totalDuration
        const drawTargetWidth = this.textWidth * currentPercent
        this.anim!.reset({
            duration: 250,
            delay: 0,
            easing: "linear",
            fill: 'forwards',
            direction: "normal",
            iterations: 1,
            begin: this.drawBeginWidth,
            end: drawTargetWidth
        })
        this.anim!.play()
        this.drawBeginWidth = drawTargetWidth
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
        canvas.attachBrush(this.normalPen)
        canvas.drawTextBlob(this.lyricTextBlob, this.beginX, this.beginY)
        canvas.detachBrush()
    }

    private drawHighlight(canvas: drawing.Canvas) {
        if (this.relativePosition > 0) {
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