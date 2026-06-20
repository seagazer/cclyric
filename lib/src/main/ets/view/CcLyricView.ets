import { Lrc } from '../bean/Lrc'
import { CcLyricController } from '../CcLyricController'
import { ListAdapter } from '../extensions/ListAdapter'
import { LrcLineView } from './LrcLineView'
import { LrcLine } from '../bean/LrcLine'
import { MediaLogger } from '../extensions/MediaLogger'
import { duration2text } from '../extensions/Extension'
import { AlignMode } from '../bean/AlignMode'
import { LyricTimelineItem } from '../bean/LyricTimelineItem'
import { LyricLayoutService } from './LyricLayoutService'
import { LyricScrollCoordinator } from './LyricScrollCoordinator'

const TAG = "[CcLyricView]"

/**
 * A view to play animation of Lrc or Krc for music player.
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
@ComponentV2
export struct CcLyricView {
    /**
     * The controller to control this view.
     */
    @Require @Param controller: CcLyricController
    @Param supportSeek: boolean = true
    @Event onSeekAction: (position: number) => void
    @Param autoHideSeekUIDelay: number = 800
    @Event onScrollChanged: (centerLine: LrcLine | undefined) => void
    @Event onScrollStateChanged: (scrolling: boolean) => void
    @Local lrcDataSource: ListAdapter<LrcLineView | undefined> = new ListAdapter()
    @Local focusIndex: number = -1
    @Local lyric?: Lrc = undefined
    @Local lineSpace: number = 0
    @Local fadeColor: ResourceColor = "#00ffffff"
    @Local fadeEnable: boolean = true
    @Local fadePercent: number = 0.2
    @Local emptyHint: ResourceStr = ""
    @Local isUserMoving: boolean = false
    @Local centerLrcLine?: LrcLine = undefined
    @Local topOffset: number = 100
    @Local alignMode: AlignMode = AlignMode.CENTER
    @Event onDataSourceReady: () => void
    private isDataSourceReady = false
    private viewWidth = 0 // px
    private playPosition = 0
    private dataSourceVersion = 0
    private lyricTimeline: LyricTimelineItem[] = []
    private readonly layoutService = new LyricLayoutService()
    private readonly scrollCoordinator = new LyricScrollCoordinator()
    private readonly scroller = this.scrollCoordinator.bindScroller()

    aboutToAppear(): void {
        // set controller
        this.emptyHint = this.controller.getEmptyHint()
        this.lineSpace = this.controller.getLineSpace()
        this.topOffset = this.controller.getTopOffset()
        this.alignMode = this.controller.getAlignMode()
        // this.fadeColor = this.controller.getFadeColor()
        this.fadeEnable = this.controller.getFadeEnable()
        this.fadePercent = this.controller.getFadePercent()
        this.controller.onProgressChanged = (position) => {
            this.playPosition = position
            this.updatePosition(position)
        }
        this.controller.onDataChanged = (lrc) => {
            this.lyric = lrc
            this.focusIndex = -1
            this.centerLrcLine = undefined
            this.isUserMoving = false
            this.scrollCoordinator.reset()
            this.setDataSource(lrc)
        }
        this.controller.onResize = () => {
            this.lineSpace = this.controller.getLineSpace()
            this.alignMode = this.controller.getAlignMode()
            if (this.lyric !== undefined) { // changed size when lyric displaying
                this.setDataSource(this.lyric)
            }
        }
        this.controller.onAttributeChanged = () => {
            MediaLogger.d(TAG, "attribute changed: " + JSON.stringify(this.controller))
            this.emptyHint = this.controller.getEmptyHint()
            this.fadeEnable = this.controller.getFadeEnable()
            this.fadePercent = this.controller.getFadePercent()
            this.topOffset = this.controller.getTopOffset()
            this.alignMode = this.controller.getAlignMode()
            for (let i = 0; i < this.lrcDataSource.totalCount(); i++) {
                const itemView = this.lrcDataSource.getData(i)
                if (itemView !== undefined) {
                    itemView.setTextSize(this.controller.getTextSize())
                    itemView.setTextColor(this.controller.getTextColor())
                    itemView.setKrcTextBgColor(this.controller.getKrcTextBgColor())
                    itemView.setTextHighlightColor(this.controller.getTextHighlightColor())
                    itemView.setAlignMode(this.alignMode)
                }
            }
        }
    }

    aboutToDisappear(): void {
        this.scrollCoordinator.clearRecoverTimer()
    }

    @Builder
    FadeOverlay() {
        if (this.fadeEnable) {
            Column()
                .width("100%")
                .height("100%")
                .hitTestBehavior(HitTestMode.Transparent)
                .linearGradient({
                    angle: 0,
                    colors: [[this.fadeColor, 0], ["#ffffffff", this.fadePercent], ["#ffffffff", 1 - this.fadePercent],
                        [this.fadeColor, 1]],
                    repeating: false
                })
                .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
        }
    }

    build() {
        Stack() {
            if (this.supportSeek) {
                Row() {
                    Text(this.centerLrcLine !== undefined ? duration2text(this.centerLrcLine.beginTime) : "--:--")
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .width(56)
                        .height("100%")
                    Blank()
                        .layoutWeight(1)
                        .height(1)
                        .backgroundColor("#80717171")
                    Image($r('app.media.cclyric_play'))
                        .width(56)
                        .height("100%")
                        .objectFit(ImageFit.Contain)
                        .onClick(() => {
                            if (this.centerLrcLine) {
                                this.onSeekAction?.(this.centerLrcLine.beginTime)
                            }
                        })
                }
                .width("100%")
                .height(this.controller.getTextSize() * 1.6)
                .visibility(this.isUserMoving ? Visibility.Visible : Visibility.Hidden)
                .animation({ duration: 300 })
            }
            if (this.lyric !== undefined && this.lrcDataSource !== undefined && this.lrcDataSource.totalCount() > 0) {
                List({ scroller: this.scroller, space: this.lineSpace }) {
                    LazyForEach(this.lrcDataSource, (itemView: LrcLineView | undefined, index: number) => {
                        ListItem() {
                            if (itemView && !itemView.isEmpty()) {
                                NodeContainer(itemView)
                                    .width("100%")
                                    .height("100%")
                            } else {
                                Stack()
                                    .width("100%")
                                    .height("100%")
                            }
                        }
                        .width("100%")
                        .height(this.controller.getTextSize() * 1.5) // todo multiline
                        .scale(this.focusIndex === index ?
                            {
                                x: this.controller.getHighlightScale(),
                                y: this.controller.getHighlightScale(),
                                centerX: this.alignMode === AlignMode.CENTER ? "50%" : 0
                            } :
                            { x: 1, y: 1, centerX: this.alignMode === AlignMode.CENTER ? "50%" : 0 })
                        .animation({ duration: 300 })
                    }, (krc: LrcLineView | undefined, index: number) => {
                        if (krc != undefined) {
                            return this.dataSourceVersion + "_" + krc.getLyric().beginTime + "_" + krc.getLyric().endTime + "_" + index
                        }
                        return this.dataSourceVersion + "_" + index
                    })
                    ListItem().height("50%")
                }
                .width("100%")
                .height("100%")
                .contentStartOffset(this.topOffset)
                .hitTestBehavior(HitTestMode.Transparent)
                .overlay(this.FadeOverlay())
                .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
                .edgeEffect(EdgeEffect.None)
                .scrollBar(BarState.Off)
                .onScrollIndex((_, __, center) => {
                    this.scrollCoordinator.onScrollIndex(this.lyricTimeline, center, this.onScrollChanged)
                    this.centerLrcLine = this.scrollCoordinator.getCenterLine()
                })
                .onScrollStart(() => {
                    this.scrollCoordinator.onScrollStart(this.onScrollStateChanged)
                })
                .onScrollStop(() => {
                    this.scrollCoordinator.onScrollStop(this.autoHideSeekUIDelay, this.onScrollStateChanged)
                })
                .onTouch((event) => {
                    switch (event.type) {
                        case TouchType.Down:
                            this.scrollCoordinator.onTouchDown(this.onScrollStateChanged)
                            break
                        case TouchType.Up:
                        case TouchType.Cancel:
                            this.scrollCoordinator.onTouchEnd(this.autoHideSeekUIDelay, this.supportSeek, this.onScrollStateChanged)
                            break
                    }
                    this.isUserMoving = this.scrollCoordinator.getUserMoving()
                })
            } else {
                Text(this.emptyHint)
                    .fontSize(this.controller.getTextSize())
                    .fontColor(this.controller.getTextColor())
            }
        }
        .width("100%")
        .height("100%")
        .onSizeChange((_, size) => {
            this.viewWidth = this.getUIContext().vp2px(size.width as number)
            this.lyric = this.controller.getLyric()
            if (this.lyric != undefined) {
                this.setDataSource(this.lyric)
            }
        })
    }

    private setDataSource(lyric: Lrc | undefined) {
        this.scrollCoordinator.reset()
        this.isUserMoving = false
        if (lyric === undefined) {
            this.lrcDataSource.clear(true)
            this.lyricTimeline = []
            this.isDataSourceReady = false
            this.focusIndex = -1
            this.centerLrcLine = undefined
            MediaLogger.w(TAG, 'The lyric is null, set empty view.')
            return
        }
        if (this.viewWidth <= 0) {
            MediaLogger.w(TAG, 'The view width is invalid, skip rebuilding lyric source.')
            return
        }
        this.isDataSourceReady = false
        this.dataSourceVersion++
        this.lrcDataSource.clear(false)
        this.lyricTimeline = []
        this.focusIndex = -1
        this.centerLrcLine = undefined
        const lines = lyric.lyricList
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            const displayLines = this.layoutService.buildDisplayLines(
                line,
                this.viewWidth,
                this.getUIContext().vp2px(this.controller.getTextSize()),
                this.controller.getHighlightScale()
            )
            for (const displayLine of displayLines) {
                const view = this.createLrcView(displayLine.line)
                this.lrcDataSource.addData(view, false)
                this.lyricTimeline.push({
                    beginTime: displayLine.beginTime,
                    endTime: displayLine.endTime,
                    displayLine,
                    view
                })
            }
        }
        this.lrcDataSource.notifyDataReload()
        this.isDataSourceReady = true
        const targetIndex = this.scrollCoordinator.resolveFocusIndex(this.lyricTimeline, this.playPosition)
        this.scrollToIndexSafely(targetIndex, false)
        this.onDataSourceReady?.()
    }

    private createLrcView(line: LrcLine) {
        const view = new LrcLineView(line)
        view.setTextSize(this.controller.getTextSize())
        view.setTextColor(this.controller.getTextColor())
        view.setKrcTextBgColor(this.controller.getKrcTextBgColor())
        view.setTextHighlightColor(this.controller.getTextHighlightColor())
        view.setAlignMode(this.alignMode)
        return view
    }

    private scrollToIndexSafely(index: number, animated: boolean) {
        if (index < 0 || index >= this.lrcDataSource.totalCount()) {
            return
        }
        this.scroller.scrollToIndex(index, animated)
    }

    private updatePosition(position: number) {
        if (this.lyricTimeline.length <= 0 || this.lyric === undefined) {
            MediaLogger.w(TAG, 'The lrc source is not set!')
            return
        }
        if (!this.isDataSourceReady) {
            MediaLogger.w(TAG, 'The lrc source is not ready!')
            return
        }
        const normalizedPosition = Math.max(0, position)
        const index = this.scrollCoordinator.resolveFocusIndex(this.lyricTimeline, normalizedPosition)
        if (index < 0 || index >= this.lyricTimeline.length) {
            return
        }
        const focusItem = this.lyricTimeline[index]
        if (focusItem === undefined) {
            return
        }
        if (this.scrollCoordinator.getFocusIndex() !== index) {
            this.scrollCoordinator.changeFocusLine(focusItem.view, index, (focusIndex) => {
                this.scrollToIndexSafely(focusIndex, true)
            })
            this.focusIndex = this.scrollCoordinator.getFocusIndex()
        }
        focusItem.view.play(position)
    }
}
