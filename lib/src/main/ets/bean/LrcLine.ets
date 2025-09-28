import { LrcWord } from './LrcWord';

/**
 * The data object of one line of Lyric.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export interface LrcLine {
    /**
     * The text of lyric line.
     */
    text: string;

    /**
     * The begin time of the lyric line, the unit is ms.
     */
    beginTime: number;

    /**
     * The end time of the lyric line, the unit is ms.
     */
    endTime: number;

    /**
     * The word info list for krc.
     */
    wordList?: LrcWord[];
}