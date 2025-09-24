import { CcLrcController, CcLyricView, Lrc } from '@seagazer/cclyric';
import { MockData, StringParser } from './MockData';


@Entry
@ComponentV2
struct Index2 {
    private timer = -1
    private changeCount = 0
    private parser = new StringParser()
    @Local progress: number = 0
    @Require @Param controller: CcLrcController = new CcLrcController()
    @Local lyric?: Lrc = undefined

    aboutToAppear(): void {
        // set controller
        this.controller.setDebugger(true)
        this.controller.textSize = 18
        this.controller.lineSpace = 12
        this.controller.textColor = 0xCC000000
        this.controller.textHighlightColor = 0xffe7107f
        this.controller.fadeColor = "#ffffffff"
        this.lyric = this.parser.parse(MockData.krc1)
        this.controller.setLyric(this.lyric)
    }

    build() {
        Column() {
            Stack() {
                CcLyricView({
                    controller: this.controller
                })
            }
            .width("100%")
            .layoutWeight(1)

            Slider({
                value: this.progress,
                max: this.lyric ? this.lyric.lyricList[this.lyric.lyricList.length-1].endTime : 0
            }).width("100%").margin(8)
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End) {
                        this.progress = value
                        this.controller.updatePosition(this.progress)
                    }
                })

            Row() {
                Button("start")
                    .onClick(() => {
                        this.mockMediaPlay()
                    })

                Button("change")
                    .onClick(() => {
                        this.mockChanged()
                    })
                Button("empty")
                    .onClick(() => {
                        this.setEmpty()
                    })
            }.width("100%")
            .justifyContent(FlexAlign.SpaceEvenly)
        }
        .height('100%')
        .width('100%')
    }

    private setEmpty() {
        clearInterval(this.timer)
        this.progress = 0
        this.controller.setLyric(undefined)
    }

    private mockMediaPlay() {
        clearInterval(this.timer)
        this.progress = 0
        this.timer = setInterval(() => {
            this.progress += 300
            this.controller.updatePosition(this.progress)
        }, 300)
    }

    // change data source
    private mockChanged() {
        if (this.changeCount % 2 == 0) {
            this.lyric = this.parser.parse(MockData.krc2)
            this.controller.setLyric(this.lyric)
        } else {
            this.lyric = this.parser.parse(MockData.krc1)
            this.controller.setLyric(this.lyric)
        }
        // replay
        this.mockMediaPlay()
        this.changeCount++
    }
}







