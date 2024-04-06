import { printD, printW } from '../extensions/Extension';
import { LyricController } from './LyricController';
import { Lyric } from '../bean/Lyric';
import { ListAdapter } from '../extensions/ListAdapter';
import { LyricLine } from '../bean/LyricLine';

/**
 * A component to display the lyric with scroll animation.
 *
 * The custom setter include the lyric text style, fade style of edge, the line space, scroll animation duration,
 * the cache size to draw out of screen.
 */
@Component
export struct LyricView2 {
    /**
     * The lyricConfig for LyricView.
     */
    controller: LyricController = new LyricController()
    private currentLyric: Lyric | null = null
    private scroller = new Scroller()
    private listAdapter = new ListAdapter<LyricLine>()
    private h = 0 // the height of this view.
    private linearGradientEdge = 150 // the size of linear gradient at top and bottom.
    @State currentIndex: number = 0 // the focused index of the lyric line list.
    @State isLyricEmpty: boolean = true // is no lyric.
    @State textSize: number = 16
    @State lineSpace: number = 16
    @State textHighlightSize: number = 18
    @State textColor: string = '#000000'
    @State textHighlightColor: string = '#000000'
    @State isHighlightBold: boolean = false
    @State alignMode: "left" | "center" = 'center'
    @State emptyHint: string = ''
    @State cacheSize: number = 0
    @State animDuration: number = 300
    private offsetSize: number = 0
    private onDataChangedListener = (lyric: Lyric) => {
        this.loadData(lyric)
    }
    private onPositionChangedListener = (mediaPosition: number) => {
        this.onPositionChanged(mediaPosition)
    }
    private onInvalidatedListener = (reLayout: boolean) => {
        this.getAttrFromController()
        if (reLayout && this.currentIndex > 0) {
            this.animateToIndex(this.currentIndex, true)
        }
    }

    private loadData(lyric: Lyric) {
        this.currentLyric = lyric
        if (this.h > 0 && this.currentLyric) {
            this.listAdapter.clear()
            let lyricLines = lyric.lyricList
            let first = lyricLines[0].beginTime
            for (let i = 0; i < this.offsetSize; i++) {
                this.listAdapter.addData(new LyricLine(' ', 0, first))
            }
            lyricLines.forEach((line) => {
                this.listAdapter.addData(line)
            })
            let last = lyricLines[lyricLines.length-1].nextTime
            for (let i = 0; i < this.offsetSize; i++) {
                this.listAdapter.addData(new LyricLine(' ', last + i, last + i))
            }
        }
        this.isLyricEmpty = this.listAdapter.isEmpty()
        this.currentIndex = 0
        this.animateToIndex(0)
        printW('loadData isEmpty = ' + this.isLyricEmpty)
    }

    private getAttrFromController() {
        this.currentLyric = this.controller.getLyric()
        this.textSize = this.controller.getTextSize()
        this.lineSpace = this.controller.getLineSpace()
        this.textColor = this.controller.getTextColor()
        this.textHighlightColor = this.controller.getHighlightColor()
        this.textHighlightSize = this.controller.getHighlightScale() * this.textSize
        this.isHighlightBold = this.controller.getHighlightStyle()
        this.animDuration = this.controller.getAnimationDuration()
        this.cacheSize = this.controller.getCacheSize()
        this.emptyHint = this.controller.getEmptyHint()
        this.alignMode = this.controller.getAlignMode()
    }

    aboutToAppear() {
        if (this.controller == null) {
            throw new Error("The lyric lyricConfig is not set!")
        }
        this.controller.onDataChangedListener = this.onDataChangedListener
        this.controller.onPositionChangedListener = this.onPositionChangedListener
        this.controller.onInvalidated = this.onInvalidatedListener
        this.getAttrFromController()
    }

    @Builder
    EmptyView() {
        Text(this.emptyHint)
            .fontSize(this.textSize)
            .fontColor(this.textColor)
    }

    @Builder
    LyricListView() {
        List({ space: this.lineSpace, scroller: this.scroller }) {
            LazyForEach(this.listAdapter,
                (item: LyricLine, index: number) => {
                    ListItem() {
                        Text(item.text)
                            .width('100%')
                            .textAlign(this.alignMode == 'center' ? TextAlign.Center : TextAlign.Start)
                            .fontSize(index == this.currentIndex ? this.textHighlightSize : this.textSize)
                            .fontColor(index == this.currentIndex ? this.textHighlightColor : this.textColor)
                            .fontWeight(index == this.currentIndex && this.isHighlightBold ? FontWeight.Bold : FontWeight.Normal)
                            .padding({ left: index == this.currentIndex ? this.textHighlightSize : 0 })
                            .animation({ duration: this.animDuration })
                    }
                },
                (item: LyricLine, index: number) => {
                    return item.text + '_' + index + '_' + item.beginTime + '_' + item.nextTime
                })
        }
        .width('100%')
        .height('100%')
    }

    build() {
        Stack() {
            if (this.isLyricEmpty) {
                this.EmptyView()
            } else {
                this.LyricListView()
            }
        }
        .width('100%')
        .height('100%')
        .onAreaChange((_, newSize) => {
            printW('onSizeChanged: ' + JSON.stringify(newSize))
            this.h = newSize.height as number
            let lineH = this.textSize + this.lineSpace
            this.offsetSize = Math.floor((this.h - lineH) / 2 / lineH)
            printW('offsetSize = ' + this.offsetSize)
            this.loadData(this.currentLyric)
        })

    }

    private getIndex(position: number): number {
        let size = this.listAdapter.totalCount()
        let first = this.listAdapter.getData(0).beginTime
        if (position < first) {
            return 0
        }
        let last = this.listAdapter.getData(size - 1).beginTime
        if (position > last) {
            return size - 1
        }
        for (let i = 0; i < size - 1; i++) {
            let line = this.listAdapter.getData(i)
            if (position >= line.beginTime && position < line.nextTime) {
                return i
            }
        }
        return this.currentIndex
    }

    private animateToIndex(index: number, focusAnimate: boolean = false) {
        printD("animate to index= " + index)
        this.currentIndex = index
        this.scroller.scrollToIndex(index, true, ScrollAlign.CENTER)
    }

    private onPositionChanged(mediaPosition: number) {
        if (this.isLyricEmpty) {
            printW("The lyric data is empty!")
            return
        }
        if (this.listAdapter.isEmpty()) {
            printW("The lyric lines is empty!")
            return
        }
        let index = this.getIndex(mediaPosition)
        if (index != this.currentIndex) {
            this.animateToIndex(index)
        }
    }
}