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
            console.warn('abc', '-------')
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
    private textSize: number = vp2px(16)
    private lineSpace: number = vp2px(16)
    private multiLineSpace: number = vp2px(10)
    private drawY: number = 0
    private scrollY: number = 0
    private centerY: number = 0
    private currentIndex: number = 0
    private emptyHint: string = ""
    private highlightScale: number = 1.15
    private normalFont: drawing.Font = new drawing.Font()
    private highlightFont: drawing.Font = new drawing.Font()
    private padding: number = vp2px(16)

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
            this.invalidate()
        } else {
            this.setEmpty()
        }
    }

    private reSize() {
        this.centerY = this.h / 2 - this.textSize / 2
        this.normalFont.setSize(this.textSize)
        this.highlightFont.setSize(this.textSize * this.highlightScale)
        if (this.lyric) {
            this.lyricMeasureResult = this.measureLines(this.lyric)
            this.invalidate()
        }
    }

    private setEmpty() {

    }

    private measureLines(lyric: Lyric): Map<number, LyricLineMeasureResult> {
        let lineHeight = this.textSize
        let measureResult = new Map<number, LyricLineMeasureResult>()
        let lyricList = lyric.lyricList
        for (let i = 0; i < lyricList.length; i++) {
            let lyricText = lyricList[i].text
            let lineWidth = this.normalFont.measureText(lyricText, drawing.TextEncoding.TEXT_ENCODING_UTF8)
            const measureItem = new LyricLineMeasureResult()
            let contentW = this.w - this.padding * 2
            if (lineWidth > contentW) { // multi lines
                let tempWidth = 0
                let tempText = ''
                let tempHeight = lineHeight
                let tempCount = 1
                for (let j = 0; j < lyricText.length; j++) {
                    let char = lyricText[j]
                    let charWidth = this.normalFont.measureText(char, drawing.TextEncoding.TEXT_ENCODING_UTF8)
                    if (tempWidth + charWidth > contentW) {
                        measureItem.preLineWidth.push(tempWidth)
                        measureItem.preLineText.push(tempText)
                        tempWidth = 0
                        tempText = ''
                        tempCount++
                        tempHeight = tempHeight + this.multiLineSpace + lineHeight
                    }
                    tempWidth += charWidth
                    tempText += char
                }
                measureItem.preLineWidth.push(tempWidth)
                measureItem.preLineText.push(tempText)
                measureItem.lineCount = tempCount
                measureItem.lineHeight = tempHeight
                measureResult.set(i, measureItem)
            } else { // single line
                measureItem.lineCount = 1
                measureItem.preLineWidth = [lineWidth]
                measureItem.lineHeight = lineHeight
                measureItem.preLineText = [lyricText]
                measureResult.set(i, measureItem)
            }
        }
        return measureResult
    }

    onTouch(event: TouchEvent): void {
    }

    draw(context: DrawContext): void {
        let canvas = context.canvas
        this.drawY = this.centerY + this.scrollY
        if (this.lyric) {
            let lyricLines = this.lyric.lyricList
            for (let i = 0; i < lyricLines.length; i++) {
                let lineText = lyricLines[i].text
                let measureResult = this.lyricMeasureResult.get(i)!
                let count = measureResult.lineCount
                if (count > 1) { //draw multi lines
                    let subLines = measureResult.preLineText
                    for (let j = 0; j < subLines.length; j++) {
                        let subLineText = subLines[j]
                        if (subLineText) {
                            if (this.currentIndex == i) {
                                canvas.attachBrush(this.highLightPaint)
                                this.normalFont.setSize(this.textSize * 1.2)
                            } else {
                                canvas.attachBrush(this.normalPaint)
                                this.normalFont.setSize(this.textSize)
                            }
                            let textBlob =
                                drawing.TextBlob.makeFromString(subLineText, this.normalFont, drawing.TextEncoding.TEXT_ENCODING_UTF8)
                            let drawX = (this.w - measureResult.preLineWidth[j]) / 2
                            canvas.drawTextBlob(textBlob, drawX, this.drawY)
                        }
                        if (j < subLines.length - 1) {
                            this.drawY += this.textSize + this.multiLineSpace
                        } else {
                            this.drawY += this.textSize + this.lineSpace
                        }
                    }
                } else { // draw single line
                    if (lineText) {
                        if (this.currentIndex == i) {
                            canvas.attachBrush(this.highLightPaint)
                            this.normalFont.setSize(this.textSize * 1.2)
                        } else {
                            canvas.attachBrush(this.normalPaint)
                            this.normalFont.setSize(this.textSize)
                        }
                        let textBlob = drawing.TextBlob.makeFromString(lineText, this.normalFont, drawing.TextEncoding.TEXT_ENCODING_UTF8)
                        let drawX = (this.w - measureResult.preLineWidth[0]) / 2
                        canvas.drawTextBlob(textBlob, drawX, this.drawY)
                    }
                    this.drawY += this.textSize + this.lineSpace
                }
            }
            canvas.detachBrush()
        }
    }

    private v() {
    }
}