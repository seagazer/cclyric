import { AlignMode, CcLyricController, CcLyricView, Lrc } from '@seagazer/cclyric';
import { MockData, StringParser } from './MockData';


@Entry
@ComponentV2
struct CustomSeekUISample {
    private timer = -1
    private changeCount = 0
    private parser = new StringParser()
    @Local progress: number = 0
    @Local lyric?: Lrc = undefined
    private controller: CcLyricController = new CcLyricController()
    // custom seek ui
    @Local userScrolling: boolean = false
    @Local scrollTargetTime: number = 0

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
            .setAlignMode(AlignMode.START)
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
                        // custom seek ui: 1.set supportSeek false, 2.get current center duration from onScrollChanged and onScrollStateChanged callback
                        supportSeek: false,
                        onScrollChanged: (centerLine) => {
                            if (centerLine !== undefined) {
                                this.scrollTargetTime = centerLine.beginTime
                            }
                        },
                        onScrollStateChanged: (scrolling) => {
                            this.userScrolling = scrolling
                        }
                    })
                }.padding(12)

                // custom seek ui
                if (this.userScrolling && this.scrollTargetTime >= 0) {
                    Row() {
                        Blank()
                        Text(duration2text(this.scrollTargetTime))
                            .fontSize(18)
                        SymbolGlyph($r("sys.symbol.play_fill"))
                            .fontSize(32)
                            .onClick(() => {
                                this.mockPlayerSeek(this.scrollTargetTime)
                                this.userScrolling = false
                            })
                    }
                    .width("95%")
                    .height(42)
                    .border({ radius: 8 })
                    .backgroundColor("#808d8d8d")
                }
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
                        this.controller.setEmptyHint("No Lyric")
                            .setLineSpace(32)
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


function duration2text(duration: number): string {
    let seconds = Math.round(duration / 1000)
    let minute = Math.floor(seconds / 60)
    let second = seconds - minute * 60
    let s1 = minute.toString()
    let s2 = second >= 10 ? second.toString() : "0" + second
    return s1 + ":" + s2
}






