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
        this.lyricList.push(null)
        this.lyricList.push(lyric1)
        this.lyricList.push(lyric2)
        this.lyricConfig
            .setTextSize(48)
            .setTextColor("#ff999999")
            .setHighlightColor("#ff000000")
            .setLineSpace(20)
            .setHighlightStyle(false)
            .setAnimationDuration(1000)
            .setEmptyHint("No Lyric")
    }

    private testIndex = 0

    private test() {
        this.duration = 0
        let testTaskId = setInterval(() => {
            this.duration += 1000
            let endDuration = this.lyric == null ? 100000 : this.lyric.lyricList[this.lyric.lyricList.length - 1].timestamp
            if (this.duration > endDuration + 1000) {
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
                .layoutWeight(1)
                .padding({ left: 16, right: 16 })
            Row() {
                Button('PlayNext')
                    .fontSize(16)
                    .onClick(() => {
                        this.testIndex++
                        let index = this.testIndex % 3
                        console.debug("----" + index)
                        this.lyricConfig.setLyric(this.lyricList[index])
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

            Slider({
                style: SliderStyle.InSet,
                max: this.lyric != null ? this.lyric.lyricList[this.lyric.lyricList.length - 1].timestamp : 100000,
                value: this.duration
            })
                .width("100%")
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == 3) {
                        this.duration = value
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