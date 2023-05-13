import { LyricLineWrapper } from '../bean/LyricLineWrapper';
import { printD, printW } from '../extensions/Extension';
import animator, { AnimatorResult } from '@ohos.animator';
import { LyricConfig } from './LyricConfig';
import { Lyric } from '../bean/Lyric';

/**
 * A component to display the lyric with scroll animation.
 *
 * The custom setter include the lyric text style, fade style of edge, the line space, scroll animation duration,
 * the cache size to draw out of screen.
 */
@Component
export struct LyricView {
    /**
     * The lyricConfig for LyricView.
     */
    lyricConfig: LyricConfig = null
    private lyricLines = new Array<LyricLineWrapper>() // the lyric lines list.
    readonly settings = new RenderingContextSettings(true)
    readonly canvasCtx = new CanvasRenderingContext2D(this.settings) // paint to draw.
    private highLightTextSize = 0
    private highLightDrawOffset = 0
    private w = 0 // the width of this view.
    private h = 0 // the height of this view.
    private centerH = 0
    private centerW = 0
    private scrollY = 0 // the total scroll offset for current timestamp.
    private linearGradientEdge = 150 // the size of linear gradient at top and bottom.
    private targetScrollY = 0 // the target end scrollY of the animation.
    private centerYOffset = 0 // the center y of the lyric view.
    private currentIndex = 0 // the focused index of the lyric line list.
    private firstVisibleIndex = 0 // the first visible item index at top.
    private lastVisibleIndex = 0 // the last visible item index at bottom.
    private topOverOffIndex = -1 // the index of highlight item when has one more item out off the top.
    private anim: AnimatorResult = null
    private isAnimRunning = false
    private isEmpty = false // is no lyric.
    private lyric: Lyric = null // current lyric.
    private onDataChangedListener = (lyric: Lyric) => {
        this.lyric = lyric
        this.initSize()
    }
    private onPositionChangedListener = (mediaPosition: number) => {
        this.onPositionChanged(mediaPosition)
    }

    aboutToAppear() {
        if (this.lyricConfig == null) {
            throw new Error("The lyric lyricConfig is not set!")
        }
        this.lyricConfig.setOnDataChangedListener(this.onDataChangedListener)
        this.lyricConfig.setOnPositionChangedListener(this.onPositionChangedListener)
        this.lyric = this.lyricConfig.getLyric()
        this.highLightTextSize = this.lyricConfig.getTextSize() * this.lyricConfig.getHighlightScale()
        this.highLightDrawOffset = this.lyricConfig.getTextSize() * (this.lyricConfig.getHighlightScale() - 1) / 2
        this.anim = animator.create({
            duration: this.lyricConfig.getAnimationDuration(),
            easing: "ease-in-out",
            delay: 0,
            fill: "forwards",
            direction: "normal",
            iterations: 1,
            begin: this.scrollY,
            end: this.targetScrollY
        })
        this.anim.oncancel = () => {
            this.isAnimRunning = false
        }
        this.anim.onfinish = () => {
            this.isAnimRunning = false
        }
        this.anim.onframe = (value) => {
            this.scrollY = value
            this.invalidate()
        }
    }

    private downY = 0

    build() {
        Canvas(this.canvasCtx)
            .onAreaChange((_, newSize) => {
                this.w = newSize.width as number
                this.h = newSize.height as number
                printD("onSizeChanged: canvas size= " + this.w + " * " + this.h)
                this.centerW = this.w / 2
                this.centerH = this.h / 2
                this.initPaint()
                this.initSize()
            })
            .width("100%")
            .height("100%")
            .onTouch((event) => {
                if (this.isEmpty) {
                    return
                }
                let touchEvent = event.touches[0]
                switch (touchEvent.type) {
                    case TouchType.Down:
                        printD("---down")
                        this.downY = touchEvent.screenY
                        break
                    case TouchType.Move:
                        printD("---move")
                        let currentY = touchEvent.screenY
                        let dy = currentY - this.downY
                        this.scrollY += dy
                        this.invalidate()
                        this.downY = currentY
                        break
                }
            })
    }

    private initPaint() {
        this.canvasCtx.fillStyle = this.lyricConfig.getTextColor()
        this.canvasCtx.strokeStyle = this.lyricConfig.getTextColor()
        this.canvasCtx.lineWidth = 1
        this.canvasCtx.font = this.lyricConfig.getTextSize() + "px"
        // TODO: the center textAlign has bugs when multi line in OpenHarmony 3.2
        // this.canvasCtx.textAlign = "center"
    }

    private initSize() {
        // reset state
        this.currentIndex = 0
        this.lyricLines = []
        this.isEmpty = this.lyric == null || this.lyric.lyricList.length <= 0
        // no lyric, draw empty hint
        if (this.isEmpty) {
            this.invalidate()
            return
        }
        this.scrollY = this.h / 2 // layout from center when first display
        let tempH = 0
        let list = this.lyric.lyricList
        for (let i = 0;i < list.length; i++) {
            let lrc = list[i]
            let textMeasure = this.canvasCtx.measureText(lrc.text)
            let lp = textMeasure.width / this.w
            let lines = lp
            if (textMeasure.width % this.w != 0) {
                lines = lp < 1 ? 1 : Math.floor(lp) + 1
            }
            let lineHeight = lines * textMeasure.height
            if (i == 0) {
                tempH = Math.round(textMeasure.height / 2)
                this.centerYOffset = tempH
            }
            if (tempH < this.h / 2) {
                tempH += lineHeight + this.lyricConfig.getLineSpace()
            } else {
                if (this.topOverOffIndex == -1) {
                    this.topOverOffIndex = i - 1 // if current index is topOverOffIndex, top off screen
                    printW("init: topOverIndex= " + this.topOverOffIndex)
                }
            }
            this.lyricLines.push(new LyricLineWrapper(lrc, lineHeight))
        }
        this.firstVisibleIndex = this.getFirstVisibleIndex(this.currentIndex)
        this.lastVisibleIndex = this.getLastVisibleIndex(this.currentIndex)
        this.invalidate()
    }

    private invalidate() {
        // clear canvas
        this.canvasCtx.clearRect(0, 0, this.w, this.h)
        if (!this.isEmpty) {
            // TODO: handle touch event, & draw center line
            // this.drawCenterLine()
            // draw lrc text
            this.drawLrc()
            this.drawEdge()
        } else {
            this.drawEmpty()
        }
    }

    private drawEmpty() {
        let hint = this.lyricConfig.getEmptyHint()
        this.canvasCtx.fillText(hint, 0, this.centerH)
    }

    private drawCenterLine() {
        this.canvasCtx.beginPath()
        this.canvasCtx.moveTo(0, this.centerH)
        this.canvasCtx.lineTo(this.w, this.centerH)
        this.canvasCtx.stroke()
    }

    private drawLrc() {
        let startY = this.centerYOffset // half of the first line measure text height
        this.canvasCtx.save()
        this.canvasCtx.translate(0, this.scrollY)
        // the draw count is the max visible lines in screen + 4 caches(2 top & 2 bottom)
        for (let i = 0;i < this.lyricLines.length; i++) {
            let lrc = this.lyricLines[i]
            // out the top of screen, the default cache is 2 lines
            if (i < this.firstVisibleIndex - this.lyricConfig.getCacheSize()) {
                startY += (lrc.height + this.lyricConfig.getLineSpace())
                continue
            }
            // out the bottom of screen, the default cache is 2 lines
            if (i > this.lastVisibleIndex + this.lyricConfig.getCacheSize()) {
                break
            }
            // draw with high light for current line
            if (i == this.currentIndex) {
                let scaleHeight = this.drawHighLight(lrc, startY)
                startY += (scaleHeight + this.lyricConfig.getLineSpace() + this.highLightDrawOffset)
            } else {
                this.canvasCtx.fillText(lrc.text, 0, startY)
                startY += (lrc.height + this.lyricConfig.getLineSpace())
            }
        }
        this.canvasCtx.restore()
    }

    private drawHighLight(lrc: LyricLineWrapper, startY: number): number {
        this.canvasCtx.save()
        this.canvasCtx.font = this.lyricConfig.getHighlightStyle() ?
            this.highLightTextSize + "px" + " bold" : this.highLightTextSize + "px"
        this.canvasCtx.fillStyle = this.lyricConfig.getHighlightColor()
        this.canvasCtx.fillText(lrc.text, 0, startY + this.highLightDrawOffset)
        let textMeasure = this.canvasCtx.measureText(lrc.text)
        let height = Math.round(textMeasure.height)
        let lp = textMeasure.width / this.w
        let lines = lp
        if (textMeasure.width % this.w != 0) {
            lines = lp < 1 ? 1 : Math.floor(lp) + 1
        }
        let scaleHeight = height * lines
        this.canvasCtx.restore()
        return scaleHeight
    }

    private drawEdge() {
        this.canvasCtx.save()
        let topFade = this.canvasCtx.createLinearGradient(this.centerW, 0, this.centerW, this.linearGradientEdge)
        topFade.addColorStop(0.0, this.lyricConfig.getEdgeColor())
        topFade.addColorStop(1.0, '#00ffffff')
        this.canvasCtx.fillStyle = topFade
        this.canvasCtx.fillRect(0, 0, this.w, this.linearGradientEdge)
        let bottomFade = this.canvasCtx.createLinearGradient(this.centerW, this.h, this.centerW, this.h - this.linearGradientEdge)
        bottomFade.addColorStop(0.0, this.lyricConfig.getEdgeColor())
        bottomFade.addColorStop(1.0, '#00ffffff')
        this.canvasCtx.fillStyle = bottomFade
        this.canvasCtx.fillRect(0, this.h - this.linearGradientEdge, this.w, this.linearGradientEdge)
        this.canvasCtx.restore()
    }

    private getIndex(position: number): number {
        let first = this.lyricLines[0].beginTime
        if (position < first) {
            return 0
        }
        let last = this.lyricLines[this.lyricLines.length - 1].beginTime
        if (position > last) {
            return this.lyricLines.length - 1
        }
        for (let i = 0; i < this.lyricLines.length - 1; i++) {
            let line = this.lyricLines[i]
            if (position >= line.beginTime && position < line.nextTime) {
                return i
            }
        }
        return this.currentIndex
    }

    private getFirstVisibleIndex(index: number): number {
        if (index > this.topOverOffIndex) {
            let tempH = 0
            for (let i = index;i > 0; i--) {
                let lrc = this.lyricLines[i]
                tempH += (lrc.height + this.lyricConfig.getLineSpace())
                if (tempH > this.centerH) {
                    return i
                }
            }
        } else {
            return 0
        }
    }

    private getLastVisibleIndex(index: number): number {
        let tempH = 0
        for (let i = index;i < this.lyricLines.length; i++) {
            let lrc = this.lyricLines[i]
            tempH += (lrc.height + this.lyricConfig.getLineSpace())
            if (tempH > this.centerH) {
                return i
            }
        }
        return this.lyricLines.length - 1
    }

    private animateToIndex(index: number) {
        printD("animate to index= " + index)
        if (index == this.currentIndex) {
            printD("index not changed, not animate!")
            return
        }
        // out of range, return
        if (index > this.lyricLines.length - 1 || index < 0) {
            printD("out of range, not animate!")
            return
        }
        this.firstVisibleIndex = this.getFirstVisibleIndex(index)
        this.lastVisibleIndex = this.getLastVisibleIndex(index)
        let animOffset = 0
        let isUp = index > this.currentIndex
        if (isUp) { // to next
            for (let i = this.currentIndex;i < index; i++) {
                let lrcH = this.lyricLines[i].height
                animOffset += lrcH + this.lyricConfig.getLineSpace()
            }
        } else { // to pre
            for (let i = index;i < this.currentIndex; i++) {
                let lrcH = this.lyricLines[i].height
                animOffset += lrcH + this.lyricConfig.getLineSpace()
            }
        }
        this.currentIndex = index
        printD("firstVisible= " + this.firstVisibleIndex + ", lastVisible= " + this.lastVisibleIndex + ", currentHighLight= " + this.currentIndex)
        // the animation is running, end it
        if (this.isAnimRunning) {
            this.anim.cancel()
            this.scrollY = this.targetScrollY
            this.invalidate()
            printW("intercept and end anim!")
        }
        // at end, stop scroll
        if (this.currentIndex > this.lyricLines.length - 1) {
            return
        }
        // get the offset of one frame
        this.targetScrollY = Math.round(isUp ? this.scrollY - animOffset : this.scrollY + animOffset)
        // start animate
        let startY = this.scrollY
        printD(">>start anim " + startY + " -> " + this.targetScrollY)
        this.anim.reset({
            duration: this.lyricConfig.getAnimationDuration(),
            easing: "ease-in-out",
            delay: 0,
            fill: "forwards",
            direction: "normal",
            iterations: 1,
            begin: startY,
            end: this.targetScrollY
        })
        this.anim.play()
        this.isAnimRunning = true
    }

    private onPositionChanged(mediaPosition: number) {
        if (this.isEmpty) {
            return
        }
        let index = this.getIndex(mediaPosition)
        if (index != this.currentIndex) {
            this.animateToIndex(index)
        }

    }
}