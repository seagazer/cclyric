import { LyricWrapper } from '../bean/LyricLineWrapper';
import { printD, printW } from '../extensions/Extension';
import animator, { AnimatorResult } from '@ohos.animator';
import { LyricConfig } from './LyricConfig';

/**
 * A component to display the lyric with scroll animation.
 *
 * The custom setter include the lyric text style, fade style of edge, the line space, scroll animation duration,
 * the cache size to draw out of screen.
 */
@Component
export struct LyricView {
    /*------------------------------setter----------------------------------*/
    config: LyricConfig
    @Watch("onProgressChanged") @Link currentPosition: number
    /*----------------------------------------------------------------------*/
    private extLrcList = new Array<LyricWrapper>()
    readonly settings = new RenderingContextSettings(true)
    readonly canvasCtx = new CanvasRenderingContext2D(this.settings)
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
    private anim: AnimatorResult
    private isAnimRunning = false
    private isEmpty = false
    private onDataChangedListener = () => {
        this.initSize()
    }

    aboutToAppear() {
        this.config.setOnDataChangedListener(this.onDataChangedListener)
        this.highLightTextSize = this.config.getTextSize() * this.config.getHighlightScale()
        this.highLightDrawOffset = this.config.getTextSize() * (this.config.getHighlightScale() - 1) / 2
        this.anim = animator.create({
            duration: this.config.getAnimationDuration(),
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
    }

    build() {
        Canvas(this.canvasCtx)
            .onAreaChange((_, newSize) => {
                this.w = newSize.width as number
                this.h = newSize.height as number
                printD("onSizeChanged: canvas size = " + this.w + " * " + this.h)
                this.centerW = this.w / 2
                this.centerH = this.h / 2
                this.initPaint()
                this.initSize()
            })
            .width("100%")
            .height("100%")
    }

    private initPaint() {
        this.canvasCtx.fillStyle = this.config.getTextColor()
        this.canvasCtx.strokeStyle = this.config.getTextColor()
        this.canvasCtx.lineWidth = 1
        this.canvasCtx.font = this.config.getTextSize() + "px"
        // TODO: the center textAlign has bugs when multi line in OpenHarmony 3.2
        // this.canvasCtx.textAlign = "center"
    }

    private initSize() {
        // reset state
        this.currentIndex = 0
        this.currentPosition = 0
        this.extLrcList = []
        this.scrollY = this.h / 2 // layout center when first display
        let tempH = 0
        let list = this.config.getLyric().lyricList
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
                tempH += lineHeight + this.config.getLineSpace()
            } else {
                if (this.topOverOffIndex == -1) {
                    this.topOverOffIndex = i - 1 // if current index is topOverOffIndex, top off screen
                    printW("init topOverIndex = " + this.topOverOffIndex)
                }
            }
            this.extLrcList.push(new LyricWrapper(lrc, lineHeight))
        }
        this.firstVisibleIndex = this.getFirstVisibleIndex(this.currentIndex)
        this.lastVisibleIndex = this.getLastVisibleIndex(this.currentIndex)
        this.invalidate()
    }

    private invalidate() {
        if (!this.isEmpty) {
            // clear canvas
            this.canvasCtx.clearRect(0, 0, this.w, this.h)
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
        let hint = this.config.getEmptyHint()
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
        for (let i = 0;i < this.extLrcList.length; i++) {
            let lrc = this.extLrcList[i]
            // out the top of screen, the default cache is 2 lines
            if (i < this.firstVisibleIndex - this.config.getCacheSize()) {
                startY += (lrc.height + this.config.getLineSpace())
                continue
            }
            // out the bottom of screen, the default cache is 2 lines
            if (i > this.lastVisibleIndex + this.config.getCacheSize()) {
                break
            }
            // draw with high light for current line
            if (i == this.currentIndex) {
                let scaleHeight = this.drawHighLight(lrc, startY)
                startY += (scaleHeight + this.config.getLineSpace() + this.highLightDrawOffset)
            } else {
                this.canvasCtx.fillText(lrc.text, 0, startY)
                startY += (lrc.height + this.config.getLineSpace())
            }
        }
        this.canvasCtx.restore()
    }

    private drawHighLight(lrc: LyricWrapper, startY: number): number {
        this.canvasCtx.save()
        this.canvasCtx.font = this.config.getHighlightStyle() ?
            this.highLightTextSize + "px" + " bold" : this.highLightTextSize + "px"
        this.canvasCtx.fillStyle = this.config.getHighlightColor()
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
        topFade.addColorStop(0.0, this.config.getEdgeColor())
        topFade.addColorStop(1.0, '#00ffffff')
        this.canvasCtx.fillStyle = topFade
        this.canvasCtx.fillRect(0, 0, this.w, this.linearGradientEdge)
        let bottomFade = this.canvasCtx.createLinearGradient(this.centerW, this.h, this.centerW, this.h - this.linearGradientEdge)
        bottomFade.addColorStop(0.0, this.config.getEdgeColor())
        bottomFade.addColorStop(1.0, '#00ffffff')
        this.canvasCtx.fillStyle = bottomFade
        this.canvasCtx.fillRect(0, this.h - this.linearGradientEdge, this.w, this.linearGradientEdge)
        this.canvasCtx.restore()
    }

    private getIndex(position: number): number {
        let first = this.extLrcList[0].timestamp
        if (position < first) {
            return 0
        }
        let last = this.extLrcList[this.extLrcList.length - 1].timestamp
        if (position > last) {
            return this.extLrcList.length - 1
        }
        for (let i = 0; i < this.extLrcList.length - 1; i++) {
            let l1 = this.extLrcList[i].timestamp
            let l2 = this.extLrcList[i+1].timestamp
            if (position > l1 && position < l2) {
                return i
            }
        }
        return this.currentIndex
    }

    private getFirstVisibleIndex(index: number): number {
        if (index > this.topOverOffIndex) {
            let tempH = 0
            for (let i = index;i > 0; i--) {
                let lrc = this.extLrcList[i]
                tempH += (lrc.height + this.config.getLineSpace())
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
        for (let i = index;i < this.extLrcList.length; i++) {
            let lrc = this.extLrcList[i]
            tempH += (lrc.height + this.config.getLineSpace())
            if (tempH > this.centerH) {
                return i
            }
        }
        return this.extLrcList.length - 1
    }

    private animateToIndex(index: number) {
        printD("animate to index=" + index)
        if (index == this.currentIndex) {
            printD("index not changed, not animate!")
            return
        }
        // out of range, return
        if (index > this.extLrcList.length - 1 || index < 0) {
            printD("out of range, not animate!")
            return
        }
        this.firstVisibleIndex = this.getFirstVisibleIndex(index)
        this.lastVisibleIndex = this.getLastVisibleIndex(index)
        let animOffset = 0
        let isUp = index > this.currentIndex
        if (isUp) { // to next
            for (let i = this.currentIndex;i < index; i++) {
                let lrcH = this.extLrcList[i].height
                animOffset += lrcH + this.config.getLineSpace()
            }
        } else { // to pre
            for (let i = index;i < this.currentIndex; i++) {
                let lrcH = this.extLrcList[i].height
                animOffset += lrcH + this.config.getLineSpace()
            }
        }
        this.currentIndex = index
        printD("firstTop=" + this.firstVisibleIndex + ", lastBottom=" + this.lastVisibleIndex + ", currentHighLight=" + this.currentIndex)
        // the animation is running, end it
        if (this.isAnimRunning) {
            this.anim.cancel()
            this.scrollY = this.targetScrollY
            this.invalidate()
            printW("intercept and end anim!")
        }
        // at end, stop scroll
        if (this.currentIndex > this.extLrcList.length - 1) {
            return
        }
        printD(">>start anim")
        // get the offset of one frame
        this.targetScrollY = Math.round(isUp ? this.scrollY - animOffset : this.scrollY + animOffset)
        // start animate
        let startY = this.scrollY
        printD(">>start anim " + startY + " -> " + this.targetScrollY)
        this.anim.reset({
            duration: this.config.getAnimationDuration(),
            easing: "ease-in-out",
            delay: 0,
            fill: "forwards",
            direction: "normal",
            iterations: 1,
            begin: startY,
            end: this.targetScrollY
        })
        this.anim.onframe = (value) => {
            this.scrollY = value
            this.invalidate()
        }
        this.anim.play()
        this.isAnimRunning = true
    }

    private onProgressChanged() {
        if (this.isEmpty) {
            return
        }
        let index = this.getIndex(this.currentPosition)
        if (index != this.currentIndex) {
            printD("next line=" + index)
            this.animateToIndex(index)
        }

    }
}