import { LrcLine } from './LrcLine';

/**
 * The data object of Lyric.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export interface Lrc {
    artist?: string; // 艺术家
    title?: string; // 标题
    album?: string; // 专辑
    by?: string; // 制作
    offset?: number; // 偏移量(ms)
    lyricList: LrcLine[]; // 歌词行列表
}