import { LyricLine } from './LyricLine';

/**
 * @deprecated since v1.0.9
 */
export class LyricLineWrapper extends LyricLine {
    readonly height: number

    constructor(src: LyricLine, height: number) {
        super(src.text, src.beginTime, src.nextTime)
        this.height = height
    }
}