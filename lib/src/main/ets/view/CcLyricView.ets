import { Lrc } from '../bean/Lrc'
import { CcLrcController } from '../CcLrcController'
import { ListAdapter } from '../extensions/ListAdapter'
import { LrcLineView } from './LrcLineView'
import { drawing } from '@kit.ArkGraphics2D'
import { LrcLine } from '../bean/LrcLine'
import { MediaLogger } from '../extensions/MediaLogger'


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
    @Require @Param controller: CcLrcController
    @Local lrcDataSource: ListAdapter<LrcLineView | undefined> = new ListAdapter()
    @Local focusIndex: number = -1
    @Local lyric?: Lrc = undefined
    @Local lineSpace: number = 0
    @Local fadeColor: ResourceColor = "#00ffffff"
    @Local emptyHint: ResourceStr = ""
    private focusView?: LrcLineView = undefined
    private scroller = new Scroller()
    private middleLine = -1
    private viewWidth = 0
    private isUserMoving: boolean = false
    private userMoveTimeout = -1
    private centerIndex = -1

    aboutToAppear(): void {
        // set controller
        this.emptyHint = this.controller.getEmptyHint()
        this.lineSpace = this.controller.getLineSpace()
        this.fadeColor = this.controller.getFadeColor()
        this.controller.onProgressChanged = (position) => {
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
            this.fadeColor = this.controller.getFadeColor()
            for (let i = 0; i < this.lrcDataSource.totalCount(); i++) {
                const itemView = this.lrcDataSource.getData(i)
                if (itemView !== undefined) {
                    itemView.setTextSize(this.controller.getTextSize())
                    itemView.setTextColor(this.controller.getTextColor())
                    itemView.setTextHighlightColor(this.controller.getTextHighlightColor())
                }
            }
        }
    }

    aboutToDisappear(): void {
        clearInterval(this.userMoveTimeout)
    }

    @Builder
    FadeOverlay() {
        Column()
            .width("100%")
            .height("100%")
            .hitTestBehavior(HitTestMode.Transparent)
            .backgroundColor(Color.Transparent)
            .linearGradient({
                angle: 0,
                colors: [[this.fadeColor, 0], ["#00ffffff", 0.2], ["#00ffffff", 0.8], [this.fadeColor, 1]],
                repeating: false
            })
    }

    build() {
        Stack() {
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
                        .scale(this.focusIndex === index ? { x: this.controller.getHighlightScale(), y: this.controller.getHighlightScale() } :
                            { x: 1, y: 1 })
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
                .overlay(this.FadeOverlay())
                .edgeEffect(EdgeEffect.None)
                .scrollBar(BarState.Off)
                .onScrollIndex((start, end, center) => {
                    this.centerIndex = center
                })
                .onTouch((event) => {
                    switch (event.type) {
                        case TouchType.Down:
                            clearInterval(this.userMoveTimeout)
                            this.isUserMoving = true
                            break
                        case TouchType.Up:
                        case TouchType.Cancel:
                            this.userMoveTimeout = setTimeout(() => {
                                this.isUserMoving = false
                            }, 800)
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
        const font = new drawing.Font()
        font.setSize(this.getUIContext().vp2px(textSize))
        const bound = drawing.TextBlob.makeFromString(text, font)
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
        this.lrcDataSource.clear(false)
        this.fillPaddingData()
        const lines = lyric.lyricList;
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
        }
        this.fillPaddingData()
        this.lrcDataSource.notifyDataReload();
        this.scroller.scrollToIndex(0);
    }

    private breakLine(line: LrcLine, textWidth: number) {
        const lineWordList = line.wordList //单个字符结构
        if (lineWordList !== undefined && lineWordList.length > 0) { //krc
            const singleLineCharSize = Math.floor(lineWordList.length * this.viewWidth / textWidth) //单行字符数
            const maxLineCharSize = lineWordList.length
            const breakLines = Math.floor(line.text.length / singleLineCharSize) + 1 //折行数
            for (let j = 0; j < breakLines; j++) {
                const begin = singleLineCharSize * j
                const end = Math.min(begin + singleLineCharSize, maxLineCharSize)
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
            const singleLineCharSize = Math.floor(line.text.length * this.viewWidth / textWidth)
            const breakLines = Math.floor(line.text.length / singleLineCharSize) + 1
            const duration = line.endTime - line.beginTime
            const lineTime = duration * singleLineCharSize / line.text.length
            for (let j = 0; j < breakLines; j++) {
                const begin = singleLineCharSize * j
                const end = Math.min(begin + singleLineCharSize, line.text.length)
                const text = line.text.substring(begin, end)
                const beginTime = j * lineTime + line.beginTime
                const endTime = Math.min(beginTime + lineTime, line.endTime)
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
        view.setTextSize(this.controller.getTextSize());
        view.setTextColor(this.controller.getTextColor());
        view.setTextHighlightColor(this.controller.getTextHighlightColor());
        return view;
    }

    private updatePosition(position: number) {
        if (this.lrcDataSource === undefined || this.lyric === undefined) {
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