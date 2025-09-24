import { LrcWord } from "./LrcWord";

/**
 * The data object of one line of Lyric.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export interface LrcLine {
    text: string; // 完整文本
    beginTime: number; // 行开始时间(ms)
    endTime: number; // 行结束时间(ms)
    wordList?: LrcWord[]; // 逐字歌词
}