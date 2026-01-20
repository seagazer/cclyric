import { AlignMode } from './bean/AlignMode'
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
    private _textColor: number = 0xffb5b5b5
    private _krcTextBgColor: number = 0xff000000
    private _textHighlightColor: number = 0xffff0000
    private _highlightScale: number = 1.1
    private _emptyHint: ResourceStr = "--"
    private _fadeColor: ResourceColor = "#ffffffff"
    private _fadeEnable: boolean = true
    private _fadePercent: number = 0.2
    private _topOffset: number = 100 //vp
    private alignMode = AlignMode.CENTER

    // private _AnimDuration = 250

    /**
     * Open the debug log or not, default is false.
     * @param debug
     */
    setDebugger(debug: boolean) {
        MediaLogger.setDebugger(debug)
    }

    /**
     * Set the padding of lyric content by the top edge of view, default is 100vp.
     * @param offset The padding of lyric content by the top edge of view.
     * @returns
     */
    setTopOffset(offset: number): CcLyricController {
        this._topOffset = offset
        this.onAttributeChanged?.()
        return this
    }

    getTopOffset(): number {
        return this._topOffset
    }

    /**
     * Set the align mode, must set before bind the CcLyricView.
     * @param mode The align mode.{@link AlignMode}
     */
    setAlignMode(mode: AlignMode): CcLyricController {
        this.alignMode = mode
        this.onAttributeChanged?.()
        return this
    }

    getAlignMode() {
        return this.alignMode
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
     * @deprecated since v1.1.1
     *
     * Set the fade color on edge of the lyric view.
     * @param color The fade color.
     */
    public setFadeColor(color: ResourceColor): CcLyricController {
        // this._fadeColor = color;
        // this.invalidate()
        return this
    }

    public getFadeColor(): ResourceColor {
        return this._fadeColor;
    }

    /**
     * Show the fade edge of the lyric view or not.
     * @param enable
     */
    public setFadeEnable(enable: boolean): CcLyricController {
        this._fadeEnable = enable
        this.invalidate()
        return this
    }

    public getFadeEnable(): boolean {
        return this._fadeEnable
    }

    /**
     * Set the fade edge percent of the lyric view, the value is [0,1].
     * @param percent The fade edge percent of the view height.
     */
    public setFadePercent(percent: number): CcLyricController {
        if (percent < 0 || percent > 1) {
            throw new Error("The fade edge percent value must in [0,1]")
        }
        this._fadePercent = percent
        this.invalidate()
        return this
    }

    public getFadePercent(): number {
        return this._fadePercent
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
     * Set the text size of lyric, must set before bind the CcLyricView.
     * @param size The text size, the unit is vp.
     */
    public setTextSize(size: number): CcLyricController {
        this._textSize = size
        this.resize()
        return this
    }

    public getTextSize(): number {
        return this._textSize
    }

    /**
     * Set the space between lyric line, must set before bind the CcLyricView.
     * @param space The space value, the unit is vp.
     */
    public setLineSpace(space: number): CcLyricController {
        this._lineSpace = space
        this.resize()
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
     * Set the background text color of krc line.
     * @param color The background text color of krc line.
     */
    public setKrcTextBgColor(color: number): CcLyricController {
        this._krcTextBgColor = color
        this.invalidate()
        return this
    }

    public getKrcTextBgColor() {
        return this._krcTextBgColor
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
     * Set the highlight scale of the text, default is 1.1f, must set before bind the CcLyricView.
     * @param scale The scale value.
     */
    public setHighlightScale(scale: number): CcLyricController {
        this._highlightScale = scale
        this.resize()
        return this
    }

    public getHighlightScale(): number {
        return this._highlightScale
    }

    /**
     * @deprecated since v1.1.1
     *
     * Set the duration for lyric highlight animation.
     * @param duration The duration of animation, default is 250ms.
     */
    public setLrcAnimDuration(duration: number): CcLyricController {
        // this._AnimDuration = duration
        // this.invalidate()
        return this
    }

    // public getLrcAnimDuration() {
    //     return this._AnimDuration
    // }

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

    private resize() {
        this.onResize?.()
    }

    /**
     * Attention: Not call by user.
     */
    onResize?: () => void = undefined
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