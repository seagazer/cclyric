import { LyricLine } from './LyricLine'

/**
 * @deprecated since v1.0.9
 */
export class Lyric {
    readonly artist: string
    readonly title: string
    readonly album: string
    readonly by: string
    readonly offset: number
    readonly lyricList: Array<LyricLine>

    constructor(artist: string, title: string, album: string, by: string, offset: number, lyricList: Array<LyricLine>) {
        this.artist = artist
        this.title = title
        this.album = album
        this.by = by
        this.offset = offset
        this.lyricList = lyricList
    }
}