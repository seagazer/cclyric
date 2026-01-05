import { AlignMode, CcLyricController, CcLyricView } from '@seagazer/cclyric';
import { CcPlayer, MediaSource, MediaSourceFactory, PlayerState } from '@seagazer/ccplayer';
import { MockData, StringParser } from './MockData';


@Entry
@ComponentV2
struct CcLyricViewSample {
    private parser = new StringParser()
    private controller: CcLyricController = new CcLyricController()
    @Local playingIndex: number = 0
    private songList = ["我想更懂你.mp3", "画心.mp3"]
    private krcList = [MockData.krc6, MockData.krc7]
    @Local userProgress: number = 0
    @Local playerProgress: number = 0
    @Local duration: number = 0
    @Local isPlaying: boolean = false
    private isSeeking = false
    private player = new CcPlayer(this.getUIContext().getHostContext()!)
    private src?: MediaSource = undefined
    private progressChangedListener = (position: number) => {
        this.playerProgress = position
        this.controller.updatePosition(this.playerProgress)
        if (this.isSeeking) {
            return
        }
        this.userProgress = position
    }
    private prepareListener = () => {
        this.duration = this.player.getDuration()
    }
    private seekChangedListener = (position: number) => {
        this.isSeeking = false
        this.userProgress = position
        this.playerProgress = position
    }
    private stateChangedListener = (state: PlayerState) => {
        this.isPlaying = this.player.isPlaying()
    }
    aboutToAppear(): void {
        // set controller
        this.controller.setDebugger(true)
        this.controller
            .setLineSpace(12)
            .setTextSize(18) // only set once
            .setHighlightScale(1.2) // only set once
            .setTextColor(0xCC707070)
            .setTextHighlightColor(0xffe7107f)
            .setEmptyHint("未找到歌词")
            .setAlignMode(AlignMode.CENTER)
            .setFadeEnable(true)
            .setFadePercent(0.25)
        this.player.addOnProgressChangedListener(this.progressChangedListener)
            .addOnPreparedListener(this.prepareListener)
            .addOnSeekChangedListener(this.seekChangedListener)
            .addOnStateChangedListener(this.stateChangedListener)
    }

    aboutToDisappear(): void {
        this.player.removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnPreparedListener(this.prepareListener)
            .removeOnSeekChangedListener(this.seekChangedListener)
            .removeOnStateChangedListener(this.stateChangedListener)
        this.player.release()
    }

    build() {
        Column() {
            Text(this.songList[this.playingIndex])
                .fontSize(24)
                .padding(16)

            Stack() {
                Stack() {
                    CcLyricView({
                        controller: this.controller,
                        // default seek ui: 1.set supportSeek true, 2.do player seek action at onSeekAction callback
                        supportSeek: true,
                        onSeekAction: (position) => {
                            this.player.seekTo(position)
                        }
                    })
                }.padding(12)
            }
            .width("100%")
            .layoutWeight(1)

            Slider({
                value: this.userProgress,
                max: this.duration
            }).width("100%").margin(8)
                .onChange((value, mode) => {
                    if (mode === SliderChangeMode.Begin) {
                        this.isSeeking = true
                    } else if (mode === SliderChangeMode.End) {
                        this.player.seekTo(value)
                    }
                })

            Row() {
                Text(duration2Text(this.playerProgress) + " / " + duration2Text(this.duration))
                    .fontSize(18)
                    .textAlign(TextAlign.Start)

                SymbolGlyph(this.isPlaying ? $r("sys.symbol.pause_fill") : $r("sys.symbol.play_fill"))
                    .fontSize(32)
                    .onClick(() => {
                        if (this.src === undefined) {
                            const lyric = this.parser.parse(this.krcList[this.playingIndex])
                            this.controller.setLyric(lyric)
                            this.src = MediaSourceFactory.createAssets(this.songList[this.playingIndex], this.songList[this.playingIndex])
                            this.player.setMediaSource(this.src, () => {
                                this.player.start()
                            })
                        } else {
                            if (this.player.isPlaying()) {
                                this.player.pause()
                            } else {
                                this.player.start()
                            }
                        }
                    })

                SymbolGlyph($r("sys.symbol.forward_end_fill"))
                    .fontSize(32)
                    .onClick(() => {
                        this.playingIndex++
                        this.playingIndex %= 2
                        const lyric = this.parser.parse(this.krcList[this.playingIndex])
                        this.controller.setLyric(lyric)
                        this.src = MediaSourceFactory.createAssets(this.songList[this.playingIndex], this.songList[this.playingIndex])
                        this.player.setMediaSource(this.src, () => {
                            this.player.start()
                        })
                    })
                SymbolGlyph($r("sys.symbol.paintpalette_fill"))
                    .fontSize(32)
                    .onClick(() => {
                        this.controller
                            .setEmptyHint("No Lyric")
                            .setTextColor(0x80809241)
                            .setTextHighlightColor(0xff32c64b)
                    })
            }.width("100%")
            .justifyContent(FlexAlign.SpaceBetween)
        }
        .height('100%')
        .width('100%')
        .padding(16)
    }


}

export function duration2Text(duration: number): string {
    const totalSeconds = Math.floor(duration / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    const minutesStr = minutes.toString().padStart(2, '0');
    const secondsStr = seconds.toString().padStart(2, '0');
    return `${minutesStr}:${secondsStr}`;
}





