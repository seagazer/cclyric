# 1.1.2
- 支持动态调整字体大小，行距，缩放等尺寸参数
- 基于新版本Api进行LyricView重构
- 新增setKrcTextBgColor接口可以单独设置高亮行的字体颜色
- 新增setTopOffset接口可以设置首行歌词距离顶部距离
- 修复英文单词和字符带空格时逐字歌词断行异常问题
- 修复seek后概率停留在seek前位置显示的问题
- 修复seek滑动指示器部分场景显示异常问题

# 1.1.1
- 修复CcLyricView组件在播放进度非0时初次显示也会从顶部开始显示问题
- 重构逐字歌词动画逻辑，动效更加平滑精准
- 歌词边缘渐变修改为使用blendMode实现(仅支持api12+)
- CcLyricController废弃setFadeColor接口,新增setFadeEnable接口
- CcLyricController新增setFadePercent接口设置渐变高度占比
- CcLyricController废弃setLrcAnimDuration接口,动画时长由库内部动态修改
- 兼容版本提升至14，编译版本提升至21

# 1.1.0
- 新增setLrcAnimDuration接口，设置逐字歌词动效时长
- 优化部分细节

# 1.0.9
- 重构动画，增加动画缓存池，性能提升
- 新增setAlignMode接口，支持歌词左对齐和居中显示模式
- 新增onScrollChanged和onScrollStateChanged接口，支持自定义seek界面
- CcLyricView新增onDataSourceReady数据加载完成回调
- 修复updatePosition在数据未加载完成前调用可能发生异常问题
- 完善接口注释，增加接口注意事项

# 1.0.8
- 新增CcLyricView组件和CcLrcController控制器
- 新增Lrc数据结构，配合CcLyricView使用
- 支持卡拉ok逐字歌词效果
- 歌词组件性能大幅增强
- 废弃LyricView和LyricView2

# 1.0.7
- 适配OpenHarmony 5.0-Release和HarmonyOS Next

# 1.0.6
- 性能优化
- LyricView2增加设置滑动seek样式选择接口
- LyricView2增加抖音汽水音乐seek样式效果

# 1.0.5

- 修复FileParser接口对外未暴露问题

# 1.0.4

- 新增seek定位线条颜色设置
- 新增歌词文件解析器FileParser
- 动效优化
- 适配4.1release-Api11

# 1.0.3

- 新增seek定位按钮和文本颜色设置
- 修改默认属性值

# 1.0.2

- 新增LyricView2组件
- LyricView2支持歌词滑动查看
- LyricView2支持歌词滑动seek视图
- LyricView2支持歌词滑动快进快退至目标时间戳
- 修复一些问题

# 1.0.1

- 新增实时动态刷新能力
- 修复一些问题

# 1.0.0

- 支持歌词解析
- 支持歌词滚动显示
- 支持自定义样式，包括歌词字体大小/颜色，聚焦大小/颜色，显示模式等
