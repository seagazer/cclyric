# cclyric

## 简介

**cclyric** 是一个为 **OpenHarmony** 和 **HaromonyOS** 的音乐播放歌词库。

- 支持歌词解析
- 支持歌词滚动显示
- 支持自定义样式，包括歌词字体大小/颜色，聚焦大小/颜色，显示模式等

## 依赖方式

```ts
ohpm install @seagazer/cclyric
```

## 接口能力

**cclyric** 提供**LyricParser **进行歌词解析， 视图组件 **LyricView** ，用户可以通过 **LyricController **来操作组件。用户也可以自己实现**IParser**接口编写自己的歌词解析业务。

### Lyric

歌词数据结构

| 属性      | 属性类型          | 属性说明     |
| --------- | ----------------- | ------------ |
| artist    | string            | 艺术家       |
| title     | string            | 标题         |
| album     | string            | 专辑         |
| by        | string            | 作者         |
| offset    | number            | 时间戳偏移量 |
| lyricList | Array\<LyricLine> | 歌词行数组   |

### LyricLine

单行歌词数据结构

| 属性      | 属性类型 | 属性说明             |
| --------- | -------- | -------------------- |
| text      | string   | 歌词内容             |
| beginTime | number   | 当前行歌词起始时间戳 |
| nextTime  | number   | 下一行歌词起始时间戳 |

### IParser

歌词解析接口

parse(src: Array\<string>): Lyric
解析歌词

| 参数 | 参数类型       | 参数说明       |
| ---- | -------------- | -------------- |
| src  | Array\<string> | 歌词文本行数组 |

### LyricController

LyricView 组件控制器

#### setLyric(lyric: Lyric): LyricController

设置歌词内容，需要通过提供的 LyricParser 或者自定义 IParser 解析歌词。

| 参数  | 参数类型 | 参数说明 |
| ----- | -------- | -------- |
| lyric | Lyric    | 歌词     |

#### updatePosition(mediaPosition: number)

更新媒体播放进度，组件会自动刷新歌词显示。

| 参数          | 参数类型 | 参数说明              |
| ------------- | -------- | --------------------- |
| mediaPosition | number   | 媒体播放进度(单位 ms) |

#### setTextSize(textSize: number): LyricController

设置歌词文本尺寸，默认为 18px。

| 参数     | 参数类型 | 参数说明              |
| -------- | -------- | --------------------- |
| textSize | number   | 歌词文本尺寸(单位 px) |

#### setTextColor(color: string): LyricController

设置歌词文本普通颜色，默认为#80000000。

| 参数  | 参数类型 | 参数说明     |
| ----- | -------- | ------------ |
| color | string   | 文本普通颜色 |

#### setHighlightColor(color: string): LyricController

设置歌词文本聚焦颜色，当前播放的歌词属于聚焦状态，默认为#000000。

| 参数  | 参数类型 | 参数说明     |
| ----- | -------- | ------------ |
| color | string   | 文本聚焦颜色 |

#### setHighlightScale(scale: number): LyricController

设置歌词文本聚焦缩放，当前播放的歌词属于聚焦状态，默认为 1.2f。

| 参数  | 参数类型 | 参数说明         |
| ----- | -------- | ---------------- |
| scale | number   | 文本聚焦缩放比例 |

#### setHighlightStyle(isBold: boolean): LyricController

设置歌词文本聚焦时是否粗体，当前播放的歌词属于聚焦状态，默认为 true。

| 参数   | 参数类型 | 参数说明           |
| ------ | -------- | ------------------ |
| isBold | boolean  | 文本聚焦时是否粗体 |

#### setEdgeColor(color: string): LyricController

设置歌词上下边缘渐变颜色，默认为#ffffff。

| 参数  | 参数类型 | 参数说明         |
| ----- | -------- | ---------------- |
| color | string   | 歌词边缘渐变颜色 |

#### setLineSpace(lineSpace: number): LyricController

设置歌词行间距，默认为 16px。

| 参数      | 参数类型 | 参数说明            |
| --------- | -------- | ------------------- |
| lineSpace | number   | 歌词行间距(单位 px) |

#### setAnimationDuration(duration: number): LyricController

设置歌词滚动动效时长，默认为 300ms。

| 参数     | 参数类型 | 参数说明                  |
| -------- | -------- | ------------------------- |
| duration | number   | 歌词滚动动效时长(单位 ms) |

#### setCacheSize(cacheSize: number): LyricController

设置歌词绘制的缓存量，在屏幕外会预绘制一定数量的歌词，提升上下滑动的显示性能，默认为 2 行。

| 参数      | 参数类型 | 参数说明     |
| --------- | -------- | ------------ |
| cacheSize | number   | 绘制缓存行数 |

#### setEmptyHint(hint: string): LyricController

设置无歌词时的提示语，默认为`--`。

| 参数 | 参数类型 | 参数说明         |
| ---- | -------- | ---------------- |
| hint | string   | 无歌词时的提示语 |

#### setAlignMode(align: "left" | "center"): LyricController

设置歌词显示模式，目前支持居中显示和居左显示，默认为"left"左对齐显示。

| 参数  | 参数类型          | 参数说明     |
| ----- | ----------------- | ------------ |
| align | "left" ，"center" | 歌词显示模式 |

#### invalidate()

主动刷新重绘，该方法只会触发重新绘制，不会触发重新布局。

### LyricHelper

歌词工具类，支持根据媒体播放进度查询当前歌词。

#### setLyricData(data: Lyric)

设置歌词数据。

| 参数 | 参数类型 | 参数说明 |
| ---- | -------- | -------- |
| data | Lyric    | 歌词数据 |

#### getLyric(position: number): string

根据媒体播放进度，查询当前的歌词内容，返回当前歌词行文本。

| 参数     | 参数类型 | 参数说明     | 返回值         |
| -------- | -------- | ------------ | -------------- |
| position | number   | 媒体播放进度 | 当前歌词行文本 |

## 场景示例

- 下面是基础示例和使用方式：

```ts
@Entry
@Component
struct Index {
    // 1.初始化controller
    private lyricController: LyricController = new LyricController()
    private parser = new LyricParser()

    aboutToAppear() {
        // 2.自定义样式属性
        this.lyricController
            .setTextSize(24)
            .setCacheSize(4)
            .setTextColor("#8c000000")
            .setHighlightColor("#ff000000")
            .setLineSpace(16)
            .setHighlightStyle(false)
            .setEmptyHint("当前没有歌词")
            .setAlignMode("center")
        // 3.解析歌词
        let lyric = this.parser.parse(MockData.src1)
        // 4.设置歌词
        this.lyricController.setLyric(lyric)
    }

    build() {
        Column() {
            LyricView({ controller: this.lyricController, })
                .width("100%")
                .layoutWeight(1)
                .padding({ left: 16, right: 16 })

                ...
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
    }
}
```

- 更多使用场景和示例，可以参考本库代码仓的 entry 工程：https://github.com/seagazer/cclyric
- 配合播放器使用的复杂示例，可以参考完整音乐播放器项目：https://github.com/seagazer/cclisten
