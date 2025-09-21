import { Lyric } from '../bean/Lyric';

/**
 * @deprecated since v1.0.9
 */
export interface IParser {

    parse(source: Object): Lyric | undefined

}