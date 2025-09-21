import { IParser, Lyric, LyricParser } from '@seagazer/cclyric';
import fs from '@ohos.file.fs';
import { printD, printW } from '../extensions/Extension';

/**
 * Author: seagazer
 * Date: 2023/6/11
 *
 * @deprecated since v1.0.9
 */
export class FileParser implements IParser {
    private parser = new LyricParser()

    parse(filePath: string): Lyric | undefined {
        let lrc = fs.readTextSync(filePath)
        let isCR = lrc.indexOf("\r") > 0 && lrc.indexOf("\n") < 0 // mac
        let isLF = lrc.indexOf("\n") > 0 && lrc.indexOf("\r") < 0 // unix
        let isCRLF = lrc.indexOf("\r") > 0 && lrc.indexOf("\n") > 0 // windows
        let lrcArray = new Array<string>()
        if (isCR) {
            printD("isCR mac")
            lrcArray = lrc.split("\r")
        } else if (isLF) {
            printD("isLF unix")
            lrcArray = lrc.split("\n")
        } else if (isCRLF) {
            printD("isCRLF windows")
            lrcArray = lrc.split("\r\n")
        }
        lrcArray.forEach((lrc) => {
            printW(JSON.stringify(lrc))
        })
        return this.parser.parse(lrcArray)
    }
}