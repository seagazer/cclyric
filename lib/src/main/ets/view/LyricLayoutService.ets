import { text } from '@kit.ArkGraphics2D'
import { LrcLine } from '../bean/LrcLine'
import { LrcWord } from '../bean/LrcWord'
import { LyricDisplayLine } from '../bean/LyricDisplayLine'

/**
 * Author: Seagazer
 * Date: 2026/6/17
 */
export class LyricLayoutService {
    private readonly fontCollection = new text.FontCollection()
    private readonly paragraphCache: Map<string, string[]> = new Map()

    measureLines(line: LrcLine, width: number, fontSize: number): string[] {
        if (width <= 0 || fontSize <= 0 || line.text.length <= 0) {
            return [line.text]
        }
        const cacheKey = this.buildCacheKey(line.text, width, fontSize)
        const cached = this.paragraphCache.get(cacheKey)
        if (cached !== undefined) {
            return cached
        }
        const style: text.ParagraphStyle = {
            wordBreak: text.WordBreak.NORMAL,
            textStyle: {
                fontSize: fontSize
            }
        }
        const builder = new text.ParagraphBuilder(style, this.fontCollection)
        builder.addText(line.text)
        const paragraph = builder.build()
        paragraph.layoutSync(width)
        const result: string[] = []
        const lineCount = paragraph.getLineCount()
        for (let i = 0; i < lineCount; i++) {
            const metrics = paragraph.getLineMetrics(i)
            if (metrics !== undefined) {
                result.push(line.text.substring(metrics.startIndex, metrics.endIndex))
            }
        }
        const normalized = result.length > 0 ? result : [line.text]
        this.paragraphCache.set(cacheKey, normalized)
        return normalized
    }

    buildDisplayLines(line: LrcLine, width: number, fontSize: number, highlightScale: number): LyricDisplayLine[] {
        const measuredLines = this.measureLines(line, width, fontSize * highlightScale)
        if (measuredLines.length <= 1) {
            return [this.createDisplayLine(line, line.beginTime, line.endTime, 0, 0, 0, measuredLines[0] ?? line.text)]
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
