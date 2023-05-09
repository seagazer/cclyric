import { Lyric, LyricConfig, LyricParser, LyricView } from '@seagazer/cclyric';
import { MockData } from './MockData';

@Entry
@Component
struct Index {
    @State duration: number = 0
    private lyricList: Array<Lyric> = new Array()
    private lyric: Lyric = null
    private lyricConfig: LyricConfig = new LyricConfig()

    aboutToAppear() {
        let lyric1 = new LyricParser().parse(MockData.src1)
        let lyric2 = new LyricParser().parse(MockData.src2)
        this.lyricList.push(lyric1)
        this.lyricList.push(lyric2)
        this.lyric = this.lyricList[0]
        this.lyricConfig
            .setLyric(this.lyric)
            .setTextSize(48)
            .setTextColor("#ff999999")
            .setHighlightColor("#ff000000")
            .setLineSpace(20)
            .setHighlightStyle(false)
            .setAnimationDuration(1000)
    }

    private test() {
        this.duration = 0
        let testTaskId = setInterval(() => {
            this.duration += 1000
            if (this.duration > this.lyric.lyricList[this.lyric.lyricList.length - 1].timestamp + 1000) {
                clearInterval(testTaskId)
            }
        }, 1000)
    }

    build() {
        Column() {
            LyricView(
                {
                    config: this.lyricConfig,
                    currentPosition: $duration,
                })
                .width("100%")
                .height("70%")
                .padding({ left: 16, right: 16 })
            Row() {
                Button('PlayNext')
                    .fontSize(16)
                    .onClick(() => {
                        if (this.lyric == this.lyricList[0]) {
                            this.lyric = this.lyricList[1]
                            this.lyricConfig.setLyric(this.lyric)
                        } else {
                            this.lyric = this.lyricList[0]
                            this.lyricConfig.setLyric(this.lyric)
                        }
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

            Text(Math.round(this.duration / 1000) + "s")
                .fontSize(18)
                .margin({ top: 16 })

            Slider({
                style: SliderStyle.InSet,
                max: this.lyric.lyricList[this.lyric.lyricList.length - 1].timestamp,
                value: this.duration
            })
                .width("100%")
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == 3) {
                        this.duration = value
                    }
                })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
    }
}