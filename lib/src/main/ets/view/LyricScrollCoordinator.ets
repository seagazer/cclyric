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
    private validIndexes: number[] = []

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
        this.validIndexes = []
        if (this.focusView !== undefined) {
            this.focusView.stop()
            this.focusView = undefined
        }
    }

    setTimeline(items: LyricTimelineItem[]) {
        this.validIndexes = []
        for (let i = 0; i < items.length; i++) {
            if (items[i].endTime > 0) {
                this.validIndexes.push(i)
            }
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
        // Only lyrics with a real time point (endTime > 0) can be focused.
        // Lines without a time point (e.g. metadata) are skipped.
        const validIndexes = this.validIndexes
        if (validIndexes.length <= 0) {
            return 0
        }
        const firstValidIndex = validIndexes[0]
        if (position < items[firstValidIndex].beginTime) {
            return firstValidIndex
        }
        const lastValidIndex = validIndexes[validIndexes.length - 1]
        if (position >= items[lastValidIndex].endTime) {
            return lastValidIndex
        }
        // Find the last valid item whose beginTime <= position.
        let lo = 0
        let hi = validIndexes.length - 1
        let best = firstValidIndex
        let bestPos = 0
        while (lo <= hi) {
            const mid = Math.floor((lo + hi) / 2)
            const idx = validIndexes[mid]
            if (items[idx].beginTime <= position) {
                best = idx
                bestPos = mid
                lo = mid + 1
            } else {
                hi = mid - 1
            }
        }
        const bestItem = items[best]
        if (position >= bestItem.beginTime && position < bestItem.endTime) {
            return best
        }
        // Position falls in a gap; choose the nearer of the previous and next valid lyrics.
        const nextIndex = validIndexes[bestPos + 1]
        if (nextIndex !== undefined) {
            const nextItem = items[nextIndex]
            const prevDistance = position - bestItem.endTime
            const nextDistance = nextItem.beginTime - position
            return nextDistance < prevDistance ? nextIndex : best
        }
        return best
    }

    changeFocusLine(focusLine: LrcLineView | undefined, focusIndex: number, onNeedScroll?: (index: number) => void) {
        const previousFocusIndex = this.focusIndex
        if (previousFocusIndex === focusIndex && this.focusView === focusLine) {
            this.focusView?.markHighlight()
            return
        }
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
