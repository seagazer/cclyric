import { DrawContext, FrameNode, NodeController, RenderNode, UIContext } from '@kit.ArkUI';
import { drawing } from '@kit.ArkGraphics2D';
import { Lyric } from '../bean/Lyric';
import { LyricLineMeasureResult } from '../bean/LyricLineMeasureResult';

/**
 * A component to display the lyric for music player.
 *
 * Author: Seagazer
 * Date: 2024/12/17
 */

export class CcLyricView extends NodeController {
    private lyricView = new LyricNode()

    makeNode(uiContext: UIContext): FrameNode | null {
        let rootView = new FrameNode(uiContext)
        let renderRoot = rootView.getRenderNode()
        if (renderRoot) {
            renderRoot.appendChild(this.lyricView)
        }
        return rootView
    }

    aboutToAppear(): void {
        this.lyricView.onCreate()
    }

    aboutToDisappear(): void {
        this.lyricView.onDestroy()
    }

    aboutToResize(size: Size): void {
        this.lyricView.onSizeChanged(size)
        console.warn('abc', '-------' + JSON.stringify(this.lyricView.frame))
    }

    onTouchEvent(event: TouchEvent): void {
        this.lyricView.onTouch(event)
    }

    setLyric(lyric?: Lyric): void {
        this.lyricView.setLyric(lyric)
    }
}


class LyricNode extends RenderNode {
    private lyric?: Lyric = undefined
    private lyricMeasureResult: Map<number, LyricLineMeasureResult> = new Map()
    private w: number = 0
    private h: number = 0
    private highLightPaint: drawing.Brush = new drawing.Brush()
    private normalPaint: drawing.Brush = new drawing.Brush()
    private textSize: number = vp2px(24)
    private lineSpace: number = vp2px(24)
    private multiLineSpace: number = vp2px(16)
    private startY: number = 0
    private scrollY: number = 0
    private centerY: number = 0
    private currentIndex: number = 4
    private emptyHint: string = ""
    private highlightScale: number = 1.2
    private normalFont: drawing.Font = new drawing.Font()
    private highlightFont: drawing.Font = new drawing.Font()
    private padding: number = vp2px(16)
    private downY: number = 0

    onCreate(): void {
        this.highLightPaint.setColor({
            red: 0,
            green: 0,
            blue: 0,
            alpha: 255
        })
        this.normalPaint.setColor({
            red: 125,
            green: 125,
            blue: 125,
            alpha: 200
        })
    }

    onDestroy(): void {
    }

    onSizeChanged(size: Size): void {
        this.frame = {
            x: 0,
            y: 0,
            width: size.width,
            height: size.height
        }
        this.w = vp2px(size.width)
        this.h = vp2px(size.height)
        this.reSize()
    }

    setHighlightScale(scale: number) {
        this.highlightScale = scale
        this.reSize()
    }

    setFontSize(size: number): void {
        this.textSize = vp2px(size)
        this.normalFont.setSize(this.textSize)
        this.reSize()
    }

    setEmptyHint(hint: string): void {
        this.emptyHint = hint
    }

    setLyric(lyric?: Lyric): void {
        if (this.lyric == lyric) {
            return
        }
        this.lyric = lyric
        if (lyric) {
            this.lyricMeasureResult.clear()
            this.lyricMeasureResult = this.measureLines(lyric)
            this.lyricMeasureResult.forEach((v) => {
                console.debug('abc', '---' + JSON.stringify(v))
            })
        } else {
            this.setEmpty()
        }
        this.invalidate()
    }

    private reSize(): void {
        this.centerY = this.h / 2 - this.textSize / 2
        this.normalFont.setSize(this.textSize)
        this.highlightFont.setSize(this.textSize * this.highlightScale)
        if (this.lyric) {
            this.lyricMeasureResult.clear()
            this.lyricMeasureResult = this.measureLines(this.lyric)
            this.invalidate()
        }
    }

    private setEmpty(): void {

    }

    private measureLines(lyric: Lyric): Map<number, LyricLineMeasureResult> {
        const lineHeight = this.textSize
        const measureResult = new Map<number, LyricLineMeasureResult>()
        const lyricList = lyric.lyricList
        for (let i = 0; i < lyricList.length; i++) {
            const lyricText = lyricList[i].text
            const measureItem = new LyricLineMeasureResult()
            let contentW = this.w - this.padding * 2
            // normal style
            this.measureByFont(measureItem, false, lyricText, contentW, lineHeight)
            // highlight style
            this.measureByFont(measureItem, true, lyricText, contentW, lineHeight * this.highlightScale)
            measureResult.set(i, measureItem)
        }
        return measureResult
    }

    private measureByFont(measureItem: LyricLineMeasureResult, isHighlight: boolean, lyricText: string, contentW: number, lineHeight: number): void {
        const font = isHighlight ? this.highlightFont : this.normalFont
        const lineWidth = font.measureText(lyricText, drawing.TextEncoding.TEXT_ENCODING_UTF8)
        if (lineWidth > contentW) { // multi lines
            let tempWidth = 0
            let tempText = ''
            let tempHeight = lineHeight
            let tempCount = 1
            for (let j = 0; j < lyricText.length; j++) {
                let char = lyricText[j]
                let charWidth = font.measureText(char, drawing.TextEncoding.TEXT_ENCODING_UTF8)
                if (tempWidth + charWidth > contentW) {
                    if (isHighlight) {
                        measureItem.preLineWidthHL.push(tempWidth)
                        measureItem.preLineTextHL.push(tempText)
                    } else {
                        measureItem.preLineWidth.push(tempWidth)
                        measureItem.preLineText.push(tempText)
                    }
                    tempWidth = 0
                    tempText = ''
                    tempCount++
                    tempHeight = tempHeight + this.multiLineSpace + lineHeight
                }
                tempWidth += charWidth
                tempText += char
            }
            if (isHighlight) {
                measureItem.preLineWidthHL.push(tempWidth)
                measureItem.preLineTextHL.push(tempText)
                measureItem.lineCountHL = tempCount
                measureItem.lineHeightHL = tempHeight
            } else {
                measureItem.preLineWidth.push(tempWidth)
                measureItem.preLineText.push(tempText)
                measureItem.lineCount = tempCount
                measureItem.lineHeight = tempHeight
            }
        } else { // single line
            if (isHighlight) {
                measureItem.lineCountHL = 1
                measureItem.preLineWidthHL = [lineWidth]
                measureItem.lineHeightHL = lineHeight
                measureItem.preLineTextHL = [lyricText]
            } else {
                measureItem.lineCount = 1
                measureItem.preLineWidth = [lineWidth]
                measureItem.lineHeight = lineHeight
                measureItem.preLineText = [lyricText]
            }
        }
    }

    onTouch(event: TouchEvent): void {
        const ev = event.touches[0]
        switch (ev.type) {
            case TouchType.Down:
                this.downY = ev.y
                break
            case TouchType.Move:
                let curY = ev.y
                let dy = curY - this.downY
                this.scrollY += vp2px(dy)
                this.downY = curY
                break
            case TouchType.Up:
                this.downY = 0
                break
        }
        this.invalidate()
    }

    draw(context: DrawContext): void {
        const canvas = context.canvas
        this.startY = this.centerY + this.scrollY
        if (this.lyric) {
            const lyricLines = this.lyric.lyricList
            for (let i = 0; i < lyricLines.length; i++) {
                const measureResult = this.lyricMeasureResult.get(i)!
                if (this.currentIndex == i) {
                    this.drawHighlight(canvas, measureResult)
                } else {
                    this.drawNormal(canvas, measureResult)
                }
            }
            canvas.detachBrush()
        }
    }

    private isDrawOnScreen(): boolean {
        return this.startY > -this.textSize && this.startY < this.h + this.textSize
    }

    private drawHighlight(canvas: drawing.Canvas, measureResult: LyricLineMeasureResult): void {
        canvas.attachBrush(this.highLightPaint)
        const count = measureResult.lineCountHL
        const subLines = measureResult.preLineTextHL
        if (count > 1) { //draw multi lines
            for (let i = 0; i < subLines.length; i++) {
                if (this.isDrawOnScreen()) {
                    const subLineText = subLines[i]
                    if (subLineText) {
                        const textBlob = drawing.TextBlob.makeFromString(subLineText, this.highlightFont, drawing.TextEncoding.TEXT_ENCODING_UTF8)
                        let drawX = (this.w - measureResult.preLineWidthHL[i]) / 2
                        canvas.drawTextBlob(textBlob, drawX, this.startY)
                    }
                }
                if (i < subLines.length - 1) {
                    this.startY += this.textSize + this.multiLineSpace
                } else {
                    this.startY += this.textSize + this.lineSpace
                }
            }
        } else { // draw single line
            if (this.isDrawOnScreen()) {
                const lineText = subLines[0]
                if (lineText) {
                    let textBlob = drawing.TextBlob.makeFromString(lineText, this.highlightFont, drawing.TextEncoding.TEXT_ENCODING_UTF8)
                    let drawX = (this.w - measureResult.preLineWidthHL[0]) / 2
                    canvas.drawTextBlob(textBlob, drawX, this.startY)
                }
            }
            this.startY += this.textSize + this.lineSpace
        }
    }

    private drawNormal(canvas: drawing.Canvas, measureResult: LyricLineMeasureResult): void {
        canvas.attachBrush(this.normalPaint)
        const count = measureResult.lineCount
        const subLines = measureResult.preLineText
        if (count > 1) { //draw multi lines
            for (let j = 0; j < subLines.length; j++) {
                if (this.isDrawOnScreen()) {
                    const subLineText = subLines[j]
                    if (subLineText) {
                        const textBlob = drawing.TextBlob.makeFromString(subLineText, this.normalFont, drawing.TextEncoding.TEXT_ENCODING_UTF8)
                        let drawX = (this.w - measureResult.preLineWidth[j]) / 2
                        canvas.drawTextBlob(textBlob, drawX, this.startY)
                    }
                }
                if (j < subLines.length - 1) {
                    this.startY += this.textSize + this.multiLineSpace
                } else {
                    this.startY += this.textSize + this.lineSpace
                }
            }
        } else { // draw single line
            if (this.isDrawOnScreen()) {
                const lineText = subLines[0]
                if (lineText) {
                    let textBlob = drawing.TextBlob.makeFromString(lineText, this.normalFont, drawing.TextEncoding.TEXT_ENCODING_UTF8)
                    let drawX = (this.w - measureResult.preLineWidth[0]) / 2
                    canvas.drawTextBlob(textBlob, drawX, this.startY)
                }
            }
            this.startY += this.textSize + this.lineSpace
        }
    }
}