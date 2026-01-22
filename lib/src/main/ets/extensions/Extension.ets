import { hilog } from "@kit.PerformanceAnalysisKit"

const TAG = "LyricView"

export function printD(msg: string) {
    hilog.debug(0, TAG, msg)
}

export function printE(msg: string) {
    hilog.error(0, TAG, msg)
}

export function printW(msg: string) {
    hilog.warn(0, TAG, msg)
}

export function duration2text(duration: number): string {
    let seconds = Math.round(duration / 1000)
    let minute = Math.floor(seconds / 60)
    let second = seconds - minute * 60
    let s1 = minute.toString()
    let s2 = second >= 10 ? second.toString() : "0" + second
    return s1 + ":" + s2
}

export function seconds2text(seconds: number) {
    let minute = Math.floor(seconds / 60)
    let second = seconds - minute * 60
    if (second < 10) {
        return minute + ":0" + second
    } else {
        return minute + ":" + second
    }
}