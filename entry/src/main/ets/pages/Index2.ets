import { CcLrcController, CcLyricView, Lrc } from '@seagazer/cclyric';
import { MockData, StringParser } from './MockData';


@Entry
@ComponentV2
struct Index2 {
    private timer = -1
    @Local focusIndex: number = -1
    @Local userSeekIndex: number = -1
    @Local progress: number = 0
    @Require @Param controller: CcLrcController = new CcLrcController()
    @Local lyric?: Lrc = undefined
    private changeCount = 0
    private parser = new StringParser()

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
                        this.mockPlayer()
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

    private mockPlayer() {
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
            // replay
            this.mockPlayer()
        } else {
            this.lyric = this.parser.parse(MockData.krc1)
            this.controller.setLyric(this.lyric)
            // replay
            this.mockPlayer()
        }
        this.changeCount++
    }
}







