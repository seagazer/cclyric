import { MediaLogger } from '../extensions/MediaLogger'
import { AnimatorOptions, AnimatorResult } from '@kit.ArkUI'

const TAG = "[AnimatorProvider]"

/**
 *
 * Author: Seagazer
 * Date: 2025/10/8
 */
export class AnimatorProvider {
    private static sInstance?: AnimatorProvider = undefined
    private context: UIContext
    private idlePool: Animator[] = []
    private runningPool: Animator[] = []
    private animationDuration = 250
    private stateChangedListener = (anim: Animator, isRunning: boolean) => {
        if (isRunning) {
            const index = this.idlePool.indexOf(anim)
            if (index >= 0) {
                this.idlePool.splice(index, 1)
            }
            this.runningPool.push(anim)
        } else {
            const index = this.runningPool.indexOf(anim)
            if (index >= 0) {
                this.runningPool.splice(index, 1)
            }
            this.idlePool.push(anim)
        }
        MediaLogger.w(TAG, "StateChanged: idlePool= " + this.idlePool.length + ", runningPool= " + this.runningPool.length)
    }

    private constructor(context: UIContext) {
        this.context = context
    }

    setAnimationDuration(duration: number) {
        this.animationDuration = duration
    }

    static getInstance(context: UIContext): AnimatorProvider {
        if (AnimatorProvider.sInstance === undefined) {
            AnimatorProvider.sInstance = new AnimatorProvider(context)
        }
        return AnimatorProvider.sInstance
    }

    getAnimator(): Animator {
        if (this.idlePool.length <= 0) {
            const animation = this.context.createAnimator({
                duration: 100,
                delay: 0,
                easing: "linear",
                fill: 'forwards',
                direction: "normal",
                iterations: 1,
                begin: 0,
                end: 1
            })
            const animator = new Animator(animation, this.stateChangedListener)
            MediaLogger.w(TAG, "create animator")
            return animator
        } else {
            return this.idlePool[0]
        }
    }
}

export class Animator {
    private anim: AnimatorResult
    private isRunning: boolean = false
    private onStateChanged: (anim: Animator, isRunning: boolean) => void

    constructor(anim: AnimatorResult, onStateChanged: (anim: Animator, isRunning: boolean) => void) {
        this.anim = anim
        this.onStateChanged = onStateChanged
        this.onStateChanged(this, false)
    }

    run() {
        this.anim.play()
        if (!this.isRunning) {
            this.isRunning = true
            this.onStateChanged(this, true)
        }
    }

    finish() {
        this.anim.finish()
    }

    reset(option: AnimatorOptions) {
        this.anim.reset(option)
    }

    stop() {
        this.isRunning = true
        if (this.isRunning) {
            this.isRunning = false
            this.onStateChanged(this, false)
        }
    }

    addCallback(callback: (progress: number) => void) {
        this.anim.onFrame = callback
    }
}