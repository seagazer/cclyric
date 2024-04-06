import { Lyric, LyricController, LyricParser, LyricView, LyricView2 } from '@seagazer/cclyric';
import { MockData } from './MockData';

@Entry
@Component
struct Index {
    @State duration: number = 0
    private lyric: Lyric | null = null
    private lyricController: LyricController = new LyricController()
    private testIndex = 0
    private testTimer = -1
    private emptyDuration = 60 * 1000
    private parser = new LyricParser()
    @State title: string = ""
    private i = 0
    private j = 0

    aboutToAppear() {
        this.lyricController
            .setTextSize(16)
            .setCacheSize(4)
            .setTextColor("#8c000000")
            .setHighlightColor("#ff000000")
            .setLineSpace(16)
            .setHighlightStyle(false)
            .setEmptyHint("当前没有歌词")
            .setAlignMode("center")
    }

    private test() {
        this.duration = 0
        this.testTimer = setInterval(() => {
            this.duration += 1000
            this.lyricController.updatePosition(this.duration)
            let endDuration = this.lyric == null ? this.emptyDuration : this.lyric.lyricList[this.lyric.lyricList.length - 1].beginTime
            if (this.duration >= endDuration + 1000) {
                clearInterval(this.testTimer)
            }
        }, 1000)
    }

    build() {
        Column() {
            Text(this.title).margin(16)
            LyricView2({ controller: this.lyricController, })
                .width("100%")
                .layoutWeight(1)
                .padding({ left: 16, right: 16 })
            Row() {
                Button('play')
                    .fontSize(16)
                    .onClick(() => {
                        this.testIndex++
                        if (this.testIndex % 2 == 0) {
                            this.lyric = this.parser.parse(MockData.src1)
                            this.title = "可能"
                        } else {
                            this.title = "一直很安静"
                            this.lyric = this.parser.parse(MockData.src2)
                        }
                        this.lyricController.setLyric(this.lyric)
                        clearInterval(this.testTimer)
                        this.duration = 0
                        this.test()
                    })
                Button('color')
                    .fontSize(16)
                    .margin({ left: 16 })
                    .onClick(() => {
                        this.i++
                        if (this.i % 2 == 0) {
                            this.lyricController.setTextColor("#8c000000")
                            this.lyricController.setHighlightColor("#000000")
                        } else {
                            this.lyricController.setTextColor("#8cff0000")
                            this.lyricController.setHighlightColor("#ff0000")
                        }
                    })
                Button('size')
                    .fontSize(16)
                    .margin({ left: 16 })
                    .onClick(() => {
                        this.j++
                        if (this.j % 2 == 0) {
                            this.lyricController.setTextSize(vp2px(18))
                                .setLineSpace(16)
                        } else {
                            this.lyricController.setTextSize(vp2px(16))
                                .setLineSpace(14)
                        }
                    })
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
                        this.lyricController.updatePosition(this.duration)
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