/**
 * The data object of one word of LrcLine.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export interface LrcWord {
    /**
     * The text of lyric word.
     */
    text: string;

    /**
     * The begin time of the lyric word, the unit is ms.
     */
    beginTime: number;

    /**
     * The begin time of the lyric word, the unit is ms.
     */
    endTime: number;
}