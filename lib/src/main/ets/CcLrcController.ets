import { Lrc } from './bean/Lrc'
import { MediaLogger } from './extensions/MediaLogger'

/**
 * The controller of CcLyricView to control the view.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export class CcLrcController {
    private lyric?: Lrc | undefined = undefined
    private _textSize: number = 20
    private _lineSpace: number = 12
    private _textColor: number = 0xff000000
    private _textHighlightColor: number = 0xffff0000
    private _emptyHint: ResourceStr = "没有歌词"
    private _fadeColor: ResourceColor = "#ffffffff"

    /**
     * Open the debug log or not, default is false.
     * @param debug
     */
    setDebugger(debug: boolean) {
        MediaLogger.setDebugger(debug)
    }

    /**
     * Set the hint when the lyric is null.
     * @param value The hint text.
     */
    public set emptyHint(value: ResourceStr) {
        this._emptyHint = value;
        this.invalidate()
    }

    public get emptyHint(): ResourceStr {
        return this._emptyHint;
    }

    /**
     * Set the fade color on edge of the lyric view.
     * @param value The fade color.
     */
    public set fadeColor(value: ResourceColor) {
        this._fadeColor = value;
        this.invalidate()
    }

    public get fadeColor(): ResourceColor {
        return this._fadeColor;
    }

    /**
     * Set the lyric.
     * @param value The lyric.
     */
    public setLyric(value: Lrc | undefined) {
        this.lyric = value
        this.onDataChanged?.(value)
    }

    public getLyric(): Lrc | undefined {
        return this.lyric
    }

    /**
     * Set the text size of lyric.
     * @param value The text size, the unit is vp.
     */
    public set textSize(value: number) {
        this._textSize = value
        this.invalidate()
    }

    public get textSize(): number {
        return this._textSize
    }

    /**
     * Set the space between lyric line.
     * @param value The space value, the unit is vp.
     */
    public set lineSpace(value: number) {
        this._lineSpace = value
        this.invalidate()
    }

    public get lineSpace(): number {
        return this._lineSpace
    }

    /**
     * Set the text color of lyric.
     * @param value The text color.
     */
    public set textColor(value) {
        this._textColor = value
        this.invalidate()
    }

    public get textColor() {
        return this._textColor
    }

    /**
     * Set the highlight text color of lyric.
     * @param value The text color.
     */
    public set textHighlightColor(value: number) {
        this._textHighlightColor = value
        this.invalidate()
    }

    public get textHighlightColor(): number {
        return this._textHighlightColor
    }

    /**
     * Update the progress of media player.
     * @param position The progress of media player, the unit is ms.
     */
    updatePosition(position: number) {
        this.onProgressChanged?.(position)
    }

    private invalidate() {
        this.onAttributeChanged?.()
    }

    /**
     * Attention: Not call by user.
     */
    onProgressChanged?: (position: number) => void = undefined
    /**
     * Attention: Not call by user.
     */
    onAttributeChanged?: () => void = undefined
    /**
     * Attention: Not call by user.
     */
    onDataChanged?: (lyric: Lrc | undefined) => void = undefined
}