import { Lyric } from '../bean/Lyric';

export interface IParser {

    parse(source: Object): Lyric | undefined

}