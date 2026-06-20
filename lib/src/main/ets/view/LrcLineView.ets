import { FrameNode, NodeController, RenderNode } from '@kit.ArkUI'
import { LrcLine } from '../bean/LrcLine'
import { common2D, drawing } from '@kit.ArkGraphics2D'
import { ColorHelper } from '../extensions/ColorHelper'
import { MediaLogger } from '../extensions/MediaLogger'
import { AlignMode } from '../bean/AlignMode'

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
        this.mode = mode
        this.lyricTextView?.setAlignMode(mode)
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
    private krcNormalPen: drawing.Brush = new drawing.Brush()
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
        red: 0,
        green: 0,
        blue: 0,
        alpha: 255
    }
    private textHighlightColor: number = 0xFFFF0000
    private lyricTextBlob?: drawing.TextBlob = undefined
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
        this.mode = mode
        this.updateConfig()
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
        this.krcNormalPen.setColor(this.textKrcBgColor)
        this.font.setSize(this.textSize)
        this.lyricTextBlob = drawing.TextBlob.makeFromString(this.lyricLine.text, this.font, drawing.TextEncoding.TEXT_ENCODING_UTF8)
        const bound = this.lyricTextBlob.bounds()
        this.textWidth = Math.max(0, bound.right - bound.left)
        this.textHeight = Math.max(0, bound.bottom - bound.top)
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

    private measureTextWidth(text: string): number {
        const blob = drawing.TextBlob.makeFromString(text, this.font, drawing.TextEncoding.TEXT_ENCODING_UTF8)
        const bound = blob.bounds()
        return Math.max(0, bound.right - bound.left)
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
        if (!this.isHighlight) {
            this.isHighlight = true
        }
        this.playPosition = position
        if (this.isKrc) {
            this.updateDrawingWidth(position)
        }
        this.invalidate()
    }

    stop() {
        this.playPosition = -1
        this.drawingWidth = 0
        this.isHighlight = false
        this.invalidate()
    }

    private updateDrawingWidth(position: number) {
        const wordList = this.lyricLine.wordList
        if (wordList === undefined || wordList.length <= 0) {
            this.drawingWidth = 0
            return
        }
        if (position <= wordList[0].beginTime) {
            this.drawingWidth = 0
            return
        }
        const lastWord = wordList[wordList.length - 1]
        if (position >= lastWord.endTime) {
            this.drawingWidth = this.textWidth
            return
        }
        let prefixText = ''
        let prefixWidth = 0
        for (let i = 0; i < wordList.length; i++) {
            const word = wordList[i]
            if (position < word.beginTime) {
                this.drawingWidth = prefixWidth
                return
            }
            const nextText = prefixText + word.text
            const nextWidth = i === wordList.length - 1 ? this.textWidth : this.measureTextWidth(nextText)
            if (position < word.endTime) {
                const duration = Math.max(1, word.endTime - word.beginTime)
                const progress = Math.min(1, Math.max(0, (position - word.beginTime) / duration))
                this.drawingWidth = prefixWidth + (nextWidth - prefixWidth) * progress
                return
            }
            prefixText = nextText
            prefixWidth = nextWidth
        }
        this.drawingWidth = this.textWidth
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
        this.drawKrcBackground(canvas);
        // draw foreground
        this.drawKrcForeground(canvas);
    }

    private drawKrcBackground(canvas: drawing.Canvas) {
        const pen = this.isHighlight ? this.krcNormalPen : this.normalPen
        canvas.attachBrush(pen)
        canvas.drawTextBlob(this.lyricTextBlob, this.beginX, this.beginY)
        canvas.detachBrush()
    }

    private drawKrcForeground(canvas: drawing.Canvas) {
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
