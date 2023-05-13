import { IParser } from './IParser';
import { Lyric } from '../bean/Lyric';
import { LyricLine } from '../bean/LyricLine';

export class LyricParser implements IParser {
    private parseTime(line: string): number {
        let spr = line.split(']')
        // let text = spr[1]
        let spr1 = spr[0]
        let spr1_1 = spr1.replace('[', "") //00:00.50
        let spr2 = spr1_1.split(':')
        let spr2_1 = spr2[0] //00
        let minute = Number.parseInt(spr2_1)
        let spr2_2 = spr2[1] //00.50
        let spr3 = spr2_2.split(".")
        let spr3_1 = spr3[0] //00
        let spr3_2 = spr3[1] //50
        let seconds = Number.parseInt(spr3_1)
        let millionSecond = Number.parseInt(spr3_2)
        return minute * 60000 + seconds * 1000 + millionSecond
    }

    parse(src: Array<string>): Lyric {
        let list = new Array<LyricLine>()
        let end = -1
        for (let i = 0;i < src.length; i++) {
            let line = src[i]
            let spr = line.split(']')
            let text = spr[1]
            if (i < src.length - 1) {
                let begin = end == -1 ? this.parseTime(line) : end
                let nextLine = src[i + 1]
                end = this.parseTime(nextLine)
                list.push(new LyricLine(text, begin, end))
            } else {
                list.push(new LyricLine(text, end, end + 1000))
            }
        }
        return new Lyric(list)
    }
}