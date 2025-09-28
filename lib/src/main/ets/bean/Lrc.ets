import { LrcLine } from './LrcLine';

/**
 * The data object of Lyric.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export interface Lrc {
    /**
     * The artist info.
     */
    artist?: string;

    /**
     * The media title.
     */
    title?: string;

    /**
     * The album info.
     */
    album?: string;

    /**
     * The creator info.
     */
    by?: string;

    /**
     * The offset.
     */
    offset?: number;

    /**
     * The lyric line list.
     */
    lyricList: LrcLine[];
}