# cclyric

## 简介

**cclyric** 是一个为 **OpenHarmony** 和 **HarmonyOS** 设计的音乐歌词组件库。

- 支持逐字歌词(卡拉ok效果)
- 支持逐行歌词
- 支持歌词滚动显示
- 支持自定义样式，包括歌词行距，字体大小/颜色，聚焦大小/颜色等

## 示例效果

## 示例效果
| 逐字歌词                                                                          | 逐行歌词                                                                          | 自定义样式                                                                        |
| --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| <img src="https://s21.ax1x.com/2025/09/28/pVoZ0KJ.jpg" width="180" height="360"/> | <img src="https://s21.ax1x.com/2025/09/28/pVoZ28O.jpg" width="180" height="360"/> | <img src="https://s21.ax1x.com/2025/09/28/pVoZyUx.jpg" width="180" height="360"/> |

## 注意事项

- 从 1.0.8 版本开始，新增逐字歌词能力，新增了 CcLyricView 组件和 CcLrcController 控制器，取缔之前的 LyricView（不再维护）。
- 从 1.0.8 版本开始，不再提供默认的歌词解析器，建议提供数据源格式和Lrc数据结构，使用AI工具编写解析代码。

## 依赖方式

```ts
ohpm install @seagazer/cclyric
```

## 接口能力

**cclyric** 提供视图组件 **CcLyricView**，用户可以通过 **CcLyricController** 来操作组件。

### Lrc

歌词数据结构

| 属性      | 属性类型        | 属性说明     |
| --------- | --------------- | ------------ |
| artist    | string          | 艺术家       |
| title     | string          | 标题         |
| album     | string          | 专辑         |
| by        | string          | 作者         |
| offset    | number          | 时间戳偏移量 |
| lyricList | Array\<LrcLine> | 歌词行数组   |

### LrcLine

单行歌词数据结构

| 属性      | 属性类型               | 属性说明                                     |
| --------- | ---------------------- | -------------------------------------------- |
| text      | string                 | 歌词内容                                     |
| beginTime | number                 | 当前行歌词起始时间戳                         |
| endTime   | number                 | 当前行歌词结束时间戳                         |
| wordList  | LrcWord[] \| undefined | 单个字的时间信息，Lrc逐行歌词场景为undefined |

### LrcWord

单个字数据结构

| 属性      | 属性类型 | 属性说明         |
| --------- | -------- | ---------------- |
| text      | string   | 字符文本         |
| beginTime | number   | 该字符起始时间戳 |
| endTime   | number   | 该字符结束时间戳 |

### CcLyricController

CcLyricView 组件控制器

#### setDebugger(debug: boolean): void

设置是否开启调试日志，默认false

| 参数  | 参数类型 | 参数说明 |
| ----- | -------- | -------- |
| lyric | Lrc      | 歌词     |

#### setLyric(lyric: Lrc| undefined): void

设置歌词内容，需要通过提供的 LyricParser 或者自定义 IParser 解析歌词。

| 参数  | 参数类型        | 参数说明                    |
| ----- | --------------- | --------------------------- |
| lyric | Lrc \|undefined | 歌词，没有歌词设置undefined |

#### setEmptyHint(hint: ResourceStr): CcLyricController

设置无歌词时的提示语，默认为`--`。

| 参数 | 参数类型    | 参数说明         |
| ---- | ----------- | ---------------- |
| hint | ResourceStr | 无歌词时的提示语 |

#### setFadeColor(color: ResourceColor): CcLyricController

设置歌词上下边缘渐变颜色，默认为#00ffffff

| 参数  | 参数类型      | 参数说明         |
| ----- | ------------- | ---------------- |
| color | ResourceColor | 歌词边缘渐变颜色 |

#### setTextSize(textSize: number): CcLyricController

设置歌词文本尺寸，默认为 20vp。**注意：该属性暂不支持动态设置，在绑定CcLyricView前请设置。**

| 参数     | 参数类型 | 参数说明              |
| -------- | -------- | --------------------- |
| textSize | number   | 歌词文本尺寸(单位 vp) |

#### setTextColor(color: number): CcLyricController

设置歌词文本普通颜色，默认为0xff000000。

| 参数  | 参数类型 | 参数说明     |
| ----- | -------- | ------------ |
| color | number   | 文本普通颜色 |

#### setHighlightColor(color: number): CcLyricController

设置歌词文本聚焦颜色，当前播放的歌词属于聚焦状态，默认为0xffff0000。

| 参数  | 参数类型 | 参数说明     |
| ----- | -------- | ------------ |
| color | number   | 文本聚焦颜色 |

#### setHighlightScale(scale: number): CcLyricController

设置歌词文本聚焦缩放，当前播放的歌词属于聚焦状态，默认为 1.1f。

| 参数  | 参数类型 | 参数说明         |
| ----- | -------- | ---------------- |
| scale | number   | 文本聚焦缩放比例 |

#### setLineSpace(lineSpace: number): CcLyricController

设置歌词行间距，默认为 12vp。

| 参数      | 参数类型 | 参数说明            |
| --------- | -------- | ------------------- |
| lineSpace | number   | 歌词行间距(单位 vp) |

#### updatePosition(position: number)

更新媒体播放进度，组件会自动刷新歌词显示。

| 参数     | 参数类型 | 参数说明              |
| -------- | -------- | --------------------- |
| position | number   | 媒体播放进度(单位 ms) |


### CcLyricView

歌词组件

| 属性       | 属性类型          | 属性说明       | 必填 |
| ---------- | ----------------- | -------------- | ---- |
| controller | CcLyricController | 歌词组件控制器 | 是   |


## 场景示例

- 下面是基础示例和使用方式：

```ts
@Entry
@ComponentV2
struct Index {
    @Local lyric?: Lrc = undefined
    // 1.init the controller
    private controller: CcLrcController = new CcLrcController()

    aboutToAppear(): void {
        // 2. setup the attribute
        this.controller.setDebugger(true)
        this.controller.setTextSize(18)
            .setLineSpace(12)
            .setTextColor(0xCC000000)
            .setTextHighlightColor(0xffe7107f)
            .setFadeColor("#ffffffff")
        this.lyric = this.parser.parse(MockData.krc1)
        // 3. set the lyric
        this.controller.setLyric(this.lyric)
    }

    build() {
        Column() {
            // 4. init the view
            CcLyricView({
                controller: this.controller
            })
            .width("100%")
            .height("100%)
        }
        .height('100%')
        .width('100%')
    }

    onPlayerPositionUpdate(position: number) {
        // 5. update the mediaplayer position
        this.controller.updatePosition(position)
    }
}    
```

- 更多使用场景和示例，可以参考本库代码仓的 entry 工程：  https://github.com/seagazer/cclyric
- 播放器场景，推荐使用@seagazer/ccplayer搭配（三方库中心仓地址https://ohpm.openharmony.cn/#/cn/detail/@seagazer%2Fccplayer） ，可以快捷构建媒体播放应用
- 使用过程中存在任何相关问题欢迎各位开发者提Issue和PR，或者加群反馈（Q群:1051643574），欢迎大家一起共建完善该库，如果觉得对你有用，请给个star鼓励一下谢谢。
