import { CcLyricController, CcLyricView, Lrc } from '@seagazer/cclyric';
import { MockData, StringParser } from './MockData';


@Entry
@ComponentV2
struct CcLyricViewSample {
    private timer = -1
    private changeCount = 0
    private parser = new StringParser()
    @Local progress: number = 0
    @Local lyric?: Lrc = undefined
    private controller: CcLyricController = new CcLyricController()

    aboutToAppear(): void {
        // set controller
        this.controller.setDebugger(true)
        this.controller
            .setLineSpace(12)
            .setTextSize(18) // only set once
            .setHighlightScale(1.2) // only set once
            .setTextColor(0xCC707070)
            .setTextHighlightColor(0xffe7107f)
            .setFadeColor("#00000000")
            .setEmptyHint("未找到歌词")
        this.lyric = this.parser.parse(MockData.krc1)
        this.controller.setLyric(this.lyric)
    }

    aboutToDisappear(): void {
        clearInterval(this.timer)
    }

    build() {
        Column() {
            Stack() {
                Stack() {
                    CcLyricView({
                        controller: this.controller,
                        // default seek ui: 1.set supportSeek true, 2.do player seek action at onSeekAction callback
                        supportSeek: true,
                        onSeekAction: (position) => {
                            this.mockPlayerSeek(position)
                        }
                    })
                }.padding(12)
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

                Button("next")
                    .onClick(() => {
                        this.mockChanged()
                    })
                Button("empty")
                    .onClick(() => {
                        this.setEmpty()
                    })
                Button("style")
                    .onClick(() => {
                        this.controller
                            .setEmptyHint("No Lyric")
                            .setTextColor(0x80809241)
                            .setTextHighlightColor(0xff32c64b)
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
            if (this.lyric && this.progress > this.lyric.lyricList[this.lyric.lyricList.length-1].endTime) {
                this.progress = this.lyric.lyricList[this.lyric.lyricList.length-1].endTime
                return
            }
            this.progress += 300
            this.controller.updatePosition(this.progress)
        }, 300)
    }

    private mockPlayerSeek(position: number) {
        clearInterval(this.timer)
        this.progress = position
        this.controller.updatePosition(this.progress)
        this.timer = setInterval(() => {
            if (this.lyric && this.progress > this.lyric.lyricList[this.lyric.lyricList.length-1].endTime) {
                this.progress = this.lyric.lyricList[this.lyric.lyricList.length-1].endTime
                return
            }
            this.progress += 300
            this.controller.updatePosition(this.progress)
        }, 300)
    }

    // change data source
    private mockChanged() {
        if (this.changeCount % 3 == 0) {
            this.lyric = this.parser.parse(MockData.krc3)
            this.controller.setLyric(this.lyric)
        } else if (this.changeCount % 2 == 0) {
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







