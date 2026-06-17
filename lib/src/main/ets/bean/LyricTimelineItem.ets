import { LyricDisplayLine } from './LyricDisplayLine'
import { LrcLineView } from '../view/LrcLineView'

export interface LyricTimelineItem {
    beginTime: number
    endTime: number
    displayLine: LyricDisplayLine
    view: LrcLineView
}
