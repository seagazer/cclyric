import { describe, expect, it } from '@ohos/hypium'
import { StringParser } from '../../main/ets/pages/MockData'

export default function stringParserTest() {
    describe('StringParser', 0, () => {
        it('parses minute and second without fraction', 0, () => {
            const lyric = new StringParser().parse(['[00:12]hello'])
            expect(lyric.lyricList.length).assertEqual(1)
            expect(lyric.lyricList[0].beginTime).assertEqual(12000)
        })

        it('parses two and three digit fractions as milliseconds', 0, () => {
            const lyric = new StringParser().parse([
                '[00:26.70]percent',
                '[00:00.195]milliseconds',
                '[00:01.2]tenths'
            ])
            expect(lyric.lyricList[0].beginTime).assertEqual(26700)
            expect(lyric.lyricList[1].beginTime).assertEqual(195)
            expect(lyric.lyricList[2].beginTime).assertEqual(1200)
        })

        it('parses seconds format', 0, () => {
            const lyric = new StringParser().parse(['[20.3]seconds'])
            expect(lyric.lyricList[0].beginTime).assertEqual(20300)
        })

        it('keeps KRC word timing with adjacent time tags', 0, () => {
            const lyric = new StringParser().parse([
                '[00:09.570]词[00:10.208]：[00:10.846][00:10.847]宇[00:11.485]多[00:12.123]田[00:12.761]'
            ])
            const line = lyric.lyricList[0]
            expect(line.wordList !== undefined).assertTrue()
            expect(line.wordList!.length).assertEqual(5)
            expect(line.wordList![1].beginTime).assertEqual(10208)
            expect(line.wordList![1].endTime).assertEqual(10846)
        })

        it('ignores metadata and empty lyric lines', 0, () => {
            const lyric = new StringParser().parse([
                '[ti:Title]',
                '[ar:Artist]',
                '[00:01.00]'
            ])
            expect(lyric.title).assertEqual('Title')
            expect(lyric.artist).assertEqual('Artist')
            expect(lyric.lyricList.length).assertEqual(0)
        })

        it('keeps explicit newline text as one lyric line', 0, () => {
            const lyric = new StringParser().parse(['[00:01.00]a\n\nb\n'])
            expect(lyric.lyricList.length).assertEqual(1)
            expect(lyric.lyricList[0].text).assertEqual('a\n\nb\n')
        })
    })
}
