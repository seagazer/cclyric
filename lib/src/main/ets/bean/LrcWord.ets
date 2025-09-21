/**
 * The data object of one word of LrcLine.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export interface LrcWord {
    text: string; // 单个字符
    startTime: number; // 开始时间(ms)
    endTime: number; // 结束时间(ms)
}