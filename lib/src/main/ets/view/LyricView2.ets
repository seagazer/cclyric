import { duration2text, printD, printW } from '../extensions/Extension';
import { LyricController } from '../LyricController';
import { Lyric } from '../bean/Lyric';
import { ListAdapter } from '../extensions/ListAdapter';
import { LyricLine } from '../bean/LyricLine';

/**
 * A component to display the lyric with scroll animation.
 * This component only support api 10+.
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
    /**
     * Enable the lyric scroll to do seek action or not.
     * If false, the onSeekAction callback will not invoke anymore.
     */
    enableSeek: boolean = true
    /**
     * The color of seek button and duration text.
     */
    seekUIColor: ResourceColor = '#000000'
    /**
     * The color of the seek location line.
     */
    seekLineColor: ResourceColor = '#0d000000'
    /**
     * The seek ui style.
     */
    seekUIStyle: 'seekLine' | 'listItem' = 'listItem'
    /**
     * The seek callback for scroll the lyric.
     * If return true, you must handle this action to do seek action of media player.
     * If return false, the lyric view will scroll to current index of the media playing position.
     */
    onSeekAction: (position: number) => boolean = () => false
    private currentLyric: Lyric | null = null
    private scroller = new Scroller()
    private listAdapter = new ListAdapter<LyricLine>()
    private w = 0 // the width of this view.
    private h = 0 // the height of this view.
    @State currentIndex: number = 0 // the focused index of the lyric line list.
    @State isLyricEmpty: boolean = true // is no lyric.
    @State textSize: number = 16
    @State lineSpace: number = 16
    @State textHighlightSize: number = 18
    @State textColor: string = '#000000'
    @State textHighlightColor: string = '#000000'
    @State isHighlightBold: boolean = false
    @State alignMode: 'left' | 'center' = 'center'
    @State emptyHint: string = ''
    @State cacheSize: number = 0
    @State animDuration: number = 300
    @State isUserTouching: boolean = false
    private centerOffsetSize: number = 0
    // seek action: center line view
    @State seekPosition: number = -1
    @State scrollDurationText: string = '00:00'
    @State seekIndex: number = -1
    private seekUiHideTimeout = -1
    private autoHideSeekUIDuration = 2000
    @State isLoadingData: boolean = false
    private loadTimeout = -1
    private onDataChangedListener = (lyric: Lyric | null) => {
        clearTimeout(this.loadTimeout)
        this.isLoadingData = true
        this.loadData(lyric)
        this.loadTimeout = setTimeout(() => {
            this.isLoadingData = false
        }, 300)
    }
    private onPositionChangedListener = (mediaPosition: number) => {
        this.onPositionChanged(mediaPosition)
    }
    private onInvalidatedListener = (reLayout: boolean) => {
        this.getAttrFromController()
        if (reLayout && this.currentIndex > 0) {
            this.animateToIndex(this.currentIndex)
        }
    }

    private loadData(lyric: Lyric | null) {
        this.currentLyric = lyric
        if (this.w > 0 && this.h > 0) {
            if (this.currentLyric) {
                this.listAdapter.clear(false)
                let lyricLines = this.currentLyric.lyricList
                let first = lyricLines[0].beginTime
                // fill the top empty gap
                for (let i = 0; i < this.centerOffsetSize; i++) {
                    this.listAdapter.addData(new LyricLine(' ', 0, first), false)
                }
                lyricLines.forEach((line) => {
                    this.listAdapter.addData(line, false)
                })
                // fill the bottom empty gap
                let last = lyricLines[lyricLines.length - 1].nextTime
                for (let i = 0; i < this.centerOffsetSize; i++) {
                    this.listAdapter.addData(new LyricLine(' ', last + i, last + i), false)
                }
                this.listAdapter.notifyDataReload()
            } else {
                this.listAdapter.clear(true)
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
        this.isHighlightBold = this.controller.isHighlightBold()
        this.animDuration = this.controller.getAnimationDuration()
        this.cacheSize = this.controller.getCacheSize()
        this.emptyHint = this.controller.getEmptyHint()
        this.alignMode = this.controller.getAlignMode()
    }

    aboutToAppear() {
        if (this.controller == null) {
            throw new Error('The lyric lyricConfig is not set!')
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
        List({ space: this.lineSpace - 16, scroller: this.scroller }) {
            LazyForEach(this.listAdapter, (item: LyricLine, index: number) => {
                ListItem() {
                    Stack() {
                        Text(item.text)
                            .width('100%')
                            .textAlign(this.alignMode == 'center' ? TextAlign.Center : TextAlign.Start)
                            .scale({
                                x: index == this.currentIndex ? this.controller.getHighlightScale() : 1,
                                y: index == this.currentIndex ? this.controller.getHighlightScale() : 1,
                                centerX: this.alignMode == 'center' ? '50%' : 0
                            })
                            .fontColor(index == this.currentIndex ? this.textHighlightColor : this.textColor)
                            .fontWeight(index == this.currentIndex && this.isHighlightBold ? FontWeight.Bold :
                            FontWeight.Normal)// .padding({
                            .animation({ duration: this.animDuration, curve: Curve.FastOutSlowIn })
                            .width('100%')

                        if (this.seekUIStyle == 'listItem' && index == this.seekIndex && item.text.length > 0
                            && this.enableSeek && this.isUserTouching) {
                            // Row() {
                            //     Image($r('app.media.cclyric_play'))
                            //         .width(24)
                            //         .height(24)
                            //         .fillColor(this.seekUIColor)
                            //         .objectFit(ImageFit.Fill)
                            Text(this.scrollDurationText)
                                .fontSize(this.textSize)
                                .fontColor(this.seekUIColor)
                            // }.width('100%')
                            // .justifyContent(FlexAlign.SpaceBetween)
                        }
                    }.align(Alignment.End)
                }
                .padding(8)
                .border({ radius: 4 })
                .backgroundColor(this.seekUIStyle == 'listItem' && index == this.seekIndex && item.text.length > 0
                    && this.enableSeek && this.isUserTouching ? '#80a9a9a9' : '#00000000')
                .onClick(() => {
                    if (this.seekUIStyle == 'listItem' && index == this.seekIndex && item.text.length > 0) {
                        if (this.seekIndex != -1 && this.seekIndex != this.currentIndex) {
                            this.handleSeekAction();
                        }
                    }
                })
            },
                (item: LyricLine, index: number) => {
                    return item.text + '_' + index + '_' + item.beginTime + '_' + item.nextTime
                })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .cachedCount(this.cacheSize)
        .visibility(this.isLoadingData ? Visibility.Hidden : Visibility.Visible)
        .onScrollIndex((_, __, center) => {
            if (this.isUserTouching) {
                this.seekIndex = center
                let targetPosition = this.listAdapter.getData(center).beginTime
                this.scrollDurationText = duration2text(targetPosition)
            }
        })
        .onTouch((event) => {
            let motion = event.touches[0]
            switch (motion.type) {
                case TouchType.Down:
                    clearTimeout(this.seekUiHideTimeout)
                    break
                case TouchType.Move:
                    this.isUserTouching = true
                    break
                case TouchType.Up:
                case TouchType.Cancel:
                    this.seekUiHideTimeout = setTimeout(() => {
                        this.seekIndex = -1
                        this.isUserTouching = false
                        this.animateToIndex(this.currentIndex)
                    }, this.autoHideSeekUIDuration)
            }
        })
    }

    private handleSeekAction() {
        clearTimeout(this.seekUiHideTimeout);
        let targetPosition = this.listAdapter.getData(this.seekIndex).beginTime;
        let isPlayerHandled = this.onSeekAction(targetPosition);
        if (!isPlayerHandled) {
            this.animateToIndex(this.currentIndex);
        }
        this.isUserTouching = false;
    }

    @Builder
    SeekLine() {
        Row() {
            Image($r('app.media.cclyric_play'))
                .width(24)
                .height(24)
                .fillColor(this.seekUIColor)
                .objectFit(ImageFit.Fill)
                .clickEffect({ level: ClickEffectLevel.MIDDLE })
                .onClick(() => {
                    if (this.seekIndex != -1 && this.seekIndex != this.currentIndex) {
                        this.handleSeekAction()
                    }
                })
            Stack()
                .height(1)
                .layoutWeight(1)
                .backgroundColor(this.seekLineColor)
                .margin({ left: 8, right: 8 })
            Text(this.scrollDurationText)
                .fontSize(this.textSize)
                .fontColor(this.seekUIColor)
        }
        .visibility(this.enableSeek && this.isUserTouching ? Visibility.Visible : Visibility.Hidden)
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.Transparent)
        .transition(TransitionEffect.OPACITY.animation({ duration: this.animDuration }))
    }

    build() {
        Stack() {
            if (this.isLyricEmpty) {
                this.EmptyView()
            } else {
                this.LyricListView()
            }
            if (this.seekUIStyle == 'seekLine') {
                this.SeekLine()
            }
        }
        .width('100%')
        .height('100%')
        .onAreaChange((_, newSize) => {
            printW('onSizeChanged: ' + JSON.stringify(newSize))
            this.h = newSize.height as number
            this.w = newSize.width as number
            let lineH = this.textSize + this.lineSpace
            this.centerOffsetSize = Math.floor((this.h - lineH) / 2 / lineH)
            printW('offsetSize = ' + this.centerOffsetSize)
            if (this.currentLyric) {
                this.loadData(this.currentLyric)
            }
        })
    }

    aboutToDisappear() {
        clearTimeout(this.loadTimeout)
        clearTimeout(this.seekUiHideTimeout)
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

    private animateToIndex(index: number) {
        printD('animate to index= ' + index)
        this.currentIndex = index
        if (this.isUserTouching) {
            return
        }
        this.scroller.scrollToIndex(index, true, ScrollAlign.CENTER)
    }

    private onPositionChanged(mediaPosition: number) {
        if (this.isLyricEmpty) {
            printW('The lyric data is empty!')
            return
        }
        if (this.listAdapter.isEmpty()) {
            printW('The lyric lines is empty!')
            return
        }
        let index = this.getIndex(mediaPosition)
        if (index != this.currentIndex) {
            this.animateToIndex(index)
        }
    }
}