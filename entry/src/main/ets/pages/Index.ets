import { Lyric, LyricController, LyricParser, LyricView, LyricView2 } from '@seagazer/cclyric';
import { MockData } from './MockData';

@Entry
@Component
struct Index {
    @State mediaPosition: number = 0
    private lyric: Lyric | null = null
    private lyricController: LyricController = new LyricController()
    private testIndex = 0
    private testTimer = -1
    private emptyDuration = 60 * 1000
    private parser = new LyricParser()
    @State title: string = ""
    @State isV2: boolean = true
    private i = 0
    private j = 0

    aboutToAppear() {
        this.lyricController
            .setTextSize(18)
            .setCacheSize(4)
            .setTextColor("#80ffffff")
            .setHighlightColor("#ffffffff")
            .setLineSpace(18)
            .setHighlightScale(1.3)
            .setHighlightBold(true)
            .setHighlightBold(false)
            .setEmptyHint("当前没有歌词")
            .setAlignMode("center")
    }

    private test() {
        this.mediaPosition = 0
        this.testTimer = setInterval(() => {
            this.mediaPosition += 1000
            this.lyricController.updatePosition(this.mediaPosition)
            let endDuration = this.lyric == null ? this.emptyDuration : this.lyric.lyricList[this.lyric.lyricList.length - 1].beginTime
            if (this.mediaPosition >= endDuration + 1000) {
                clearInterval(this.testTimer)
            }
        }, 1000)
    }

    build() {
        Column() {
            Text(this.title).margin(16)
                .fontColor("#ffffff")
                .fontSize(24)
                .fontColor("#ffffff")
            if (this.isV2) {
                LyricView2({
                    controller: this.lyricController,
                    enableSeek: true,
                    seekUIColor: "#ffd4d4d4",
                    seekLineColor: "#80ffffff",
                    seekUIStyle: "listItem",
                    onSeekAction: (position) => {
                        this.mediaPosition = position
                        return true
                    }
                }).width("100%").layoutWeight(1)
            } else {
                LyricView({ controller: this.lyricController })
                    .width("100%").layoutWeight(1)
            }
            Row() {
                Column() {
                    Text('useV2View').fontColor("#ffffff").fontSize(16).padding(4)
                    Toggle({ type: ToggleType.Switch, isOn: true })
                        .onChange((isOn) => {
                            this.isV2 = isOn
                        })
                    Text('centerMode').fontColor("#ffffff").fontSize(16).padding(4)
                    Toggle({ type: ToggleType.Switch, isOn: true })
                        .onChange((isOn) => {
                            if (isOn) {
                                this.lyricController.setAlignMode("center")
                            } else {
                                this.lyricController.setAlignMode("left")
                            }
                        })
                }

                Button('play')
                    .fontSize(16)
                    .margin({ left: 16 })
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
                        this.mediaPosition = 0
                        this.test()
                    })
                Button('color')
                    .fontSize(16)
                    .margin({ left: 16 })
                    .onClick(() => {
                        this.i++
                        if (this.i % 2 == 0) {
                            this.lyricController
                                .setTextColor("#80ffffff")
                                .setHighlightColor("#ffffffff")
                        } else {
                            this.lyricController
                                .setTextColor("#80e3d052")
                                .setHighlightColor("#e3d052")
                        }
                    })
                Button('size')
                    .fontSize(16)
                    .margin({ left: 16 })
                    .onClick(() => {
                        this.j++
                        if (this.j % 2 == 0) {
                            this.lyricController.setTextSize(12)
                                .setLineSpace(12)
                        } else {
                            this.lyricController.setTextSize(18)
                                .setLineSpace(18)
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
                    value: this.mediaPosition
                })
                .blockColor("#fffafafa")
                .trackColor("#ffffff")
                .width("100%")
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == 3) {
                        this.mediaPosition = value
                        this.lyricController.updatePosition(this.mediaPosition)
                    }
                })

            Text(Math.round(this.mediaPosition / 1000) + "s")
                .fontColor("#ffffff")
                .fontSize(18)
                .margin({ top: 16 })

        }
        .linearGradient({
            angle: 360,
            colors: [["#ff2e3030", 0], ["#662e3030", 1],]
        })
        .padding(16)
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
    }
}