import { Lrc } from './bean/Lrc'
import { MediaLogger } from './extensions/MediaLogger'

/**
 * The controller of CcLyricView to control the view.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export class CcLyricController {
    private lyric?: Lrc | undefined = undefined
    private _textSize: number = 20
    private _lineSpace: number = 12
    private _textColor: number = 0xff000000
    private _textHighlightColor: number = 0xffff0000
    private _highlightScale: number = 1.1
    private _emptyHint: ResourceStr = "--"
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
     * @param hintText The hint text.
     */
    public setEmptyHint(hintText: ResourceStr): CcLyricController {
        this._emptyHint = hintText;
        this.invalidate()
        return this
    }

    public getEmptyHint(): ResourceStr {
        return this._emptyHint;
    }

    /**
     * Set the fade color on edge of the lyric view.
     * @param color The fade color.
     */
    public setFadeColor(color: ResourceColor): CcLyricController {
        this._fadeColor = color;
        this.invalidate()
        return this
    }

    public getFadeColor(): ResourceColor {
        return this._fadeColor;
    }

    /**
     * Set the lyric.
     * @param data The lyric.
     */
    public setLyric(data: Lrc | undefined): CcLyricController {
        this.lyric = data
        this.onDataChanged?.(data)
        return this
    }

    public getLyric(): Lrc | undefined {
        return this.lyric
    }

    /**
     * Set the text size of lyric.
     * @param size The text size, the unit is vp.
     */
    public setTextSize(size: number): CcLyricController {
        this._textSize = size
        this.invalidate()
        return this
    }

    public getTextSize(): number {
        return this._textSize
    }

    /**
     * Set the space between lyric line.
     * @param space The space value, the unit is vp.
     */
    public setLineSpace(space: number): CcLyricController {
        this._lineSpace = space
        this.invalidate()
        return this
    }

    public getLineSpace(): number {
        return this._lineSpace
    }

    /**
     * Set the text color of lyric.
     * @param color The text color.
     */
    public setTextColor(color: number): CcLyricController {
        this._textColor = color
        this.invalidate()
        return this
    }

    public getTextColor() {
        return this._textColor
    }

    /**
     * Set the highlight text color of lyric.
     * @param color The text color.
     */
    public setTextHighlightColor(color: number): CcLyricController {
        this._textHighlightColor = color
        this.invalidate()
        return this
    }

    public getTextHighlightColor(): number {
        return this._textHighlightColor
    }

    /**
     * Set the highlight scale of the text, default is 1.1f.
     * @param scale The scale value.
     */
    public setHighlightScale(scale: number): CcLyricController {
        this._highlightScale = scale
        this.invalidate()
        return this
    }

    public getHighlightScale(): number {
        return this._highlightScale
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