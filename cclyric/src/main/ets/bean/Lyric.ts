import { LyricLine } from './LyricLine'

export class Lyric {
    readonly lyricList: Array<LyricLine>

    constructor(lyricList: Array<LyricLine>) {
        this.lyricList = lyricList
    }
}