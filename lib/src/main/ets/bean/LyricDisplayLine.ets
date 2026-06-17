import { LrcLine } from './LrcLine'

/**
 * Author: Seagazer
 * Date: 2026/6/17
 */
export interface LyricDisplayLine {
    line: LrcLine
    beginTime: number
    endTime: number
    isKrc: boolean
    sourceLineIndex: number
    sourceBeginIndex: number
    sourceEndIndex: number
}
