# 歌词库重构方案说明

> 项目：`cclyric`
>
> 范围：歌词展示组件、歌词时间线构建、滚动协调、逐词高亮、布局测量
>
> 目的：对比重构前后实现，说明问题、方案、收益与后续建议

## 1. 背景

当前歌词库的核心入口是 `CcLyricView`，它负责接收 controller 回调、构建歌词数据、处理滚动交互、控制高亮动画、以及完成最终渲染。

在重构之前，`CcLyricView` 实际上承担了多个职责：

- 控制器状态接入
- 数据源构建
- 文本换行测量
- KRC 按词拆分
- 时间轴生成
- 滚动/seek 交互状态处理
- 焦点行高亮切换
- 自动恢复定时器管理

这导致单个文件中的业务密度非常高，后续维护时容易出现：

- 修改一个功能时影响其它功能
- 状态流不清晰
- 测量逻辑和视图逻辑相互耦合
- 边界条件难以单独验证

本次重构的目标不是重写全部功能，而是把现有可用实现拆成更清晰的职责边界，降低耦合，提升可维护性和可扩展性。

---

## 2. 重构前的结构问题

### 2.1 `CcLyricView` 职责过载

重构前，`CcLyricView` 中包含了以下逻辑：

- `aboutToAppear()` 中绑定 controller 回调
- `setDataSource()` 中构建数据源
- `checkBreakLine()` 中做文本测量和换行
- `splitWordsByLines()` 中做 KRC 按词拆分
- `resolveFocusIndex()` 中做播放进度定位
- `updatePosition()` 中做高亮状态切换
- `changeFocusLine()` 中做焦点行替换与滚动联动
- touch/scroll 事件中管理用户拖动状态和恢复计时器

这使得 `CcLyricView` 同时是：

- 视图容器
- 歌词解析器
- 时间线生成器
- 交互状态机
- 滚动协调器

### 2.2 时间线数据与视图对象强耦合

重构前，时间线结构里直接存储了 `LrcLineView`：

- `LyricTimelineItem { beginTime, endTime, view }`

这意味着：

- 数据结构和 UI 对象绑定在一起
- 时间轴无法纯粹表示“歌词片段”
- 单元测试和逻辑验证不方便
- 后续增加缓存、虚拟化或复用会比较困难

### 2.3 KRC 多行拆分逻辑不够稳

重构前的 KRC 多行处理主要依赖：

- `Paragraph` 计算换行
- `splitWordsByLines()` 按文本前缀匹配词列表
- 通过匹配结果回推出每行 `beginTime` / `endTime`

这个流程存在几个风险：

- 某一行匹配失败时会退化推进 `wordIndex`
- 拆分结果与实际行数不一致时，可能导致范围错位
- 词数不足、标点、空格、特殊字符都会影响匹配结果
- 生成的子行时间可能与显示文本不严格一致

### 2.4 用户滚动状态存在竞态风险

重构前，以下事件都会影响 `isUserMoving` 和恢复定时器：

- `onScrollStart`
- `onScrollStop`
- `onTouch(Down/Up/Cancel)`

这些分支中有不同的 `setTimeout` 和 `clearTimeout` 时机，若用户快速拖动或连续触摸，可能出现：

- seek 条显示闪烁
- 自动恢复时机不一致
- 状态残留

### 2.5 `LrcLineView` 同时承担渲染和动画控制

`LrcLineView` 中既有：

- `NodeController` 的视图生命周期管理
- `RenderNode` 的绘制逻辑
- KRC 逐词动画的播放控制
- 字体、颜色、高亮、对齐的配置更新

这会让“单行歌词视图”既是渲染器，也是动画状态机。

---

## 3. 重构后的总体架构

本次重构后，歌词库拆成了更清晰的四层：

### 3.1 视图容器层

- `CcLyricView`

职责：

- 接收 controller 的输入
- 组织 UI 结构
- 触发数据重建
- 触发滚动和高亮更新
- 维护最少量的页面级状态

### 3.2 布局与时间线构建层

- `LyricLayoutService`
- `LyricDisplayLine`

职责：

- 根据宽度和字体大小计算换行
- 将 `LrcLine` 转换为可渲染展示行
- 处理 LRC / KRC 的时间拆分
- 提供缓存与容错

### 3.3 滚动与交互协调层

- `LyricScrollCoordinator`
- `LyricTimelineItem`

职责：

- 管理用户拖动与自动恢复状态
- 管理焦点行切换
- 负责播放进度到索引的映射
- 统一滚动行为，避免 UI 内部竞态

### 3.4 单行歌词渲染层

- `LrcLineView`

职责：

- 单行歌词内容绘制
- LRC / KRC 颜色与高亮表现
- KRC 逐词动画播放
- 局部渲染状态管理

---

## 4. 重构前后对比

### 4.1 组件职责对比

| 模块 | 重构前 | 重构后 |
|---|---|---|
| `CcLyricView` | 视图 + 数据构建 + 换行 + 拆词 + 定位 + 滚动状态 + 高亮切换 | 仅负责容器编排、事件接入和少量页面状态 |
| `LrcLineView` | 渲染 + 动画 + 配置更新 | 仍负责单行渲染与动画，但状态更稳定、边界更清晰 |
| 时间线 | 存 `LrcLineView` | 以纯数据为主，视图与时间轴解耦 |
| 滚动控制 | 分散在多个事件中 | 收敛到 `LyricScrollCoordinator` |
| 布局测量 | 内嵌在组件中 | 下沉到 `LyricLayoutService` |

### 4.2 数据流对比

#### 重构前

`controller -> CcLyricView -> 文本测量 -> 拆词 -> 创建视图 -> 构建时间线 -> 更新高亮 -> 滚动定位`

#### 重构后

`controller -> CcLyricView -> LyricLayoutService -> LyricDisplayLine / LyricTimelineItem -> LyricScrollCoordinator -> LrcLineView`

重构后的路径更清楚：

- 先产出数据
- 再由协调器处理状态
- 最后交给渲染层表现

### 4.3 状态管理对比

#### 重构前

状态分散在 `CcLyricView`：

- `focusIndex`
- `centerLrcLine`
- `isUserMoving`
- `userMoveTimeout`
- `focusView`
- `playPosition`
- `isDataSourceReady`

#### 重构后

状态被拆分：

- 页面态留在 `CcLyricView`
- 交互态收敛到 `LyricScrollCoordinator`
- 展示行内容进入 `LyricDisplayLine`
- 时间索引进入 `LyricTimelineItem`

这样避免一个类同时持有太多状态分支。

---

## 5. 当前重构结果说明

### 5.1 新增的数据结构

#### `LyricDisplayLine`

作用：描述“可展示的一行歌词”，包含：

- 原始 `LrcLine`
- 起止时间
- 是否是 KRC
- 源行拆分位置

优点：

- 数据更纯
- 便于后续缓存和调试
- 支持更多布局信息扩展

#### `LyricTimelineItem`

作用：描述时间轴上的一个可定位片段，包含：

- `beginTime`
- `endTime`
- `view`
- `displayLine`

优点：

- 时间轴和 UI 绑定关系更明确
- 为后续改成纯数据时间线留下空间

### 5.2 新增的服务

#### `LyricLayoutService`

已经实现的能力：

- 文本测量缓存
- 单行 / 多行换行处理
- LRC 平均时长拆分
- KRC 按词拆分
- 容错回退

补强点：

- 空参数保护
- 缓存键封装
- 测量失败兜底
- KRC 词列表为空时回退到普通 LRC 逻辑

#### `LyricScrollCoordinator`

已经实现的能力：

- 统一管理 `isUserMoving`
- 统一管理恢复定时器
- `resolveFocusIndex()` 边界判定更明确
- 焦点行切换时只负责协调，不负责视图细节

补强点：

- `onScrollStop` / `onTouchDown` / `onTouchEnd` 都先清 timer
- 防止拖动状态叠加

### 5.3 `LrcLineView` 补强

已经做了以下调整：

- 修正普通 LRC 更新分支中的无效早返回
- KRC 动画增加边界保护
- `stop()` 时重置 `lastWordPosition`
- 文本宽高测量增加下限保护
- 把文本宽度测量封装成独立函数
- 对 0 时长动画做保护

---

## 6. 重构方案的落地顺序

如果按项目演进节奏继续推进，建议顺序如下：

### 第 1 步 纯数据化

目标：继续减少 UI 对业务逻辑的依赖。

要做的事：

- 让时间线只表达数据，不表达渲染对象
- 为 `LyricTimelineItem` 增加更清晰的语义字段
- 视图对象通过索引或映射获取，而不是直接嵌入时间线

### 第 2 步 布局和拆词独立化

目标：让换行和 KRC 拆分可单独验证。

要做的事：

- 把测量结果缓存做完整
- KRC 拆分增加更多回退策略
- 对异常歌词、超长文本、空词列表做稳定处理

### 第 3 步 状态机统一

目标：消除滚动与 seek 的竞态。

要做的事：

- 把 `playing / userScrubbing / awaitingRecover / idle` 显式化
- 统一 timer 生命周期
- 在状态恢复时补一次稳定定位

### 第 4 步 渲染层继续拆分

目标：让单行渲染职责更单纯。

要做的事：

- 将 LRC 和 KRC 的渲染逻辑分成独立实现
- 让逐词动画只负责 KRC 表现
- 普通 LRC 只做高亮和静态绘制

### 第 5 步 回归测试

至少覆盖以下场景：

- 普通 LRC 单行
- 普通 LRC 多行
- KRC 单词精确匹配
- KRC 多行拆分
- 空歌词
- 超长歌词
- 宽度变化
- 字号变化
- 手动拖动 seek
- 快速切歌

---

## 7. 仍然存在的可继续优化点

虽然当前重构已经明显改善结构，但仍有一些进一步优化方向：

### 7.1 `LrcLineView` 仍然较重

它仍然同时负责：

- 渲染
- KRC 动画
- 布局测量适配

后续可进一步拆出：

- `LrcTextRenderer`
- `KrcAnimatorController`

### 7.2 `LyricLayoutService` 的拆词策略还可更严格

当前策略已经比之前稳定，但还可以继续增强：

- 更完整的标点和空格归一化
- 对中英文混排做更细粒度处理
- 拆分失败时提供“退化但不越界”的方案

### 7.3 缓存策略还可继续扩展

当前缓存已按：

- 文本
- 宽度
- 字号

进行控制。

后续还可以把以下因素纳入缓存键：

- 对齐模式
- 字体资源变化
- 高亮缩放比例

### 7.4 视图层仍可继续瘦身

`CcLyricView` 现在已经比重构前清晰很多，但如果继续优化，可以把：

- seek 条
- 空状态
- fade overlay
- 歌词列表

拆成更独立的 builder 或子组件。

---

## 8. 这次重构带来的收益

### 8.1 可维护性提升

最直接的收益是：职责边界清晰了。

- 需要改布局时，去 `LyricLayoutService`
- 需要改滚动策略时，去 `LyricScrollCoordinator`
- 需要改单行表现时，去 `LrcLineView`
- 需要改页面结构时，去 `CcLyricView`

### 8.2 风险降低

以前一个函数里改动，可能会影响多个功能；现在改动被分散到对应模块后，回归范围更小。

### 8.3 后续扩展更容易

未来如果要增加：

- 新的歌词格式
- 新的动画表现
- 虚拟列表优化
- 更复杂的歌词样式

都可以在当前分层基础上继续演进。

### 8.4 性能优化入口更明确

当前已经把最容易优化的点暴露出来：

- 文本测量缓存
- 时间轴纯数据化
- 滚动状态集中管理
- 减少无效视图更新

---

## 9. 结论

这次重构的核心不是“把代码拆散”，而是把原来混在 `CcLyricView` 里的几类职责，重新归位到更合适的层次。

重构前，歌词库更像一个“功能完整但耦合较重的组件”；
重构后，它已经更接近一个“可扩展的歌词渲染引擎”。

当前结果已经解决了最关键的问题：

- 数据和视图耦合过紧
- 滚动与 seek 状态竞态
- KRC 拆分与换行逻辑不清晰
- 单行渲染与动画职责过重

后续如果继续推进，建议沿着“数据纯化、状态统一、渲染拆分、缓存增强”这四条主线迭代。
