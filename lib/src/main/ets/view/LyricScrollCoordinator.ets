import { LrcLine } from '../bean/LrcLine'
import { LrcLineView } from './LrcLineView'
import { LyricTimelineItem } from '../bean/LyricTimelineItem'

export class LyricScrollCoordinator {
    private focusView?: LrcLineView
    private readonly scroller = new Scroller()
    private isUserMoving = false
    private userMoveTimeout = -1
    private focusIndex = -1
    private centerLrcLine?: LrcLine = undefined

    bindScroller(): Scroller {
        return this.scroller
    }

    getFocusIndex(): number {
        return this.focusIndex
    }

    getCenterLine(): LrcLine | undefined {
        return this.centerLrcLine
    }

    setUserMoving(userMoving: boolean) {
        this.isUserMoving = userMoving
    }

    getUserMoving(): boolean {
        return this.isUserMoving
    }

    clearRecoverTimer() {
        clearTimeout(this.userMoveTimeout)
    }

    reset() {
        this.clearRecoverTimer()
        this.isUserMoving = false
        this.focusIndex = -1
        this.centerLrcLine = undefined
        if (this.focusView !== undefined) {
            this.focusView.stop()
            this.focusView = undefined
        }
    }

    onScrollIndex(items: LyricTimelineItem[], center: number, onScrollChanged?: (centerLine: LrcLine | undefined) => void) {
        if (center < 0 || center >= items.length) {
            return
        }
        const item = items[center]
        if (item === undefined) {
            return
        }
        const curCenter = item.displayLine.line
        if (this.centerLrcLine !== curCenter) {
            this.centerLrcLine = curCenter
            onScrollChanged?.(this.centerLrcLine)
        }
    }

    onScrollStart(onScrollStateChanged?: (scrolling: boolean) => void) {
        onScrollStateChanged?.(true)
    }

    onScrollStop(delay: number, onScrollStateChanged?: (scrolling: boolean) => void) {
        this.clearRecoverTimer()
        this.userMoveTimeout = setTimeout(() => {
            this.isUserMoving = false
            onScrollStateChanged?.(false)
        }, delay)
    }

    onTouchDown(onScrollStateChanged?: (scrolling: boolean) => void) {
        this.clearRecoverTimer()
        this.isUserMoving = true
        onScrollStateChanged?.(true)
    }

    onTouchEnd(delay: number, supportSeek: boolean, onScrollStateChanged?: (scrolling: boolean) => void) {
        this.clearRecoverTimer()
        if (supportSeek) {
            this.userMoveTimeout = setTimeout(() => {
                this.isUserMoving = false
                onScrollStateChanged?.(false)
            }, delay)
            return
        }
        this.isUserMoving = false
        onScrollStateChanged?.(false)
    }

    resolveFocusIndex(items: LyricTimelineItem[], position: number): number {
        if (items.length <= 0) {
            return -1
        }
        if (position < items[0].beginTime) {
            return 0
        }
        const lastIndex = items.length - 1
        if (position >= items[lastIndex].endTime) {
            return lastIndex
        }
        let left = 0
        let right = lastIndex
        while (left <= right) {
            const mid = Math.floor((left + right) / 2)
            const item = items[mid]
            if (position < item.beginTime) {
                right = mid - 1
                continue
            }
            if (position >= item.endTime) {
                left = mid + 1
                continue
            }
            return mid
        }
        return Math.min(Math.max(left, 0), lastIndex)
    }

    changeFocusLine(focusLine: LrcLineView | undefined, focusIndex: number, onNeedScroll?: (index: number) => void) {
        const previousFocusIndex = this.focusIndex
        if (this.focusView) {
            this.focusView.stop()
            this.focusView = undefined
        }
        this.focusView = focusLine
        this.focusView?.markHighlight()
        this.focusIndex = focusIndex
        if (!this.isUserMoving && previousFocusIndex !== focusIndex) {
            onNeedScroll?.(focusIndex)
        }
    }
}
