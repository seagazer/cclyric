export class LyricLine {
    readonly timestamp: number
    readonly text: string

    constructor(timestamp: number, text: string) {
        this.timestamp = timestamp
        this.text = text
    }
}