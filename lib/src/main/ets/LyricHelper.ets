import { Lyric } from './bean/Lyric'
import { LyricLine } from './bean/LyricLine'
import { printD } from './extensions/Extension'

/**
 * The helper to get lyric line by media position.
 */
export class LyricHelper {
    private currentIndex = 0
    private currentLyric = ""
    private lrcList: Array<LyricLine> = new Array()

    private getIndex(position: number): number {
        let first = this.lrcList[0].beginTime
        if (position < first) {
            return 0
        }
        let last = this.lrcList[this.lrcList.length-1].beginTime
        if (position > last) {
            return this.lrcList.length - 1
        }
        for (let i = 0; i < this.lrcList.length - 1; i++) {
            let line = this.lrcList[i]
            if (position >= line.beginTime && position < line.nextTime) {
                return i
            }
        }
        return this.currentIndex
    }

    /**
     * Setup the lyric list.
     * @param data The lyric data.
     */
    public setLyricData(data: Lyric) {
        this.lrcList = data.lyricList
        this.currentIndex = 0
        this.currentLyric = ""
    }

    /**
     * Get the lyric text from current media progress.
     * @param position The position of the player.
     * @returns The lyric text current time.
     */
    public getLyric(position: number): string {
        if (!this.lrcList) {
            return ""
        }
        let index = this.getIndex(position)
        if (index != this.currentIndex) {
            printD("next line=" + index)
            this.currentLyric = this.lrcList[index].text
            this.currentIndex = index
        }
        return this.currentLyric
    }
}