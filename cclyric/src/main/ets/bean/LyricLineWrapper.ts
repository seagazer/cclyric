import { LyricLine } from './LyricLine';

export class LyricWrapper extends LyricLine {
    readonly height: number

    constructor(src: LyricLine, height: number) {
        super(src.timestamp, src.text)
        this.height = height
    }
}