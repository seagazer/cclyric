import { LrcLine } from '../bean/LrcLine'
import drawing from '@ohos.graphics.drawing'
import { AlignMode } from '../bean/AlignMode'
import common2D from '@ohos.graphics.common2D'
import { ColorHelper } from '../extensions/ColorHelper'
import { MediaLogger } from '../extensions/MediaLogger'
import { FrameNode, NodeController, RenderNode } from '@ohos.arkui.node'

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
    private typeface: drawing.Typeface | null = null
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

    public setTypeface(typeface: drawing.Typeface | null) {
        this.typeface = typeface
        this.lyricTextView?.setTypeface(typeface)
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
     * Return the line count of the lyric text (split by newline).
     * @returns The line count of this lyric.
     */
    getLineCount(): number {
        if (this.isEmptyLine) {
            return 0
        }
        return this.lyricLine.text.split('\n').length
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
            // 一次性批量应用所有配置，仅触发一次文本测量
            this.lyricTextView.applyConfig(
                this.textSize !== -1 ? this.textSize : LrcTextView.DEFAULT_TEXT_SIZE,
                this.textColor !== -1 ? this.textColor : 0xFF000000,
                this.krcTextBgColor !== -1 ? this.krcTextBgColor : 0xFF000000,
                this.textHighlightColor !== -1 ? this.textHighlightColor : 0xFFFF0000,
                this.typeface,
                this.mode
            )
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
    private readonly defaultTypeface = this.font.getTypeface()
    static readonly DEFAULT_TEXT_SIZE: number = 16 //vp
    private textSize: number = 0 //px
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
    private lyricTextBlobs: drawing.TextBlob[] = []
    private lineWidths: number[] = []
    private lineHeights: number[] = []
    private textWidth: number = 0
    private textHeight: number = 0
    private lineHeight: number = 0
    private beginY = -1
    private drawingWidth = 0
    private wordPrefixWidths: number[] = []
    private isWordMetricsDirty = true
    private cachedShader: drawing.ShaderEffect | null = null
    private cachedShaderEndX = -1
    private cachedShaderColor = -1
    private readonly shaderUpdateThreshold = 1
    private isKrc = false
    private isHighlight = false
    private mode: AlignMode = AlignMode.CENTER

    constructor(uiContext: UIContext, lyricLine: LrcLine) {
        super()
        this.context = uiContext
        this.lyricLine = lyricLine
        this.isKrc = lyricLine.wordList != undefined && lyricLine.wordList.length > 0
        // 用默认值完成一次完整初始化，实际配置由 applyConfig 一次性覆盖
        this.applyConfig(LrcTextView.DEFAULT_TEXT_SIZE, 0xFF000000, 0xFF000000, 0xFFFF0000, null, AlignMode.CENTER)
    }

    markHighlight() {
        this.isHighlight = true
        this.invalidate()
    }

    setAlignMode(mode: AlignMode) {
        if (this.mode === mode) {
            return
        }
        this.mode = mode
        // 对齐模式只在绘制时影响起点，无需重新测量文本
        this.invalidate()
    }

    setTextSize(size: number) {
        const newSize = this.context.vp2px(size)
        if (this.textSize === newSize) {
            return
        }
        this.textSize = newSize
        this.isWordMetricsDirty = true
        this.applyTextMetrics()
    }

    setTextColor(textColor: number) {
        const colors = ColorHelper.hex2Argb(textColor) //argb
        const newColor: common2D.Color = {
            red: colors[1],
            green: colors[2],
            blue: colors[3],
            alpha: colors[0]
        }
        if (this.textColor.red === newColor.red && this.textColor.green === newColor.green &&
            this.textColor.blue === newColor.blue && this.textColor.alpha === newColor.alpha) {
            return
        }
        this.textColor = newColor
        this.normalPen.setColor(this.textColor)
        this.invalidate()
    }

    setKrcTextBgColor(textColor: number) {
        const colors = ColorHelper.hex2Argb(textColor) //argb
        const newColor: common2D.Color = {
            red: colors[1],
            green: colors[2],
            blue: colors[3],
            alpha: colors[0]
        }
        if (this.textKrcBgColor.red === newColor.red && this.textKrcBgColor.green === newColor.green &&
            this.textKrcBgColor.blue === newColor.blue && this.textKrcBgColor.alpha === newColor.alpha) {
            return
        }
        this.textKrcBgColor = newColor
        this.krcNormalPen.setColor(this.textKrcBgColor)
        this.invalidate()
    }

    setTextHighlightColor(textColor: number) {
        if (this.textHighlightColor === textColor) {
            return
        }
        this.textHighlightColor = textColor
        this.applyHighlightColor()
        this.invalidate()
    }

    setTypeface(typeface: drawing.Typeface | null) {
        const target = typeface ?? this.defaultTypeface
        if (this.font.getTypeface() === target) {
            return
        }
        this.font.setTypeface(target)
        this.isWordMetricsDirty = true
        this.applyTextMetrics()
    }

    /**
     * Apply the whole set of rendering attributes at once and perform a single
     * text measurement. Used at view creation to avoid the repeated native
     * measurement caused by calling each setter individually.
     * @param textSize The text size, the unit is vp.
     */
    applyConfig(textSize: number, textColor: number, krcTextBgColor: number,
        textHighlightColor: number, typeface: drawing.Typeface | null, mode: AlignMode) {
        this.textSize = this.context.vp2px(textSize)
        this.mode = mode
        this.isWordMetricsDirty = true
        const colors = ColorHelper.hex2Argb(textColor)
        this.textColor = {
            red: colors[1],
            green: colors[2],
            blue: colors[3],
            alpha: colors[0]
        }
        this.normalPen.setColor(this.textColor)
        const krcColors = ColorHelper.hex2Argb(krcTextBgColor)
        this.textKrcBgColor = {
            red: krcColors[1],
            green: krcColors[2],
            blue: krcColors[3],
            alpha: krcColors[0]
        }
        this.krcNormalPen.setColor(this.textKrcBgColor)
        this.textHighlightColor = textHighlightColor
        this.font.setTypeface(typeface ?? this.defaultTypeface)
        this.applyHighlightColor()
        this.applyTextMetrics()
    }

    /**
     * Re-measure the lyric text and rebuild the render resources that depend on
     * the text metrics. Only needed when the text size or the typeface changes.
     */
    private applyTextMetrics() {
        this.font.setSize(this.textSize)
        const lines = this.lyricLine.text.split('\n')
        this.lyricTextBlobs = []
        this.lineWidths = []
        this.lineHeights = []
        this.textWidth = 0
        this.textHeight = 0
        for (let i = 0; i < lines.length; i++) {
            const blob = drawing.TextBlob.makeFromString(lines[i], this.font, drawing.TextEncoding.TEXT_ENCODING_UTF8)
            const bound = blob.bounds()
            const width = Math.max(0, bound.right - bound.left)
            const height = Math.max(0, bound.bottom - bound.top)
            this.lyricTextBlobs.push(blob)
            this.lineWidths.push(width)
            this.lineHeights.push(height)
            this.textWidth = Math.max(this.textWidth, width)
            this.textHeight += height
        }
        this.lineHeight = 0
        for (let i = 0; i < this.lineHeights.length; i++) {
            this.lineHeight = Math.max(this.lineHeight, this.lineHeights[i])
        }
        if (this.lineHeight <= 0) {
            this.lineHeight = this.textSize
        }
        this.textHeight = 0
        for (let i = 0; i < this.lineHeights.length; i++) {
            if (this.lineHeights[i] <= 0) {
                this.lineHeights[i] = this.lineHeight
            }
            this.textHeight += this.lineHeights[i]
        }
        if (this.isWordMetricsDirty) {
            this.wordPrefixWidths = this.buildWordPrefixWidths()
            this.isWordMetricsDirty = false
        }
        this.updateLayout()
        this.invalidate()
    }

    /**
     * Refresh the highlight color resources. For krc lines the sweep shader is
     * invalidated; for lrc lines the highlight pen color is updated.
     */
    private applyHighlightColor() {
        if (this.isKrc) {
            this.cachedShader = null
        } else {
            const argb = ColorHelper.hex2Argb(this.textHighlightColor)
            this.highlightPen.setColor({
                alpha: argb[0],
                red: argb[1],
                green: argb[2],
                blue: argb[3]
            })
        }
    }

    private updateLayout() {
        const frameHeight = this.context.vp2px(this.frame.height)
        const totalHeight = this.textHeight
        const startY = frameHeight / 2 - totalHeight / 2 + this.lineHeight / 2
        this.beginY = Math.max(this.lineHeight / 2, startY)
        this.invalidate()
    }

    private measureTextWidth(text: string): number {
        const blob = drawing.TextBlob.makeFromString(text, this.font, drawing.TextEncoding.TEXT_ENCODING_UTF8)
        const bound = blob.bounds()
        return Math.max(0, bound.right - bound.left)
    }

    /**
     * Precompute the cumulative text width for each krc word.
     * The per-frame sweep then only reads this array instead of re-measuring
     * text with native calls. The last word is aligned with {@link textWidth},
     * matching the historical sweep behavior.
     */
    private buildWordPrefixWidths(): number[] {
        const widths: number[] = []
        if (!this.isKrc) {
            return widths
        }
        const wordList = this.lyricLine.wordList
        if (wordList === undefined || wordList.length <= 0) {
            return widths
        }
        let prefixText = ''
        for (let i = 0; i < wordList.length; i++) {
            prefixText += wordList[i].text
            const width = i === wordList.length - 1 ? this.textWidth : this.measureTextWidth(prefixText)
            widths.push(width)
        }
        return widths
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
        this.updateLayout()
    }

    update(position: number) {
        if (this.isKrc) {
            const previousWidth = this.drawingWidth
            this.updateDrawingWidth(position)
            if (!this.isHighlight) {
                this.isHighlight = true
                this.invalidate()
            } else if (this.drawingWidth !== previousWidth) {
                this.invalidate()
            }
            return
        }
        // An lrc line renders a static whole-line highlight; a redraw is only
        // needed when the highlighted state changes.
        if (!this.isHighlight) {
            this.isHighlight = true
            this.invalidate()
        }
    }

    stop() {
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
        const prefixWidths = this.wordPrefixWidths
        let prefixWidth = 0
        for (let i = 0; i < wordList.length; i++) {
            const word = wordList[i]
            if (position < word.beginTime) {
                this.drawingWidth = prefixWidth
                return
            }
            const nextWidth = prefixWidths[i]
            if (position < word.endTime) {
                const duration = Math.max(1, word.endTime - word.beginTime)
                const progress = Math.min(1, Math.max(0, (position - word.beginTime) / duration))
                this.drawingWidth = prefixWidth + (nextWidth - prefixWidth) * progress
                return
            }
            prefixWidth = nextWidth
        }
        this.drawingWidth = this.textWidth
    }

    private getLineBeginX(lineWidth: number): number {
        return this.mode === AlignMode.CENTER ? (this.context.vp2px(this.frame.width) - lineWidth) / 2 : 0
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
        let y = this.beginY
        for (let i = 0; i < this.lyricTextBlobs.length; i++) {
            const blob = this.lyricTextBlobs[i]
            if (blob !== undefined && this.lineHeights[i] > 0) {
                canvas.drawTextBlob(blob, this.getLineBeginX(this.lineWidths[i]), y)
            }
            y += this.lineHeights[i]
        }
        canvas.detachBrush()
    }

    private drawKrc(canvas: drawing.Canvas) {
        if (this.textWidth > 0 && this.drawingWidth >= this.textWidth) {
            // Fully highlighted: the foreground sweep already covers the whole
            // text, so the background layer would be completely hidden.
            this.drawKrcForeground(canvas)
            return
        }
        // draw background
        this.drawKrcBackground(canvas)
        // draw foreground
        this.drawKrcForeground(canvas)
    }

    private drawKrcBackground(canvas: drawing.Canvas) {
        const pen = this.isHighlight ? this.krcNormalPen : this.normalPen
        canvas.attachBrush(pen)
        let y = this.beginY
        for (let i = 0; i < this.lyricTextBlobs.length; i++) {
            const blob = this.lyricTextBlobs[i]
            if (blob !== undefined && this.lineHeights[i] > 0) {
                canvas.drawTextBlob(blob, this.getLineBeginX(this.lineWidths[i]), y)
            }
            y += this.lineHeights[i]
        }
        canvas.detachBrush()
    }

    private drawKrcForeground(canvas: drawing.Canvas) {
        if (this.drawingWidth <= 0) {
            return
        }
        const endX = this.drawingWidth + this.getLineBeginX(this.textWidth)
        let shader = this.cachedShader
        if (shader === null ||
            this.cachedShaderColor !== this.textHighlightColor ||
            Math.abs(this.cachedShaderEndX - endX) >= this.shaderUpdateThreshold) {
            shader = drawing.ShaderEffect.createLinearGradient({ x: 0, y: 0 }, { x: endX, y: 0 },
                [this.textHighlightColor, this.textHighlightColor], drawing.TileMode.DECAL)
            this.cachedShader = shader
            this.cachedShaderEndX = endX
            this.cachedShaderColor = this.textHighlightColor
        }
        this.highlightPen.setShaderEffect(shader)
        canvas.attachBrush(this.highlightPen)
        let y = this.beginY
        for (let i = 0; i < this.lyricTextBlobs.length; i++) {
            const blob = this.lyricTextBlobs[i]
            if (blob !== undefined && this.lineHeights[i] > 0) {
                canvas.drawTextBlob(blob, this.getLineBeginX(this.lineWidths[i]), y)
            }
            y += this.lineHeights[i]
        }
        canvas.detachBrush()
    }
}
