import text from '@ohos.graphics.text'
import drawing from '@ohos.graphics.drawing'
import { LrcLine } from '../bean/LrcLine'
import { LrcWord } from '../bean/LrcWord'
import { LyricDisplayLine } from '../bean/LyricDisplayLine'

/**
 * Author: Seagazer
 * Date: 2026/6/17
 */
export class LyricLayoutService {
    private readonly fontCollection = new text.FontCollection()
    private readonly wrapFont = new drawing.Font()
    private readonly defaultTypeface = this.wrapFont.getTypeface()
    private typeface: drawing.Typeface | null = null
    private readonly paragraphCache: Map<string, string[]> = new Map()
    // Punctuation that should not start a wrapped line (avoid orphan punctuation for CJK text).
    private readonly noStartPunctuation = '，。、；：！？…—～」』】》）”’,.;:!?)]}'

    /**
     * Set the typeface used to measure and wrap the lyric text.
     * The typeface must be identical to the one used for rendering, otherwise lines wrapped
     * with the default font metrics can overflow the viewport after the highlight scale is applied.
     * @param typeface The typeface, null to use the default font.
     */
    setTypeface(typeface: drawing.Typeface | null) {
        if (this.typeface === typeface) {
            return
        }
        this.typeface = typeface
        this.paragraphCache.clear()
    }

    measureLines(line: LrcLine, width: number, fontSize: number): string[] {
        if (width <= 0 || fontSize <= 0 || line.text.length <= 0) {
            return [line.text]
        }
        const cacheKey = this.buildCacheKey(line.text, width, fontSize)
        const cached = this.paragraphCache.get(cacheKey)
        if (cached !== undefined) {
            return cached
        }
        // A custom typeface must drive the wrapping, otherwise the wrapped lines are measured
        // with the default font and can be wider than the viewport once rendered with the
        // custom typeface and scaled by the highlight scale.
        const result = this.typeface === null
            ? this.measureLinesByParagraph(line.text, width, fontSize)
            : this.measureLinesByDrawing(line.text, width, fontSize)
        this.paragraphCache.set(cacheKey, result)
        return result
    }

    private measureLinesByParagraph(textValue: string, width: number, fontSize: number): string[] {
        const style: text.ParagraphStyle = {
            wordBreak: text.WordBreak.NORMAL,
            textStyle: {
                fontSize: fontSize
            }
        }
        const builder = new text.ParagraphBuilder(style, this.fontCollection)
        builder.addText(textValue)
        const paragraph = builder.build()
        paragraph.layoutSync(width)
        const result: string[] = []
        const lineCount = paragraph.getLineCount()
        for (let i = 0; i < lineCount; i++) {
            const metrics = paragraph.getLineMetrics(i)
            if (metrics !== undefined) {
                result.push(textValue.substring(metrics.startIndex, metrics.endIndex))
            }
        }
        return result.length > 0 ? result : [textValue]
    }

    /**
     * Greedy wrapping based on the same drawing.Font metrics as LrcTextView rendering,
     * so the measured width always matches the rendered width.
     */
    private measureLinesByDrawing(textValue: string, width: number, fontSize: number): string[] {
        const result: string[] = []
        let start = 0
        while (start < textValue.length) {
            const end = this.findBreakIndex(textValue, start, width, fontSize)
            if (end <= start) {
                break
            }
            result.push(textValue.substring(start, end))
            start = end
        }
        return result.length > 0 ? result : [textValue]
    }

    private findBreakIndex(textValue: string, start: number, width: number, fontSize: number): number {
        // Find the longest prefix that fits within the width.
        let lo = start
        let hi = textValue.length
        while (lo < hi) {
            const mid = Math.ceil((lo + hi) / 2)
            if (this.measureTextWidth(textValue.substring(start, mid), fontSize) <= width) {
                lo = mid
            } else {
                hi = mid - 1
            }
        }
        if (lo <= start) {
            return Math.min(textValue.length, start + 1)
        }
        // Do not split a surrogate pair.
        if (lo < textValue.length) {
            const current = textValue.charCodeAt(lo)
            const previous = textValue.charCodeAt(lo - 1)
            if (current >= 0xDC00 && current <= 0xDFFF && previous >= 0xD800 && previous <= 0xDBFF) {
                lo -= 1
            }
        }
        let breakIndex = lo
        if (lo < textValue.length) {
            // Prefer keeping English words intact: break at the last space inside the fitted prefix.
            const lastSpace = textValue.lastIndexOf(' ', lo - 1)
            if (lastSpace > start) {
                breakIndex = lastSpace + 1
            }
            // Avoid starting a line with closing punctuation.
            while (breakIndex < textValue.length && this.noStartPunctuation.indexOf(textValue.charAt(breakIndex)) >= 0) {
                if (this.measureTextWidth(textValue.substring(start, breakIndex + 1), fontSize) > width) {
                    break
                }
                breakIndex++
            }
        }
        return breakIndex
    }

    private measureTextWidth(textValue: string, fontSize: number): number {
        this.wrapFont.setTypeface(this.typeface ?? this.defaultTypeface)
        this.wrapFont.setSize(fontSize)
        const blob = drawing.TextBlob.makeFromString(textValue, this.wrapFont, drawing.TextEncoding.TEXT_ENCODING_UTF8)
        const bound = blob.bounds()
        return Math.max(0, bound.right - bound.left)
    }

    buildDisplayLines(line: LrcLine, width: number, fontSize: number, highlightScale: number): LyricDisplayLine[] {
        // Explicit newlines are rendered by LrcTextView so their line height and empty lines stay together.
        if (line.text.indexOf('\n') >= 0) {
            const sourceEndIndex = line.wordList !== undefined && line.wordList.length > 0 ? line.wordList.length - 1 : 0
            return [this.createDisplayLine(line, line.beginTime, line.endTime, 0, 0, sourceEndIndex, line.text)]
        }
        const measuredLines = this.measureLines(line, width, fontSize * highlightScale)
        if (measuredLines.length <= 1) {
            const sourceEndIndex = line.wordList !== undefined && line.wordList.length > 0 ? line.wordList.length - 1 : 0
            return [this.createDisplayLine(line, line.beginTime, line.endTime, 0, 0, sourceEndIndex, measuredLines[0] ?? line.text)]
        }
        const isKrc = line.wordList !== undefined && line.wordList.length > 0
        if (!isKrc) {
            return this.buildLrcDisplayLines(line, measuredLines)
        }
        return this.buildKrcDisplayLines(line, measuredLines)
    }

    private buildLrcDisplayLines(line: LrcLine, measuredLines: string[]): LyricDisplayLine[] {
        const result: LyricDisplayLine[] = []
        const duration = Math.max(0, line.endTime - line.beginTime)
        const averageTime = measuredLines.length > 0 ? duration / measuredLines.length : duration
        for (let i = 0; i < measuredLines.length; i++) {
            const beginTime = line.beginTime + averageTime * i
            const endTime = i === measuredLines.length - 1 ? line.endTime : Math.min(line.endTime, beginTime + averageTime)
            result.push(this.createDisplayLine(line, beginTime, endTime, i, 0, 0, measuredLines[i]))
        }
        return result
    }

    private buildKrcDisplayLines(line: LrcLine, measuredLines: string[]): LyricDisplayLine[] {
        const wordList = line.wordList as LrcWord[]
        if (wordList.length <= 0) {
            return this.buildLrcDisplayLines(line, measuredLines)
        }
        const breakResult = this.splitWordsByLines(measuredLines, wordList)
        const result: LyricDisplayLine[] = []
        for (let i = 0; i < measuredLines.length; i++) {
            const breakIndex = breakResult[i] ?? [0, Math.max(0, wordList.length - 1)]
            const beginWord = wordList[Math.max(0, Math.min(breakIndex[0], wordList.length - 1))]
            const endWord = wordList[Math.max(0, Math.min(breakIndex[1], wordList.length - 1))]
            const beginTime = beginWord?.beginTime ?? line.beginTime
            const endTime = endWord?.endTime ?? line.endTime
            const sourceBeginIndex = Math.max(0, breakIndex[0])
            const sourceEndIndex = Math.max(sourceBeginIndex, Math.min(breakIndex[1], wordList.length - 1))
            result.push(this.createDisplayLine(line, beginTime, endTime, i, sourceBeginIndex, sourceEndIndex, measuredLines[i]))
        }
        return result
    }

    private splitWordsByLines(lines: string[], words: LrcWord[]): number[][] {
        const result: number[][] = []
        let wordIndex = 0
        for (const line of lines) {
            const targetLine = line.trim()
            const startIndex = wordIndex
            let matchedText = ''
            let matchedCount = 0
            while (wordIndex < words.length) {
                const wordText = words[wordIndex].text
                const nextText = (matchedText + wordText).trim()
                if (targetLine.startsWith(nextText)) {
                    matchedText = matchedText + wordText
                    wordIndex++
                    matchedCount++
                    if (nextText === targetLine) {
                        break
                    }
                    continue
                }
                const textNoPunct = nextText.replace(/[^\w\s\u4e00-\u9fa5]+$/, '')
                if (textNoPunct !== nextText && targetLine.startsWith(textNoPunct)) {
                    matchedText = matchedText + wordText
                    wordIndex++
                    matchedCount++
                    if (textNoPunct === targetLine) {
                        break
                    }
                    continue
                }
                if (matchedCount === 0) {
                    wordIndex++
                    matchedText = wordText
                    matchedCount = 1
                }
                break
            }
            result.push([startIndex, Math.max(startIndex, wordIndex - 1)])
        }
        if (result.length > 0 && result.length < lines.length) {
            const lastRange = result[result.length - 1]
            while (result.length < lines.length) {
                result.push([lastRange[0], lastRange[1]])
            }
        }
        return result
    }

    private buildCacheKey(textValue: string, width: number, fontSize: number): string {
        return textValue + '_' + width + '_' + fontSize
    }

    private createDisplayLine(
        line: LrcLine,
        beginTime: number,
        endTime: number,
        sourceLineIndex: number,
        sourceBeginIndex: number,
        sourceEndIndex: number,
        textOverride?: string
    ): LyricDisplayLine {
        return {
            line: {
                text: textOverride ?? line.text,
                beginTime,
                endTime,
                wordList: line.wordList?.slice(sourceBeginIndex, sourceEndIndex + 1)
            },
            beginTime,
            endTime,
            isKrc: line.wordList !== undefined && line.wordList.length > 0,
            sourceLineIndex,
            sourceBeginIndex,
            sourceEndIndex
        }
    }
}
