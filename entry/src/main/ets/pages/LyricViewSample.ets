import { FileParser, Lyric, LyricController, LyricView, LyricView2 } from '@seagazer/cclyric';
import { picker } from '@kit.CoreFileKit';
import { uri } from '@kit.ArkTS';

// @deprecated since v1.0.9
@Entry
@Component
struct LyricViewSample {
    @State mediaPosition: number = 0
    private lyric: Lyric | undefined = undefined
    private lyricController: LyricController = new LyricController()
    private testTimer = -1
    private emptyDuration = 60 * 1000
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

    aboutToDisappear(): void {
        clearInterval(this.testTimer)
    }

    private test() {
        this.mediaPosition = 0
        this.testTimer = setInterval(() => {
            this.mediaPosition += 1000
            this.lyricController.updatePosition(this.mediaPosition)
            let endDuration = this.lyric == undefined ? this.emptyDuration : this.lyric.lyricList[this.lyric.lyricList.length - 1].beginTime
            if (this.mediaPosition >= endDuration + 1000) {
                clearInterval(this.testTimer)
            }
        }, 1000)
    }

    build() {
        Column() {
            Text(this.title).margin(16)
                .fontColor("#ffffffff")
                .fontSize(24)
                .fontColor("#ffffffff")
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
            Column() {
                Row() {
                    Text('useV2View').fontColor("#ffffffff").fontSize(16).padding(4)
                    Toggle({ type: ToggleType.Switch, isOn: true })
                        .onChange((isOn) => {
                            this.isV2 = isOn
                        })
                    Text('centerMode').fontColor("#ffffffff").fontSize(16).padding(4)
                    Toggle({ type: ToggleType.Switch, isOn: true })
                        .onChange((isOn) => {
                            if (isOn) {
                                this.lyricController.setAlignMode("center")
                            } else {
                                this.lyricController.setAlignMode("left")
                            }
                        })
                }

                Row() {
                    Button('play')
                        .fontSize(16)
                        .margin({ left: 16 })
                        .onClick(() => {
                            let parser = new FileParser()
                            let documentSelectOptions = new picker.DocumentSelectOptions();
                            let picker2 = new picker.DocumentViewPicker(getContext(this))
                            picker2.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
                                let url = decodeURI(documentSelectResult[0])
                                let uri2 = new uri.URI(url)
                                this.lyric = parser.parse(uri2.path)
                                if (this.lyric) {
                                    this.lyricController.setLyric(this.lyric)
                                    this.test()
                                }
                            })
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
                    Button('clear')
                        .fontSize(16)
                        .margin({ left: 16 })
                        .onClick(() => {
                            this.lyricController.setLyric(null)
                        })
                }.width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ top: 16 })
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