import { Lrc } from './bean/Lrc'

/**
 * The controller of CcLyricView to control the view.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export class CcLrcController {
    private _textSize: number = 20
    private _lineSpace: number = 12
    private _lyric?: Lrc | undefined = undefined
    private _textColor: number = 0xff000000
    private _textHighlightColor: number = 0xffff0000
    private _emptyHint: ResourceStr = "没有歌词";
    private _fadeColor: ResourceColor = "#ffffffff";

    public set emptyHint(value: ResourceStr) {
        this._emptyHint = value;
        this.invalidate()
    }

    public get emptyHint(): ResourceStr {
        return this._emptyHint;
    }

    public set fadeColor(value: ResourceColor) {
        this._fadeColor = value;
        this.invalidate()
    }

    public get fadeColor(): ResourceColor {
        return this._fadeColor;
    }

    public set lyric(value: Lrc | undefined) {
        this._lyric = value
        this.onDataChanged?.(value)
        // todo lrc changed
    }

    public get lyric(): Lrc | undefined {
        return this._lyric
    }

    public set textSize(value: number) {
        this._textSize = value
        this.invalidate()
    }

    public get textSize(): number {
        return this._textSize
    }

    public set lineSpace(value: number) {
        this._lineSpace = value
        this.invalidate()
    }

    public get lineSpace(): number {
        return this._lineSpace
    }

    public set textColor(value) {
        this._textColor = value
        this.invalidate()
    }

    public get textColor() {
        return this._textColor
    }

    public set textHighlightColor(value: number) {
        this._textHighlightColor = value
        this.invalidate()
    }

    public get textHighlightColor(): number {
        return this._textHighlightColor
    }

    updatePosition(position: number) {
        this.onProgressChanged?.(position)
    }

    private invalidate() {
        this.onAttributeChanged?.()
    }

    onProgressChanged?: (position: number) => void = undefined
    onAttributeChanged?: () => void = undefined
    onDataChanged?: (lyric: Lrc | undefined) => void = undefined
}