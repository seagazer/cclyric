import { Lyric } from '../bean/Lyric'

// default config
const DEFAULT_LINE_SPACE = 16
const DEFAULT_TEXT_SIZE = 18
const DEFAULT_HIGHLIGHT_SCALE = 1.2
const DEFAULT_TEXT_COLOR = "#80000000"
const DEFAULT_HIGHLIGHT_COLOR = "#000000"
const DEFAULT_EDGE_COLOR = "#ffffff"
const DEFAULT_ANIM_DURATION = 300
const DEFAULT_CACHE_SIZE = 4

/**
 * The controller for LyricView.
 */
export class LyricController {
    private lyric: Lyric | null = null
    private textColor: string = DEFAULT_TEXT_COLOR
    private textSize: number = DEFAULT_TEXT_SIZE
    private highlightColor: string = DEFAULT_HIGHLIGHT_COLOR
    private highlightScale: number = DEFAULT_HIGHLIGHT_SCALE
    private edgeColor: string = DEFAULT_EDGE_COLOR
    private lineSpace: number = DEFAULT_LINE_SPACE
    private animDuration: number = DEFAULT_ANIM_DURATION
    private cacheSize: number = DEFAULT_CACHE_SIZE
    private isBold: boolean = true
    private emptyHint: string = "--"
    private alignMode: "left" | "center" = "center"
    /**
     *  Listener to observe the lyric data set changed. This is a inner function, do not call this.
     */
    onDataChangedListener: (lyric: Lyric) => void = () => {
    }
    /**
     *  Listener to observe the media position changed. This is a inner function, do not call this.
     */
    onPositionChangedListener: (position: number) => void = () => {
    }
    /**
     *  Listener to observe the user config changed. This is a inner function, do not call this.
     */
    onInvalidated: (reLayout: boolean) => void = () => {
    }

    /**
     * Update the current position of media player to refresh the lyric view.
     * @param mediaPosition The current position of media player.
     */
    updatePosition(mediaPosition: number) {
        this.onPositionChangedListener?.(mediaPosition)
    }

    /**
     * Set the lyric datasource.
     * @param lyric The lyric datasource.
     * @returns LyricConfig
     */
    setLyric(lyric: Lyric): LyricController {
        this.lyric = lyric
        this.onDataChangedListener(lyric)
        return this
    }

    /**
     * Get the lyric datasource.
     * @returns The lyric datasource.
     */
    getLyric(): Lyric | null {
        return this.lyric
    }

    /**
     * Set the color of normal lyric text. The default color is 0xff929292.
     * @param color The color of normal lyric text.
     * @returns LyricConfig
     */
    setTextColor(color: string): LyricController {
        this.textColor = color
        this.onInvalidated(false)
        return this
    }

    /**
     * Get the color of normal lyric text.
     * @returns The color of normal lyric text.
     */
    getTextColor(): string {
        return this.textColor
    }

    /**
     * Set the text size(vp) of normal lyric. The default size is 48px.
     * @param textSize The text size of normal lyric.
     * @returns LyricConfig
     */
    setTextSize(textSize: number): LyricController {
        this.textSize = textSize
        this.onInvalidated(true)
        return this
    }

    /**
     * Get the text size(vp) of normal lyric.
     * @returns The text size of normal lyric.
     */
    getTextSize(): number {
        return this.textSize
    }

    /**
     * Set the color of focused lyric text. The default color is Black.
     * @param color The color of focused lyric text.
     * @returns LyricConfig
     */
    setHighlightColor(color: string): LyricController {
        this.highlightColor = color
        this.onInvalidated(false)
        return this
    }

    /**
     * Get the color of focused lyric text.
     * @returns The color of focused lyric text.
     */
    getHighlightColor(): string {
        return this.highlightColor
    }

    /**
     * Set the scale of focused lyric. The default scale is 1.2f.
     * @param scale The scale of focused lyric.
     * @returns LyricConfig
     */
    setHighlightScale(scale: number): LyricController {
        this.highlightScale = scale
        this.onInvalidated(true)
        return this
    }

    /**
     * Get the scale of focused lyric.
     * @returns The scale of focused lyric.
     */
    getHighlightScale(): number {
        return this.highlightScale
    }

    /**
     * Set is bold or not for the focused lyric. Default is true.
     * @param bold True to set text bold style, false to set normal style.
     * @returns LyricConfig
     */
    setHighlightBold(isBold: boolean): LyricController {
        this.isBold = isBold
        this.onInvalidated(false)
        return this
    }

    /**
     * The bold style of focused lyric.
     * @returns True to set text bold style, false to set normal style.
     */
    isHighlightBold(): boolean {
        return this.isBold
    }

    /**
     * Set the fade edge color of top and bottom. The default color is White.
     * @deprecated since v1.0.2
     * @param color The fade edge color of top and bottom.
     * @returns LyricConfig
     */
    setEdgeColor(color: string): LyricController {
        this.edgeColor = color
        this.onInvalidated(false)
        return this
    }

    /**
     * Get the fade edge color of top and bottom.
     * @deprecated since v1.0.2
     * @returns The fade edge color of top and bottom.
     */
    getEdgeColor(): string {
        return this.edgeColor
    }

    /**
     * Set the line space(vp) between two lyric lines. The default line space is 16px.
     * @param lineSpace The line space between two lyric lines.
     * @returns LyricConfig
     */
    setLineSpace(lineSpace: number): LyricController {
        this.lineSpace = lineSpace
        this.onInvalidated(true)
        return this
    }

    /**
     * Get the line space between two lyric lines.
     * @returns The line space between two lyric lines.
     */
    getLineSpace(): number {
        return this.lineSpace
    }

    /**
     * Set the duration of translate animation. The default duration is 500ms.
     * @param duration The duration of translate animation.
     * @returns LyricConfig
     */
    setAnimationDuration(duration: number): LyricController {
        this.animDuration = duration
        return this
    }

    /**
     * Get the duration of translate animation.
     * @returns The duration of translate animation.
     */
    getAnimationDuration(): number {
        return this.animDuration
    }

    /**
     * Set the size of lyric lines to draw out of top and bottom, the result is min of cacheSize and the lyric lines.
     * The default cache size is 2.
     * @param cacheSize The size of lyric lines to draw out of top and bottom.
     * @returns LyricConfig
     */
    setCacheSize(cacheSize: number): LyricController {
        this.cacheSize = cacheSize
        this.onInvalidated(false)
        return this
    }

    /**
     * Get the size of lyric lines to draw out of top and bottom.
     * @returns The size of lyric lines to draw out of top and bottom.
     */
    getCacheSize(): number {
        return this.cacheSize
    }

    /**
     * Set the hint text when is no lyric to display.
     * @param hint The hint text when is no lyric to display.
     * @returns LyricConfig
     */
    setEmptyHint(hint: string): LyricController {
        this.emptyHint = hint
        this.onInvalidated(false)
        return this
    }

    /**
     * Get the hint text when is no lyric to display.
     * @returns The hint text when is no lyric to display.
     */
    getEmptyHint(): string {
        return this.emptyHint
    }

    /**
     * Set the alignment of the lyric text to display from.
     * @param align The value is "left" | "center", default is "left".
     * @returns LyricConfig
     */
    setAlignMode(align: "left" | "center"): LyricController {
        this.alignMode = align
        this.onInvalidated(true)
        return this
    }

    /**
     * Get the alignment of the lyric text to display from.
     * @returns The value is "left" | "center".
     */
    getAlignMode(): "left" | "center" {
        return this.alignMode
    }

    /**
     * Invalidate the ui by user, this will not reLayout, just do draw.
     */
    invalidate() {
        this.onInvalidated(false)
    }
}