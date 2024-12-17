/**
 * The info of a lyric line.
 *
 * Author: Seagazer
 * Date: 2024/12/17
 */
export class LyricLineMeasureResult {
    // normal style
    lineHeight: number = 0
    lineCount: number = 0
    preLineText = new Array<string>()
    preLineWidth = new Array<number>()
    // highlight style
    lineHeightHL: number = 0
    lineCountHL: number = 0
    preLineTextHL = new Array<string>()
    preLineWidthHL = new Array<number>()

    constructor() {
    }
}