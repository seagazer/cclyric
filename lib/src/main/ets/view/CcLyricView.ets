import { Lrc } from '../bean/Lrc'
import { CcLyricController } from '../CcLyricController'
import { ListAdapter } from '../extensions/ListAdapter'
import { LrcLineView } from './LrcLineView'
import { drawing, text } from '@kit.ArkGraphics2D'
import { LrcLine } from '../bean/LrcLine'
import { MediaLogger } from '../extensions/MediaLogger'
import { duration2text } from '../extensions/Extension'
import { AlignMode } from '../bean/AlignMode'
import { LrcWord } from '../bean/LrcWord'


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
    @Event onDataSourceReady: () => void
    private isDataSourceReady = false
    private focusView?: LrcLineView = undefined
    private scroller = new Scroller()
    private viewWidth = 0 // px
    private userMoveTimeout = -1
    private playPosition = 0

    aboutToAppear(): void {
        // set controller
        this.emptyHint = this.controller.getEmptyHint()
        this.lineSpace = this.controller.getLineSpace()
        this.topOffset = this.controller.getTopOffset()
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
        this.controller.onResize = () => {
            this.lineSpace = this.controller.getLineSpace()
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
            for (let i = 0; i < this.lrcDataSource.totalCount(); i++) {
                const itemView = this.lrcDataSource.getData(i)
                if (itemView !== undefined) {
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
                    if (center > this.lrcDataSource.totalCount() - 1) {
                        return
                    }
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
            this.viewWidth = this.getUIContext().vp2px(size.width as number)
            this.lyric = this.controller.getLyric()
            if (this.lyric != undefined) {
                this.setDataSource(this.lyric)
            }
        })
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
        this.isDataSourceReady = false
        this.lrcDataSource.clear(false)
        const lines = lyric.lyricList
        let targetInitIndex = -1
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            this.checkBreakLine(line)
        }
        this.lrcDataSource.notifyDataReload();
        setTimeout(() => {
            if (targetInitIndex == -1) {
                this.scroller.scrollToIndex(0, false);
            } else {
                this.scroller.scrollToIndex(targetInitIndex, false);
            }
            this.isDataSourceReady = true
            this.onDataSourceReady?.()
        }, 50)
    }

    private fontCollection = new text.FontCollection()

    private checkBreakLine(lrcLine: LrcLine) {
        MediaLogger.w("abcd", "break line= " + lrcLine.text)
        const style: text.ParagraphStyle = {
            wordBreak: text.WordBreak.NORMAL,
            textStyle: {
                fontSize: this.getUIContext().vp2px(this.controller.getTextSize() * this.controller.getHighlightScale())
            }
        }
        const builder = new text.ParagraphBuilder(style, this.fontCollection)
        builder.addText(lrcLine.text)
        const paragraph = builder.build()
        paragraph.layoutSync(this.viewWidth)
        const breakLineSize = paragraph.getLineCount()
        MediaLogger.e("abcd", "---------------break line count= " + breakLineSize)
        if (breakLineSize > 1) { // multi lines
            const isKrc = lrcLine.wordList !== undefined && lrcLine.wordList.length > 0
            const averageLineTime = (lrcLine.endTime - lrcLine.beginTime) / breakLineSize
            if (isKrc) {
                const lines: string[] = []
                for (let i = 0; i < breakLineSize; i++) {
                    const lineMetric = paragraph.getLineMetrics(i)
                    if (lineMetric !== undefined) {
                        const text = lrcLine.text.substring(lineMetric.startIndex, lineMetric.endIndex)
                        lines.push(text)
                    }
                }
                MediaLogger.w("abcd", "--------------lines= " + JSON.stringify(lines))
                const wordList = lrcLine.wordList!
                MediaLogger.w("abcd", "--------------wordList= " + JSON.stringify(wordList))
                const breakResult = this.splitWordsByLines(lines, wordList)
                for (let i = 0; i < breakResult.length; i++) {
                    const breakIndex = breakResult[i]
                    MediaLogger.i("abcd", "break index= " + JSON.stringify(breakIndex))
                    const begin = wordList[breakIndex[0]]
                    const end = wordList[breakIndex[1]]
                    MediaLogger.i("abcd", "begin= " + JSON.stringify(begin))
                    MediaLogger.i("abcd", "end= " + JSON.stringify(end))
                    MediaLogger.w("abcd", "break words= " + JSON.stringify(wordList.slice(breakIndex[0], breakIndex[1] + 1)))
                    const singLrcLine: LrcLine = {
                        text: lines[i],
                        beginTime: begin.beginTime,
                        endTime: end.endTime,
                        wordList: wordList.slice(breakIndex[0], breakIndex[1] + 1)
                    }
                    const view = this.createLrcView(singLrcLine)
                    this.lrcDataSource.addData(view, false)
                }
            } else {
                for (let i = 0; i < breakLineSize; i++) {
                    const lineMetric = paragraph.getLineMetrics(i)
                    if (lineMetric !== undefined) {
                        const start = lineMetric.startIndex
                        const end = lineMetric.endIndex
                        const newLineText = lrcLine.text.substring(start, end)
                        const singLrcLine: LrcLine = {
                            text: newLineText,
                            beginTime: averageLineTime * i,
                            endTime: Math.min(averageLineTime * (i + 1), lrcLine.endTime),
                        }
                        const view = this.createLrcView(singLrcLine)
                        this.lrcDataSource.addData(view, false)
                    }
                }
            }
        } else { // single line
            const view = this.createLrcView(lrcLine)
            this.lrcDataSource.addData(view, false)
        }
    }

    private splitWordsByLines(lines: string[], words: LrcWord[]): number[][] {
        let result: number[][] = [];
        let wordIndex: number = 0;
        for (let line of lines) {
            let targetLine: string = line.trim();
            let startIndex: number = wordIndex;
            let matchedText: string = "";
            while (wordIndex < words.length) {
                // 直接拼接word，保留原始空格（不额外添加空格）
                let nextText: string = matchedText + words[wordIndex].text;
                let nextTextTrimmed: string = nextText.trim();
                // 检查trim后的文本是否匹配目标行开头
                if (targetLine.startsWith(nextTextTrimmed)) {
                    matchedText = nextText;
                    wordIndex++;
                    if (nextTextTrimmed === targetLine) break;
                } else {
                    // 尝试去除末尾标点后匹配（处理 "us," 匹配 "us who we" 的情况）
                    let textNoPunct: string = nextTextTrimmed.replace(/[^\w\s\u4e00-\u9fa5]+$/, "");
                    if (textNoPunct !== nextTextTrimmed && targetLine.startsWith(textNoPunct)) {
                        matchedText = nextText;
                        wordIndex++;
                        if (textNoPunct === targetLine) break;
                    } else {
                        break;
                    }
                }
            }
            result.push([startIndex, wordIndex > startIndex ? wordIndex - 1 : startIndex]);
        }
        return result;
    }

    private createLrcView(line: LrcLine) {
        const view = new LrcLineView(line);
        view.setTextSize(this.controller.getTextSize())
        view.setTextColor(this.controller.getTextColor())
        view.setTextHighlightColor(this.controller.getTextHighlightColor())
        view.setAlignMode(this.controller.getAlignMode())
        return view
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
        if (this.focusView !== undefined) { // play the focus highlight animation
            this.focusView.play(position)
        }
        const size = this.lrcDataSource.totalCount()
        for (let i = 0; i < size; i++) {
            const lyricLineView = this.lrcDataSource.getData(i)
            if (lyricLineView === undefined) {
                continue
            }
            const lyricLine = lyricLineView.getLyric()
            const beginTime = lyricLine.beginTime
            const endTime = lyricLine.endTime
            if (position >= beginTime && position < endTime) { //between a lyric line
                if (this.focusIndex != i) {
                    this.changeFocusLine(lyricLineView, i)
                }
                break
            } else if (i < size - 2) { // between at two lyric lines
                const nextItemIndex = i + 1
                const nextLineView = this.lrcDataSource.getData(nextItemIndex)
                let nextEndTime = 0
                if (nextLineView === undefined) {
                    nextEndTime = endTime
                } else {
                    nextEndTime = nextLineView.getLyric().beginTime
                }
                if (position >= beginTime && position < nextEndTime && this.focusIndex != nextItemIndex) {
                    this.changeFocusLine(nextLineView, nextItemIndex)
                    break
                }
            }
        }
    }

    private changeFocusLine(focusLine: LrcLineView | undefined, focusIndex: number) {
        if (this.focusView) {
            this.focusView.stop()
            MediaLogger.d(TAG, this.focusView.getLyric().text + "--unHighlight")
            this.focusView = undefined
        }
        this.focusView = focusLine
        this.focusIndex = focusIndex
        MediaLogger.d(TAG, this.focusView?.getLyric().text + "--highlight")
        if (!this.isUserMoving) {
            const centerScrollIndex = focusIndex
            this.scroller.scrollToIndex(centerScrollIndex, true)
        }
    }
}