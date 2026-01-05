import { Lrc } from '../bean/Lrc'
import { CcLyricController } from '../CcLyricController'
import { ListAdapter } from '../extensions/ListAdapter'
import { LrcLineView } from './LrcLineView'
import { drawing } from '@kit.ArkGraphics2D'
import { LrcLine } from '../bean/LrcLine'
import { MediaLogger } from '../extensions/MediaLogger'
import { duration2text } from '../extensions/Extension'
import { AlignMode } from '../bean/AlignMode'


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
    @Event onDataSourceReady: () => void
    private isDataSourceReady = false
    private focusView?: LrcLineView = undefined
    private scroller = new Scroller()
    private middleLine = -1
    private viewWidth = 0
    private userMoveTimeout = -1
    private measureFont = new drawing.Font()
    private playPosition = 0

    aboutToAppear(): void {
        // set controller
        this.emptyHint = this.controller.getEmptyHint()
        this.lineSpace = this.controller.getLineSpace()
        // this.fadeColor = this.controller.getFadeColor()
        this.fadeEnable = this.controller.getFadeEnable()
        this.fadePercent = this.controller.getFadePercent()
        this.controller.onProgressChanged = (position) => {
            this.playPosition = this.playPosition
            this.updatePosition(position)
        }
        this.controller.onDataChanged = (lrc) => {
            this.focusView = undefined
            this.lyric = lrc
            this.setDataSource(lrc)
        }
        this.controller.onAttributeChanged = () => {
            MediaLogger.d(TAG, "attribute changed: " + JSON.stringify(this.controller))
            this.emptyHint = this.controller.getEmptyHint()
            this.lineSpace = this.controller.getLineSpace()
            // this.fadeColor = this.controller.getFadeColor()
            this.fadeEnable = this.controller.getFadeEnable()
            this.fadePercent = this.controller.getFadePercent()
            for (let i = 0; i < this.lrcDataSource.totalCount(); i++) {
                const itemView = this.lrcDataSource.getData(i)
                if (itemView !== undefined) {
                    itemView.setAnimationDuration(this.controller.getLrcAnimDuration())
                    itemView.setTextSize(this.controller.getTextSize())
                    itemView.setTextColor(this.controller.getTextColor())
                    itemView.setTextHighlightColor(this.controller.getTextHighlightColor())
                    itemView.setAlignMode(this.controller.getAlignMode())
                }
            }
        }
    }

    aboutToDisappear(): void {
        clearInterval(this.userMoveTimeout)
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
                    LazyForEach(this.lrcDataSource, (krc: LrcLineView | undefined, index: number) => {
                        ListItem() {
                            if (krc && !krc.isEmpty()) {
                                NodeContainer(krc)
                                    .width("100%")
                                    .height("100%")
                            } else {
                                Stack()
                                    .width("100%")
                                    .height("100%")
                            }
                        }
                        .width("100%")
                        .height(this.controller.getTextSize() * 1.5)
                        .scale(this.focusIndex === index ?
                            {
                                x: this.controller.getHighlightScale(),
                                y: this.controller.getHighlightScale(),
                                centerX: this.controller.getAlignMode() === AlignMode.CENTER ? "50%" : 0
                            } :
                            { x: 1, y: 1, centerX: this.controller.getAlignMode() === AlignMode.CENTER ? "50%" : 0 })
                        .animation({ duration: 300 })
                    }, (krc: LrcLineView | undefined, index: number) => {
                        if (krc != undefined) {
                            return krc.getLyric().beginTime + "_" + krc.getLyric().endTime + "_" + index
                        }
                        return index.toString()
                    })
                }
                .width("100%")
                .height("100%")
                .hitTestBehavior(HitTestMode.Transparent)
                .overlay(this.FadeOverlay())
                .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
                .edgeEffect(EdgeEffect.None)
                .scrollBar(BarState.Off)
                .scrollSnapAlign(ScrollSnapAlign.CENTER)
                .onScrollIndex((_, __, center) => {
                    const view = this.lrcDataSource.getData(center)
                    if (view !== undefined) {
                        const curCenter = view.getLyric()
                        if (this.centerLrcLine != curCenter) {
                            this.centerLrcLine = curCenter
                            this.onScrollChanged?.(this.centerLrcLine)
                        }
                    }
                })
                .onScrollStart(() => {
                    this.onScrollStateChanged?.(this.isUserMoving)
                })
                .onScrollStop(() => {
                    this.userMoveTimeout = setTimeout(() => {
                        this.onScrollStateChanged?.(this.isUserMoving)
                    }, this.autoHideSeekUIDelay)
                })
                .onTouch((event) => {
                    switch (event.type) {
                        case TouchType.Down:
                            clearInterval(this.userMoveTimeout)
                            this.isUserMoving = true
                            break
                        case TouchType.Up:
                        case TouchType.Cancel:
                            if (this.supportSeek) {
                                this.userMoveTimeout = setTimeout(() => {
                                    this.isUserMoving = false
                                }, this.autoHideSeekUIDelay)
                            } else {
                                this.isUserMoving = false
                            }
                            break
                    }
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
            if (this.middleLine === -1) {
                const h = size.height as number
                this.viewWidth = this.getUIContext().vp2px(size.width as number)
                this.middleLine =
                    Math.round(((h + this.controller.getLineSpace()) / (this.controller.getTextSize() * 1.5 + this.controller.getLineSpace()) - 1) /
                        2)
                MediaLogger.i(TAG, "view height= " + h + ", middle line= " + this.middleLine)
                this.lyric = this.controller.getLyric()
                if (this.lyric != undefined) {
                    this.setDataSource(this.lyric)
                }
            }
        })
    }

    private measureText(text: string, textSize: number, scale: number): number {
        this.measureFont.setSize(this.getUIContext().vp2px(textSize))
        const bound = drawing.TextBlob.makeFromString(text, this.measureFont)
        const rect = bound.bounds()
        const textWidth = rect.right - rect.left
        return textWidth * scale
    }

    private setDataSource(lyric: Lrc | undefined) {
        if (this.focusView !== undefined) {
            this.focusView.stop()
            this.focusView = undefined
        }
        if (lyric === undefined) {
            this.lrcDataSource.clear(true)
            MediaLogger.w(TAG, "The lyric is null, set empty view.")
            return
        }
        if (this.middleLine === -1) {
            MediaLogger.w(TAG, "The size of view is not ready.")
            return
        }
        this.isDataSourceReady = false
        this.lrcDataSource.clear(false)
        this.fillPaddingData()
        const lines = lyric.lyricList
        let targetInitIndex = -1
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            // measure and break line
            const textWidth = this.measureText(line.text, this.controller.getTextSize(), this.controller.getHighlightScale())
            if (textWidth > this.viewWidth) {
                // break line
                this.breakLine(line, textWidth)
            } else {
                const view = this.createLrcView(line);
                this.lrcDataSource.addData(view, false);
            }
            if (this.playPosition > 0 && this.playPosition >= line.beginTime && this.playPosition < line.endTime) {
                targetInitIndex = i
            }
        }
        this.fillPaddingData()
        this.lrcDataSource.notifyDataReload();
        setTimeout(() => {
            if (targetInitIndex == -1) {
                this.scroller.scrollToIndex(0);
            } else {
                this.scroller.scrollToIndex(targetInitIndex);
            }
            this.isDataSourceReady = true
            this.onDataSourceReady?.()
        }, 50)
    }

    private breakLine(line: LrcLine, textWidth: number) {
        const lineWordList = line.wordList
        if (lineWordList !== undefined && lineWordList.length > 0) { //krc
            const krcWordSize = lineWordList.length
            const singleKrcLineWordSize = Math.floor(krcWordSize * this.viewWidth / textWidth)
            const breakLines = Math.floor(krcWordSize / singleKrcLineWordSize) + 1
            for (let i = 0; i < breakLines; i++) {
                const begin = singleKrcLineWordSize * i
                const end = Math.min(begin + singleKrcLineWordSize, krcWordSize)
                const text = line.text.substring(begin, end) //[begin,end)
                const singKrcLine: LrcLine = {
                    text: text,
                    beginTime: lineWordList[begin].beginTime,
                    endTime: lineWordList[end - 1].endTime,
                    wordList: lineWordList.slice(begin, end) //[begin,end)
                }
                const view = this.createLrcView(singKrcLine)
                this.lrcDataSource.addData(view, false)
            }
        } else { //lrc
            const lrcCharSize = line.text.length
            const singleLrcLineCharSize = Math.floor(lrcCharSize * this.viewWidth / textWidth)
            const lineTotalDuration = line.endTime - line.beginTime
            const singleLineDuration = lineTotalDuration * singleLrcLineCharSize / lrcCharSize
            const breakLines = Math.floor(lrcCharSize / singleLrcLineCharSize) + 1
            for (let i = 0; i < breakLines; i++) {
                const begin = singleLrcLineCharSize * i
                const end = Math.min(begin + singleLrcLineCharSize, lrcCharSize)
                const text = line.text.substring(begin, end)
                const beginTime = i * singleLineDuration + line.beginTime
                const endTime = Math.min(beginTime + singleLineDuration, line.endTime)
                const singLrcLine: LrcLine = {
                    text: text,
                    beginTime: beginTime,
                    endTime: endTime,
                }
                const view = this.createLrcView(singLrcLine)
                this.lrcDataSource.addData(view, false)
            }
        }
    }

    private fillPaddingData() {
        for (let i = 0; i < this.middleLine; i++) {
            this.lrcDataSource.addData(undefined, false)
        }
    }

    private createLrcView(line: LrcLine) {
        const view = new LrcLineView(line);
        view.setAnimationDuration(this.controller.getLrcAnimDuration())
        view.setTextSize(this.controller.getTextSize());
        view.setTextColor(this.controller.getTextColor());
        view.setTextHighlightColor(this.controller.getTextHighlightColor());
        view.setAlignMode(this.controller.getAlignMode())
        return view;
    }

    private updatePosition(position: number) {
        if (this.lrcDataSource === undefined || this.lyric === undefined) {
            MediaLogger.w(TAG, "The lrc source is not set!")
            return
        }
        if (!this.isDataSourceReady) {
            MediaLogger.w(TAG, "The lrc source is not ready!")
            return
        }
        if (this.focusView !== undefined) {
            this.focusView.play(position)
        }
        const beginIndex = this.middleLine
        const endIndex = this.lrcDataSource.totalCount() - 1
        for (let i = beginIndex; i < endIndex; i++) {
            const lyric = this.lrcDataSource.getData(i)
            if (lyric === undefined) {
                continue
            }
            const lyricLine = lyric.getLyric()
            const start = lyricLine.beginTime
            const end = lyricLine.endTime
            if (position >= start && position < end) {
                if (this.focusIndex != i) {
                    if (this.focusView) {
                        this.focusView.stop()
                        MediaLogger.d(TAG, this.focusView.getLyric().text + "--unHighlight")
                        this.focusView = undefined
                    }
                    this.focusView = this.lrcDataSource.getData(i)
                    MediaLogger.d(TAG, this.focusView?.getLyric().text + "--highlight")
                    this.focusIndex = i
                    if (!this.isUserMoving) {
                        const centerScrollIndex = i - this.middleLine
                        this.scroller.scrollToIndex(centerScrollIndex, true)
                    }
                }
                break
            }
        }
    }
}