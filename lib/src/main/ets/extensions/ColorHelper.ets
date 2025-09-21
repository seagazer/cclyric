/**
 *
 * Author: Seagazer
 * Date: 2025/9/21
 */
export class ColorHelper {
    // hex, argb, string
    private static hex2String(hex: number): string {
        let hexString = hex.toString(16)
        if (hexString.length < 6) {
            let size = 6 - hexString.length
            let fill = ""
            for (let i = 0; i < size; i++) {
                fill += 0
            }
            return "#" + fill + hexString
        } else {
            return "#" + hexString
        }
    }

    private static hexNumber2Argb(hex: number) {
        let alpha = hex >> 24 & 0xff
        let red = hex >> 16 & 0xff
        let green = hex >> 8 & 0xff
        let blue = hex & 0xff
        return [alpha, red, green, blue]
    }

    static hex2Argb(hex: string | number): number[] {
        if (typeof hex == 'number') {
            return ColorHelper.hexNumber2Argb(hex)
        } else {
            let hexString = hex.replace("#", "")
            if (hexString.length < 8) {
                hexString = "ff" + hexString
            }
            let hex2 = Number.parseInt(hexString, 16)
            return ColorHelper.hexNumber2Argb(hex2)
        }
    }
}