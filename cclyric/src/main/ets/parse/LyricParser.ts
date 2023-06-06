import { IParser } from './IParser';
import { Lyric } from '../bean/Lyric';
import { LyricLine } from '../bean/LyricLine';

/**
 * The parser to parse the string array of a standard lyric file.
 */
export class LyricParser implements IParser {
    // Example lyric file:
    // [ti:画心]
    // [ar:张靓颖]
    // [al:432326]
    // [by:]
    // [offset:0]
    // [00:00.10]画心 - 张靓颖
    // [01:05.49]看不穿 是你失落的魂魄

    /**
     * Parse the string array to a Lyric.
     * @param src The lyric source, a string array.
     * @returns A lyric instance.
     */
    parse(src: Array<string>): Lyric {
        let lyricLines = new Array<LyricLine>()
        let end = -1
        let title = ""
        let artist = ""
        let album = ""
        let by = ""
        let offset = 0
        for (let i = 0;i < src.length; i++) {
            let line = src[i]
            if (line.indexOf("ti") > 0) {
                title = this.parseIdTag(line)
            } else if (line.indexOf("ar") > 0) {
                artist = this.parseIdTag(line)
            } else if (line.indexOf("al") > 0) {
                album = this.parseIdTag(line)
            } else if (line.indexOf("by") > 0) {
                by = this.parseIdTag(line)
            } else if (line.indexOf("offset") > 0) {
                offset = Number.parseInt(this.parseIdTag(line))
            } else {
                let spr = line.split(']')
                let text = spr[1] // text
                if (i < src.length - 1) {
                    let begin = end == -1 ? this.parseTimeline(line) : end
                    let nextLine = src[i + 1]
                    end = this.parseTimeline(nextLine)
                    lyricLines.push(new LyricLine(text, begin - offset, end - offset))
                } else {
                    lyricLines.push(new LyricLine(text, end - offset, end + 1000 - offset))
                }
            }
        }
        return new Lyric(artist, title, album, by, offset, lyricLines)
    }

    private parseIdTag(line: string): string {
        let spr = line.split(":")
        let spr1 = spr[1]
        let result = spr1.replace("]", "")
        return result
    }

    private parseTimeline(line: string): number {
        let spr = line.split(']') // timestamp
        let time = spr[0]
        let timeString = time.replace('[', "") //00:00.50
        let timeStringList = timeString.split(':')
        let minuteString = timeStringList[0] //00
        let minute = Number.parseInt(minuteString)
        let secondStrings = timeStringList[1] //00.50
        let secondStringList = secondStrings.split(".")
        let secondString = secondStringList[0] //00
        let millionSecondString = secondStringList[1] //50
        let seconds = Number.parseInt(secondString)
        let millionSecond = Number.parseInt(millionSecondString)
        return minute * 60000 + seconds * 1000 + millionSecond // covert to million seconds
    }
}