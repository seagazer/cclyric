# cclyric

## 简介

**cclyric** 是一个为 **OpenHarmony** 和 **HarmonyOS** 设计的音乐歌词组件库。

- 支持逐字歌词，也就是卡拉 OK 高亮效果
- 支持逐行歌词
- 支持歌词滚动显示
- 支持滑动 seek 操作
- 支持默认 seek UI，也支持自定义 seek UI
- 支持歌词左对齐和居中显示
- 支持自定义歌词样式，包括行距、字号、普通颜色、逐字背景色、聚焦颜色、聚焦缩放等
- 逐字歌词进度由播放时间戳驱动，并在播放中进行平滑刷新

## 示例效果

| 居中对齐                                                                          | 左对齐                                                                            | 自定义样式                                                                        | 自定义 seek 界面                                                                  |
| --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| <img src="https://s41.ax1x.com/2026/01/05/pZdi7AP.png" width="180" height="360"/> | <img src="https://s41.ax1x.com/2026/01/05/pZdFS7q.png" width="180" height="360"/> | <img src="https://s41.ax1x.com/2026/01/05/pZdF9A0.png" width="180" height="360"/> | <img src="https://s41.ax1x.com/2025/12/20/pZ3QWSe.png" width="180" height="360"/> |

## 注意事项

- 从 1.1.4 版本开始，废弃的 `LyricView`、`LyricView2`、旧控制器和旧解析器已删除，请统一使用 `CcLyricView`、`CcLyricController` 和 `Lrc` 数据结构。
- 从 1.1.1 版本开始，逐字动画逻辑已重构，动效更平滑和精准；由于使用了部分高版本接口，后续版本仅支持 API 14 及以上。
- 从 1.0.8 版本开始，不再提供默认歌词解析器。业务侧可以根据自己的歌词来源，将 LRC、KRC、逐字歌词等格式解析为本库的 `Lrc` 数据结构。

## 依赖方式

```ts
ohpm install @seagazer/cclyric
```

## 接口文档

### CcLyricView

歌词视图组件。组件通过 `controller` 接收歌词、播放进度和样式配置。

| 属性                 | 属性类型                                   | 默认值 | 属性说明                                               | 必填 |
| -------------------- | ------------------------------------------ | ------ | ------------------------------------------------------ | ---- |
| controller           | CcLyricController                          | -      | 歌词组件控制器                                         | 是   |
| supportSeek          | boolean                                    | true   | 是否开启默认滑动 seek 能力                             | 否   |
| autoHideSeekUIDelay  | number                                     | 800    | 用户停止滑动后，默认 seek UI 或自定义 seek 状态隐藏延迟，单位 ms | 否   |
| onSeekAction         | (position: number) => void                 | -      | 点击默认 seek UI 播放按钮时触发，返回目标播放进度，单位 ms | 否   |
| onScrollChanged      | (centerLine: LrcLine \| undefined) => void | -      | 用户滑动歌词时，中间位置歌词变化回调，可用于自定义 seek UI | 否   |
| onScrollStateChanged | (scrolling: boolean) => void               | -      | 用户手动滑动状态变化回调，可用于自定义 seek UI         | 否   |
| onDataSourceReady    | () => void                                 | -      | 歌词数据源构建完成回调                                 | 否   |

### CcLyricController

`CcLyricView` 控制器，用于设置歌词数据、播放进度和显示样式。样式接口支持链式调用。

#### setDebugger(debug: boolean): void

设置是否开启调试日志，默认 `false`。

| 参数  | 参数类型 | 参数说明         |
| ----- | -------- | ---------------- |
| debug | boolean  | 是否开启调试日志 |

#### setLyric(lyric: Lrc | undefined): CcLyricController

设置歌词数据。传入 `undefined` 时显示空歌词提示。

| 参数  | 参数类型        | 参数说明 |
| ----- | --------------- | -------- |
| lyric | Lrc \| undefined | 歌词数据 |

#### setAlignMode(mode: AlignMode): CcLyricController

设置歌词对齐模式，默认 `AlignMode.CENTER`。

| 参数 | 参数类型  | 参数说明 |
| ---- | --------- | -------- |
| mode | AlignMode | 对齐模式 |

#### setEmptyHint(hintText: ResourceStr): CcLyricController

设置无歌词时的提示语，默认 `--`。

| 参数     | 参数类型    | 参数说明         |
| -------- | ----------- | ---------------- |
| hintText | ResourceStr | 无歌词时的提示语 |

#### setFadeEnable(enable: boolean): CcLyricController

设置歌词上下边缘是否渐变显示，默认 `true`。

| 参数   | 参数类型 | 参数说明                 |
| ------ | -------- | ------------------------ |
| enable | boolean  | 歌词上下边缘是否渐变显示 |

#### setFadePercent(percent: number): CcLyricController

设置歌词上下边缘渐变占比，默认 `0.2`，取值范围为 `[0, 1]`。

| 参数    | 参数类型 | 参数说明         |
| ------- | -------- | ---------------- |
| percent | number   | 上下边缘渐变占比 |

#### setTopOffset(offset: number): CcLyricController

设置歌词内容距离顶部的偏移，单位 vp，默认 `100`。

| 参数   | 参数类型 | 参数说明               |
| ------ | -------- | ---------------------- |
| offset | number   | 歌词内容顶部偏移，单位 vp |

#### setTextSize(size: number): CcLyricController

设置歌词文本大小，单位 vp，默认 `20`。

| 参数 | 参数类型 | 参数说明           |
| ---- | -------- | ------------------ |
| size | number   | 歌词文本大小，单位 vp |

#### setLineSpace(space: number): CcLyricController

设置歌词行间距，单位 vp，默认 `12`。

| 参数  | 参数类型 | 参数说明         |
| ----- | -------- | ---------------- |
| space | number   | 歌词行间距，单位 vp |

#### setTextColor(color: number): CcLyricController

设置普通歌词文本颜色，默认 `0xff000000`。

| 参数  | 参数类型 | 参数说明     |
| ----- | -------- | ------------ |
| color | number   | 普通文本颜色 |

#### setKrcTextBgColor(color: number): CcLyricController

设置逐字歌词聚焦行的背景文本颜色，默认 `0xff000000`。

| 参数  | 参数类型 | 参数说明                 |
| ----- | -------- | ------------------------ |
| color | number   | 逐字歌词聚焦行背景文本颜色 |

#### setTextHighlightColor(color: number): CcLyricController

设置当前播放歌词的高亮颜色，默认 `0xffff0000`。

| 参数  | 参数类型 | 参数说明 |
| ----- | -------- | -------- |
| color | number   | 高亮颜色 |

#### setHighlightScale(scale: number): CcLyricController

设置当前播放歌词的缩放比例，默认 `1.1`。

| 参数  | 参数类型 | 参数说明 |
| ----- | -------- | -------- |
| scale | number   | 缩放比例 |

#### updatePosition(position: number): void

更新媒体播放进度，组件会自动刷新歌词位置、聚焦行和逐字歌词进度。

| 参数     | 参数类型 | 参数说明           |
| -------- | -------- | ------------------ |
| position | number   | 媒体播放进度，单位 ms |

### Lrc

歌词数据结构。

| 属性      | 属性类型        | 属性说明     |
| --------- | --------------- | ------------ |
| artist    | string          | 艺术家，可选 |
| title     | string          | 标题，可选   |
| album     | string          | 专辑，可选   |
| by        | string          | 作者，可选   |
| offset    | number          | 时间戳偏移量，可选 |
| lyricList | LrcLine[]       | 歌词行数组   |

### LrcLine

单行歌词数据结构。

| 属性      | 属性类型               | 属性说明                                  |
| --------- | ---------------------- | ----------------------------------------- |
| text      | string                 | 歌词内容                                  |
| beginTime | number                 | 当前行歌词起始时间戳，单位 ms             |
| endTime   | number                 | 当前行歌词结束时间戳，单位 ms             |
| wordList  | LrcWord[] \| undefined | 逐字歌词时间信息；逐行歌词可不传          |

### LrcWord

逐字歌词数据结构。

| 属性      | 属性类型 | 属性说明                |
| --------- | -------- | ----------------------- |
| text      | string   | 字符或词文本            |
| beginTime | number   | 字符或词起始时间戳，单位 ms |
| endTime   | number   | 字符或词结束时间戳，单位 ms |

### AlignMode

歌词对齐模式。

| 枚举值 | 说明 |
| ------ | ---- |
| CENTER | 居中对齐 |
| START  | 左对齐 |

## 基础示例

```ts
import { AlignMode, CcLyricController, CcLyricView, Lrc } from '@seagazer/cclyric'

@Entry
@ComponentV2
struct Index {
    @Local lyric?: Lrc = undefined
    private parser = new YourLyricParser()
    private controller: CcLyricController = new CcLyricController()

    aboutToAppear(): void {
        this.controller
            .setLineSpace(12)
            .setTextSize(18)
            .setHighlightScale(1.1)
            .setTextColor(0xCC707070)
            .setKrcTextBgColor(0xffd79a75)
            .setTextHighlightColor(0xffe7107f)
            .setEmptyHint('未找到歌词')
            .setAlignMode(AlignMode.CENTER)
            .setFadeEnable(true)
            .setFadePercent(0.15)
            .setTopOffset(300)

        this.lyric = this.parser.parse(lyricText)
        this.controller.setLyric(this.lyric)
    }

    build() {
        Column() {
            CcLyricView({
                controller: this.controller,
                supportSeek: true,
                onSeekAction: (position: number) => {
                    this.seekTo(position)
                }
            })
                .width('100%')
                .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
    }

    onPlayerPositionUpdate(position: number) {
        this.controller.updatePosition(position)
    }

    seekTo(position: number) {
        // player.seekTo(position)
        this.controller.updatePosition(position)
    }
}

const lyricText = `
[00:00.000]我[00:00.400]想[00:00.800]更[00:01.200]懂[00:01.700]你[00:02.500]
[00:02.500]不[00:02.900]是[00:03.300]为[00:03.700]了[00:04.100]抓[00:04.500]紧[00:05.000]你[00:05.600]
`
```

## 自定义 seek UI 示例

将 `supportSeek` 设置为 `false` 后，可以通过 `onScrollChanged` 和 `onScrollStateChanged` 获取滑动状态与中心歌词时间，自行绘制 seek UI。

```ts
import { AlignMode, CcLyricController, CcLyricView, Lrc, LrcLine } from '@seagazer/cclyric'

@Entry
@ComponentV2
struct CustomSeekIndex {
    @Local lyric?: Lrc = undefined
    @Local userScrolling: boolean = false
    @Local scrollTargetTime: number = 0
    private controller: CcLyricController = new CcLyricController()

    aboutToAppear(): void {
        this.controller
            .setTextSize(18)
            .setLineSpace(12)
            .setTextColor(0xCC707070)
            .setTextHighlightColor(0xffe7107f)
            .setAlignMode(AlignMode.START)
            .setEmptyHint('未找到歌词')

        this.lyric = parseLyric()
        this.controller.setLyric(this.lyric)
    }

    build() {
        Stack() {
            CcLyricView({
                controller: this.controller,
                supportSeek: false,
                onScrollChanged: (centerLine: LrcLine | undefined) => {
                    if (centerLine !== undefined) {
                        this.scrollTargetTime = centerLine.beginTime
                    }
                },
                onScrollStateChanged: (scrolling: boolean) => {
                    this.userScrolling = scrolling
                }
            })

            if (this.userScrolling) {
                Row() {
                    Blank()
                    Text(duration2Text(this.scrollTargetTime))
                        .fontSize(18)
                    SymbolGlyph($r('sys.symbol.play_fill'))
                        .fontSize(32)
                        .onClick(() => {
                            this.seekTo(this.scrollTargetTime)
                            this.userScrolling = false
                        })
                }
                .width('95%')
                .height(42)
                .border({ radius: 8 })
                .backgroundColor('#808d8d8d')
            }
        }
        .width('100%')
        .height('100%')
    }

    onPlayerPositionUpdate(position: number) {
        this.controller.updatePosition(position)
    }

    seekTo(position: number) {
        // player.seekTo(position)
        this.controller.updatePosition(position)
    }
}

function duration2Text(duration: number): string {
    const totalSeconds = Math.floor(duration / 1000)
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    return minutes.toString().padStart(2, '0') + ':' + seconds.toString().padStart(2, '0')
}

function parseLyric(): Lrc {
    return {
        lyricList: [
            { text: '第一句歌词', beginTime: 0, endTime: 3000 },
            { text: '第二句歌词', beginTime: 3000, endTime: 6000 }
        ]
    }
}
```

## 更多示例

- 更多使用场景可以参考本仓库的 `entry` 工程：https://github.com/seagazer/cclyric
- 播放器场景可以参考 `entry/src/main/ets/pages/CcLyricViewSample.ets`，该示例使用 `@seagazer/ccplayer` 搭配歌词组件构建播放页面。
- 自定义 seek UI 可以参考 `entry/src/main/ets/pages/CustomSeekUISample.ets`。
- 使用过程中存在任何相关问题欢迎提 Issue 和 PR，或者加群反馈：Q 群 1051643574。如果这个库对你有用，也欢迎给一个 star。
