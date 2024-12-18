import { CcLyricView, LyricParser } from '@seagazer/cclyric';
import { MockData } from './MockData';

@Entry
@Component
struct Index {
    private ccLyricView = new CcLyricView()

    build() {
        Column() {
            NodeContainer(this.ccLyricView)
                .width('100%')
                .layoutWeight(1)

            Button('test')
                .fontSize(16)
                .onClick(() => {
                    let parser = new LyricParser()
                    let lyric = parser.parse(MockData.src1)
                    this.ccLyricView.setLyric(lyric)
                })

        }
        .width('100%')
        .height('100%')
    }
}