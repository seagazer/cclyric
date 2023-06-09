import { Lyric, LyricConfig, LyricParser, LyricView } from '@seagazer/cclyric';
import { MockData } from './MockData';

@Entry
@Component
struct Index {
    @State duration: number = 0
    private lyricList: Array<Lyric> = new Array()
    private lyric: Lyric = null
    private lyricConfig: LyricConfig = new LyricConfig()
    private testIndex = 0
    private testTimer = -1
    private emptyDuration = 60 * 1000

    aboutToAppear() {
        let lyric1 = new LyricParser().parse(MockData.src1)
        let lyric2 = new LyricParser().parse(MockData.src2)
        this.lyricList.push(null)
        this.lyricList.push(lyric1)
        this.lyricList.push(lyric2)
        this.lyricConfig
            .setTextSize(24)
            .setCacheSize(4)
            .setTextColor("#ffc4c4c4")
            .setHighlightColor("#ff000000")
            .setLineSpace(16)
            .setHighlightStyle(false)
            .setEmptyHint("No Lyric")
    }

    private test() {
        this.duration = 0
        this.testTimer = setInterval(() => {
            this.duration += 1000
            this.lyricConfig.updatePosition(this.duration)
            let endDuration = this.lyric == null ? this.emptyDuration : this.lyric.lyricList[this.lyric.lyricList.length - 1].beginTime
            if (this.duration >= endDuration + 1000) {
                clearInterval(this.testTimer)
            }
        }, 1000)
    }

    build() {
        Column() {
            LyricView({ lyricConfig: this.lyricConfig, })
                .width("100%")
                .layoutWeight(1)
                .padding({ left: 16, right: 16 })
            Row() {
                Button('PlayNext')
                    .fontSize(16)
                    .onClick(() => {
                        this.testIndex++
                        let index = this.testIndex % 3
                        this.lyric = this.lyricList[index]
                        this.lyricConfig.setLyric(this.lyric)
                        clearInterval(this.testTimer)
                        this.duration = 0
                    })
                Button('AutoPlay')
                    .fontSize(16)
                    .onClick(() => {
                        this.test()
                    }).margin({ left: 16 })
            }
            .width("100%")
            .justifyContent(FlexAlign.Center)
            .margin({ top: 36 })

            Slider(
                {
                    style: SliderStyle.InSet,
                    max: this.lyric != null ? this.lyric.lyricList[this.lyric.lyricList.length - 1].beginTime : this.emptyDuration,
                    value: this.duration
                })
                .width("100%")
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == 3) {
                        this.duration = value
                        this.lyricConfig.updatePosition(this.duration)
                    }
                })

            Text(Math.round(this.duration / 1000) + "s")
                .fontSize(18)
                .margin({ top: 16 })

        }
        .padding(16)
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
    }
}