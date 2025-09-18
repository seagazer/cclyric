import { AnimatorResult, DrawContext, FrameNode, NodeController, RenderNode, Size, UIContext } from '@kit.ArkUI';
import { common2D, drawing } from '@kit.ArkGraphics2D';
import { ListAdapter } from '@seagazer/cclyric/src/main/ets/extensions/ListAdapter';

const src1 = [
    "[ar:G.E.M. 邓紫棋、张靓颖]",
    "[ti:雨蝶 (Live)]",
    "[offset:0]",
    "[tool:LDDC v0.9.2 https://github.com/chenmozhijin/LDDC]",
    "[00:00.000]G[00:00.178].[00:00.356]E[00:00.534].[00:00.713]M[00:00.891].[00:01.069] [00:01.248]邓[00:01.426]紫[00:01.604]棋[00:01.783]、[00:01.961]张[00:02.139]靓[00:02.318]颖[00:02.496] [00:02.674]-[00:02.853] [00:03.031]雨[00:03.209]蝶[00:03.388] [00:03.566]([00:03.744]L[00:03.923]i[00:04.101]v[00:04.279]e[00:04.457])[00:04.636]",
    "[00:04.636]作[00:04.814]词[00:04.992]：[00:05.171]许[00:05.349]常[00:05.527]德[00:05.706]、[00:05.884]琼[00:06.062]瑶[00:06.241]",
    "[00:06.241]作[00:06.419]曲[00:06.597]：[00:06.776]张[00:06.954]宇[00:07.132]",
    "[00:07.132]原[00:07.311]唱[00:07.489]：[00:07.667]李[00:07.846]翊[00:08.024]君[00:08.202]",
    "[00:08.202]音[00:08.380]乐[00:08.559]总[00:08.737]监[00:08.915]：[00:09.094]楼[00:09.272]恩[00:09.450]奇[00:09.629]",
    "[00:09.629]定[00:09.807]位[00:09.985]制[00:10.164]作[00:10.342]人[00:10.520]：[00:10.699]刘[00:10.877]洲[00:11.055]",
    "[00:11.055]编[00:11.234]曲[00:11.412]：[00:11.590]宋[00:11.768]阳[00:11.947]",
    "[00:11.947]吉[00:12.125]他[00:12.303]：[00:12.482]王[00:12.660]传[00:12.838]统[00:13.017]",
    "[00:13.017]弦[00:13.195]乐[00:13.373]：[00:13.552]国[00:13.730]际[00:13.908]首[00:14.087]席[00:14.265]爱[00:14.443]乐[00:14.622]乐[00:14.800]团[00:14.978]",
    "[00:14.978]张[00:15.157]靓[00:15.335]颖[00:15.513]：[00:15.691]",
    "[00:15.692]爱[00:16.272]到[00:16.552]心[00:17.222]破[00:17.502]碎[00:18.212]也[00:18.492]别[00:18.842]去[00:19.152]怪[00:19.462]谁[00:20.052]",
    "[00:20.072]只[00:20.452]因[00:20.832]为[00:20.992]相[00:21.492]遇[00:21.982]太[00:22.382]美[00:22.752]",
    "[00:23.592]就[00:23.922]算[00:24.292]流[00:24.642]干[00:24.972]泪[00:25.202]伤[00:25.612]到[00:25.912]底[00:26.122]",
    "[00:26.142]心[00:26.542]成[00:26.872]灰[00:27.252]也[00:27.482]无[00:27.792]所[00:28.262]谓[00:29.322]",
    "[00:30.822]我[00:31.632]破[00:31.992]茧[00:32.712]成[00:33.112]蝶[00:33.682]愿[00:34.012]和[00:34.362]你[00:34.572]双[00:34.992]飞[00:35.322]",
    "[00:35.582]最[00:35.912]怕[00:36.312]你[00:36.602]会[00:37.042]一[00:37.162]去[00:37.562]不[00:37.912]回[00:38.492]",
    "[00:39.112]虽[00:39.492]然[00:39.862]爱[00:40.122]过[00:40.572]我[00:40.742]给[00:41.082]过[00:41.442]我[00:41.612]",
    "[00:41.632]想[00:42.092]过[00:42.422]我[00:42.642]就[00:42.962]是[00:43.402]安[00:43.682]慰[00:44.952]",
    "[00:46.462]我[00:46.802]向[00:47.302]你[00:47.562]飞[00:48.402]雨[00:48.522]温[00:48.842]柔[00:49.142]的[00:49.372]坠[00:49.922]",
    "[00:50.312]像[00:50.772]你[00:51.072]的[00:51.442]拥[00:52.052]抱[00:52.392]把[00:52.782]我[00:53.032]包[00:53.362]围[00:53.842]",
    "[00:54.152]我[00:54.432]向[00:54.942]你[00:55.152]飞[00:55.892]多[00:56.242]远[00:56.582]都[00:56.872]不[00:57.262]累[00:57.632]",
    "[00:57.832]虽[00:58.232]然[00:58.602]旅[00:58.872]途[00:59.182]中[00:59.812]有[01:00.142]过[01:00.472]痛[01:00.832]和[01:01.172]泪[01:01.612]",
    "[01:01.892]我[01:02.302]向[01:02.782]你[01:03.032]追[01:03.692]风[01:04.032]温[01:04.362]柔[01:04.662]的[01:04.892]吹[01:05.412]",
    "[01:05.872]只[01:06.312]要[01:06.632]你[01:07.042]无[01:07.562]怨[01:07.932]我[01:08.272]也[01:08.572]无[01:08.892]悔[01:09.362]",
    "[01:09.792]爱[01:10.022]是[01:10.482]那[01:10.792]么[01:11.442]美[01:11.752]我[01:12.042]心[01:12.412]陶[01:12.722]醉[01:13.182]",
    "[01:13.412]被[01:13.832]爱[01:14.352]的[01:14.662]感[01:15.092]觉[01:17.892]",
    "[01:17.892]G[01:18.440].[01:18.989]E[01:19.538].[01:20.087]M[01:20.636].[01:21.185] [01:21.734]邓[01:22.283]紫[01:22.832]棋[01:23.381]：[01:23.929]",
    "[01:49.033]爱[01:49.235]到[01:49.492]心[01:50.106]破[01:50.410]碎[01:51.121]也[01:51.427]别[01:51.730]去[01:52.035]怪[01:52.389]谁[01:52.543]",
    "[01:52.940]只[01:53.380]因[01:53.680]为[01:53.890]相[01:54.380]遇[01:54.810]太[01:55.250]美[01:55.840]",
    "[01:56.530]就[01:56.780]算[01:57.190]流[01:57.540]干[01:57.860]泪[01:58.080]伤[01:58.510]到[01:58.830]底[01:59.010]",
    "[01:59.030]心[01:59.470]成[01:59.800]灰[02:00.130]也[02:00.500]无[02:00.630]所[02:01.080]谓[02:02.090]",
    "[02:04.296]我[02:04.606]破[02:04.886]茧[02:05.506]成[02:05.936]蝶[02:06.586]愿[02:06.906]和[02:07.216]你[02:07.416]双[02:07.816]飞[02:08.216]",
    "[02:08.476]最[02:08.826]怕[02:09.156]你[02:09.476]会[02:09.996]一[02:10.016]去[02:10.406]不[02:10.756]回[02:11.186]",
    "[02:11.996]虽[02:12.366]然[02:12.786]爱[02:13.036]过[02:13.376]我[02:13.646]给[02:13.996]过[02:14.336]我[02:14.486]",
    "[02:14.506]想[02:14.956]过[02:15.306]我[02:15.576]就[02:15.886]是[02:16.306]安[02:16.576]慰[02:18.576]",
    "[02:19.486]我[02:19.656]向[02:20.126]你[02:20.386]飞[02:21.306]雨[02:21.416]温[02:21.726]柔[02:22.076]的[02:22.286]坠[02:23.076]",
    "[02:23.256]像[02:23.676]你[02:23.996]的[02:24.296]拥[02:24.936]抱[02:25.286]把[02:25.676]我[02:25.906]包[02:26.256]围[02:26.876]",
    "[02:27.216]我[02:27.386]向[02:27.866]你[02:28.076]飞[02:28.766]多[02:29.146]远[02:29.466]都[02:29.806]不[02:30.086]累[02:30.516]",
    "[02:30.676]虽[02:31.086]然[02:31.426]旅[02:31.696]途[02:31.996]中[02:32.676]有[02:33.006]过[02:33.276]痛[02:33.726]和[02:33.956]泪[02:34.736]",
    "[02:34.946]我[02:35.166]向[02:35.626]你[02:35.876]追[02:36.566]风[02:36.926]温[02:37.206]柔[02:37.556]的[02:37.756]吹[02:38.536]",
    "[02:38.756]只[02:39.166]要[02:39.446]你[02:39.836]无[02:40.436]怨[02:40.756]我[02:41.106]也[02:41.606]无[02:41.676]悔[02:42.416]",
    "[02:42.716]爱[02:42.916]是[02:43.326]那[02:43.656]么[02:44.276]美[02:44.646]我[02:44.846]心[02:45.256]陶[02:45.546]醉[02:46.016]",
    "[02:46.216]被[02:46.626]爱[02:46.896]的[02:47.206]感[02:47.496]觉[02:50.466]",
    "[02:50.466]张[02:58.206]靓[03:05.946]颖[03:13.686]：[03:21.426]",
    "[03:21.426]我[03:21.586]向[03:22.116]你[03:22.326]飞[03:23.136]雨[03:23.366]温[03:23.756]柔[03:24.066]的[03:24.296]坠[03:24.796]",
    "[03:25.156]像[03:25.656]你[03:25.936]的[03:26.296]拥[03:26.946]抱[03:27.256]把[03:27.666]我[03:27.926]包[03:28.296]围[03:28.986]",
    "[03:28.986]G[03:29.004].[03:29.022]E[03:29.040].[03:29.058]M[03:29.076].[03:29.095] [03:29.113]邓[03:29.131]紫[03:29.149]棋[03:29.167]：[03:29.185]",
    "[03:29.186]我[03:29.406]向[03:29.846]你[03:30.026]飞[03:30.736]多[03:31.106]远[03:31.416]都[03:31.696]不[03:32.096]累[03:32.466]",
    "[03:32.596]虽[03:33.036]然[03:33.386]旅[03:33.666]途[03:33.956]中[03:34.576]有[03:34.936]过[03:35.206]痛[03:35.596]和[03:35.896]泪[03:36.686]",
    "[03:36.686]合[03:36.786]：[03:36.886]",
    "[03:36.886]我[03:37.096]向[03:37.536]你[03:37.806]追[03:38.526]风[03:38.856]温[03:39.156]柔[03:39.476]的[03:39.716]吹[03:40.426]",
    "[03:40.706]只[03:41.106]要[03:41.396]你[03:41.796]无[03:42.376]怨[03:42.716]我[03:43.066]也[03:43.606]无[03:43.696]悔[03:44.356]",
    "[03:44.656]爱[03:44.816]是[03:45.266]那[03:45.596]么[03:46.216]美[03:46.586]我[03:46.796]心[03:47.196]陶[03:47.486]醉[03:47.916]",
    "[03:48.103]被[03:48.358]爱[03:48.869]的[03:49.225]感[03:49.531]觉[03:49.888]",
    "[03:52.228]被[03:52.484]爱[03:52.840]的[03:53.609]感[03:53.861]觉[03:54.115]",
    "[03:56.234]被[03:56.488]爱[03:56.743]的[03:57.046]感[03:57.300]觉[03:57.553]",
]

const src2: string[] = [
    "[00:36.549]ど[00:37.080]う[00:37.328]し[00:37.705]て[00:37.914]君[00:38.129]は [00:39.721]小[00:40.033]さ[00:40.329]な[00:40.790]手[00:41.235]で [00:42.224]伤[00:42.466]を[00:42.824]背[00:43.509]负[00:43.814]う[00:44.274]と[00:44.703]す[00:45.059]る[00:45.319]の[00:45.724]だ[00:45.946]ろ[00:46.199]う[00:47.382]",
    "[00:49.069]谁[00:49.764]か[00:50.474]の[00:50.929]た[00:51.289]め[00:51.484]だ[00:52.025]け[00:52.469]じ[00:52.727]ゃ[00:52.969]な[00:53.233]い [00:54.254]见[00:54.525]失[00:54.739]わ[00:55.111]な[00:55.490]い[00:55.859]で[00:57.196]",
    "[01:02.355]ど[01:02.946]う[01:03.311]し[01:03.498]て[01:03.771]仆[01:04.181]は [01:05.116]迷[01:05.441]い[01:05.891]な[01:06.307]が[01:06.718]ら [01:07.769]逃[01:08.144]げ[01:08.524]出[01:08.973]す[01:09.274]事[01:09.764]で[01:10.444]き[01:10.675]な[01:10.949]い[01:11.284]ん[01:11.504]だ[01:11.922]ろ[01:12.543]う[01:13.057]",
    "[01:14.146]望[01:14.706]む[01:15.766]の[01:16.055]は [01:17.006]光[01:18.008]さ[01:18.374]す [01:19.133]灯[01:20.015]を [01:22.711]灯[01:23.396]を[01:26.827]",
    "[01:28.770]FIND [01:29.700]THE [01:30.515]WAY [01:31.003]辉[01:31.265]く[01:32.485]空[01:32.825]に [01:33.830]手[01:34.161]は[01:34.425]届[01:34.945]か[01:35.240]な[01:35.705]く[01:35.960]て[01:36.320]も[01:36.645]",
    "[01:36.745]响[01:37.280]く [01:38.380]爱[01:38.890]だ[01:39.310]け[01:39.727]頼[01:41.260]り[01:41.935]に[01:42.423]",
    "[01:42.355]进[01:43.020]ん[01:43.693]だ[01:44.040]道[01:44.765]の[01:45.520]先 [01:45.956]光[01:46.390]が[01:46.831]见[01:47.066]つ[01:47.626]か[01:48.031]る[01:48.368]か[01:48.691]ら[01:51.175]",
    "[01:53.736]YOU [01:54.348]FIND [01:55.382]THE [01:55.761]WAY[01:57.915]",
    "[02:09.494]君[02:10.170]は[02:10.856]言[02:11.175]っ[02:11.681]た [02:12.231]长[02:12.777]い[02:13.134]梦[02:13.591]を[02:13.901]见[02:14.181]た [02:14.821]と[02:15.220]て[02:15.573]も[02:16.033]悲[02:16.391]し[02:16.821]い[02:17.236]梦[02:18.201]だ[02:18.591]っ[02:18.841]た[02:19.141]と[02:20.183]",
    "[02:22.240]そ[02:22.925]れ[02:23.172]で[02:23.734]も[02:24.175]そ[02:24.570]の[02:25.140]姿[02:26.212]は [02:27.245]少[02:27.808]し[02:28.235]も[02:28.516]昙[02:29.287]ら[02:29.537]な[02:29.785]い[02:31.280]",
    "[02:35.070]仆[02:35.855]は[02:36.510]言[02:36.855]っ[02:37.305]た [02:37.742]泣[02:38.227]い[02:38.532]て[02:38.922]い[02:39.189]い[02:39.467]ん[02:39.728]だ[02:40.022]と [02:40.912]ず[02:41.159]っ[02:41.522]と[02:41.734]傍[02:42.607]に[02:43.092]居[02:43.667]て[02:43.914]あ[02:44.152]げ[02:44.527]る[02:44.837]よ[02:45.861]",
    "[02:46.650]欲[02:47.760]し[02:48.758]い[02:49.081]の[02:49.300]は [02:49.890]抱[02:50.462]き[02:50.730]上[02:51.146]げ[02:51.520]る [02:52.010]手[02:52.882]を [02:55.523]手[02:55.992]を[02:59.636]",
    "[03:01.599]FIND [03:02.574]THE [03:03.336]WAY [03:03.839]言[03:04.100]叶[03:04.674]な[03:05.032]く[03:05.552]て[03:05.934]も [03:06.424]飞[03:06.689]ぶ[03:06.914]羽[03:07.514]は[03:07.864]な[03:08.354]く[03:08.674]て[03:08.999]も[03:09.236]",
    "[03:09.509]吹[03:10.059]き[03:10.340]出[03:10.551]す [03:11.009]风[03:11.578]に[03:12.059]负[03:12.454]け[03:13.007]ぬ[03:14.078]よ[03:14.294]う[03:14.544]に[03:15.076]",
    "[03:15.124]今[03:16.144]谁[03:16.551]よ[03:16.924]り[03:17.591]早[03:18.394]く [03:18.879]光[03:19.295]に[03:19.759]気[03:20.482]付[03:21.314]け[03:21.564]た[03:22.046]な[03:22.364]ら[03:24.108]",
    "[03:26.339]答[03:27.074]え[03:28.249]を[03:30.453]出[03:30.971]す[03:31.825]事 [03:32.251]き[03:32.783]っ[03:33.171]と[03:33.454]全[03:34.861]て[03:35.826]じ[03:36.816]ゃ[03:36.826]な[03:36.976]い[03:38.581]",
    "[03:40.683]焦[03:41.404]ら[03:41.700]な[03:42.039]く[03:42.579]て[03:44.519]い[03:44.895]い[03:45.224]ん[03:45.597]だ[03:45.949]よ [03:49.375]あ[03:49.773]な[03:50.709]た[03:51.553]も[03:55.107]",
    "[03:59.454]FIND [04:00.053]THE [04:00.924]WAY [04:01.538]辉[04:02.144]く[04:02.481]空[04:03.255]に [04:04.049]手[04:04.399]は[04:05.034]届[04:05.249]か[04:05.719]な[04:06.148]く[04:06.458]て[04:07.098]も[04:07.403]",
    "[04:07.109]响[04:07.683]く [04:09.023]爱[04:09.568]だ[04:09.968]け[04:10.688]赖[04:11.799]り[04:11.974]に[04:12.542]",
    "[04:12.696]进[04:13.335]ん[04:13.801]だ[04:14.376]道[04:14.956]の[04:15.567]先 [04:16.621]光[04:16.881]が[04:17.358]见[04:18.500]つ[04:18.946]か[04:19.270]る[04:19.811]か[04:20.110]ら[04:23.424]",
    "[04:24.957]FIND [04:25.730]THE [04:26.555]WAY [04:27.175]言[04:27.360]叶[04:27.985]な[04:28.365]く[04:28.700]て[04:29.127]も [04:29.865]飞[04:30.261]ぶ[04:30.464]羽[04:31.235]は[04:31.620]な[04:31.856]く[04:32.076]て[04:32.430]も[04:32.867]",
    "[04:32.751]吹[04:33.240]き[04:33.485]出[04:33.940]す [04:34.295]风[04:34.685]に[04:35.170]负[04:35.605]け[04:36.125]ぬ[04:37.120]よ[04:37.355]う[04:37.615]に[04:37.977]",
    "[04:38.245]进[04:38.955]ん[04:39.626]だ[04:39.927]道[04:40.625]の[04:40.926]先 [04:42.505]确[04:42.815]か[04:43.190]な[04:44.115]光[04:44.861]を[04:45.112]见[04:45.805]た"
];

class LrcDataSource extends ListAdapter<LrcLineView | undefined> {
    constructor() {
        super()
    }
}


export class LrcController {
    private currentPosition = 0
    private _textSize: number = 20
    private _lineSpace: number = 12
    private _lyric?: Lrc | undefined = undefined
    private _textColor: number = 0xff000000
    private _textHighlightColor: number = 0xffff0000
    private _emptyHint: ResourceStr = "没有歌词";
    private _fadeColor: ResourceColor = "#ffffffff";

    public set emptyHint(value: ResourceStr) {
        this._emptyHint = value;
        this.invalidate()
    }

    public get emptyHint(): ResourceStr {
        return this._emptyHint;
    }

    public set fadeColor(value: ResourceColor) {
        this._fadeColor = value;
        this.invalidate()
    }

    public get fadeColor(): ResourceColor {
        return this._fadeColor;
    }

    public set lyric(value: Lrc | undefined) {
        this._lyric = value
        this.onDataChanged?.(value)
        // todo lrc changed
    }

    public get lyric(): Lrc | undefined {
        return this._lyric
    }

    public set textSize(value: number) {
        this._textSize = value
        this.invalidate()
    }

    public get textSize(): number {
        return this._textSize
    }

    public set lineSpace(value: number) {
        this._lineSpace = value
        this.invalidate()
    }

    public get lineSpace(): number {
        return this._lineSpace
    }

    public set textColor(value) {
        this._textColor = value
        this.invalidate()
    }

    public get textColor() {
        return this._textColor
    }

    public set textHighlightColor(value: number) {
        this._textHighlightColor = value
        this.invalidate()
    }

    public get textHighlightColor(): number {
        return this._textHighlightColor
    }

    updatePosition(position: number) {
        this.currentPosition = position
        this.onProgressChanged?.(position)
    }

    private invalidate() {
        this.onAttributeChanged?.()
    }

    onProgressChanged?: (position: number) => void = undefined
    onAttributeChanged?: () => void = undefined
    onDataChanged?: (lyric: Lrc | undefined) => void = undefined
}

@Entry
@ComponentV2
struct Index {
    private timer = -1
    private scroller = new Scroller()
    @Local focusIndex: number = -1
    @Local userSeekIndex: number = -1
    @Local progress: number = 0
    @Local lrcDataSource?: LrcDataSource = undefined
    private focusView?: LrcLineView = undefined
    @Require @Param controller: LrcController = new LrcController()
    @Local lyric?: Lrc = undefined
    private middleLine = 0

    aboutToAppear(): void {
        // set controller
        this.controller.textSize = 18
        this.controller.lineSpace = 12
        this.controller.textColor = 0xCC000000
        this.controller.textHighlightColor = 0xffe7107f
        this.lyric = new SampleLyricParser().parse(src1)

        this.controller.onProgressChanged = (position) => {
            this.updatePosition(position)
        }
        this.controller.onDataChanged = (lrc) => {
            this.focusView = undefined
            this.lyric = lrc
        }
    }

    @Builder
    FadeOverlay() {
        Column()
            .width("100%")
            .height("100%")
            .hitTestBehavior(HitTestMode.Transparent)
            .backgroundColor(Color.Transparent)
            .linearGradient({
                angle: 0,
                colors: [[this.controller.fadeColor, 0], ["#00ffffff", 0.2], ["#00ffffff", 0.8], [this.controller.fadeColor, 1]],
                repeating: false
            })
    }

    build() {
        Column() {
            Stack() {
                if (this.lyric !== undefined && this.lrcDataSource !== undefined && this.lrcDataSource.totalCount() > 0) {
                    List({ scroller: this.scroller, space: this.controller.lineSpace }) {
                        LazyForEach(this.lrcDataSource, (krc: LrcLineView | undefined, index: number) => {
                            ListItem() {
                                if (krc && !krc.isEmpty()) {
                                    NodeContainer(krc)
                                        .width("100%")
                                        .height("100%")
                                } else {
                                    Stack()
                                        .width("100%")
                                        .height("100%")
                                }
                            }
                            .width("100%")
                            .height(this.controller.textSize * 1.5)
                            .scale(this.focusIndex === index ? { x: 1.1, y: 1.1 } : { x: 1, y: 1 })
                            .animation({ duration: 300 })
                        }, (krc: LrcLineView | undefined, index: number) => {
                            if (krc != undefined) {
                                return krc.getLyric().text + index
                            }
                            return index.toString()
                        })
                    }
                    .width("100%")
                    .height("100%")
                    .overlay(this.FadeOverlay())
                    .edgeEffect(EdgeEffect.None)
                    .scrollBar(BarState.Off)
                    .onScrollIndex((start, end, center) => {
                        // console.warn("abc", "center= " + center)
                        // currentCenter lyric line is center+1
                    })
                    .onTouch((event) => {
                        // todo handle seek action
                    })
                } else {
                    Text(this.controller.emptyHint)
                        .fontSize(this.controller.textSize)
                        .fontColor(this.controller.textColor)
                }
            }
            .width("100%")
            .layoutWeight(1)
            .onSizeChange((_, size) => {
                if (this.lrcDataSource === undefined) {
                    this.lrcDataSource = new LrcDataSource()
                    const h = size.height as number
                    this.middleLine =
                        Math.round(((h + this.controller.lineSpace) / (this.controller.textSize * 1.5 + this.controller.lineSpace) - 1) / 2)
                    console.warn("abc", "h= " + h + ", line= " + (this.controller.textSize) + ", lines= " + this.middleLine)
                    // todo 动态计算填充个数
                    this.setupDataSource()
                }
            })

            Progress({
                value: this.progress,
                total: this.lyric ? this.lyric.lyricList[this.lyric.lyricList.length-1].endTime : 0
            }).width("100%").margin(8)

            Row() {
                Button("start")
                    .onClick(() => {
                        this.mockPlayer()
                    })

                Button("change")
                    .onClick(() => {
                        // change data source
                        this.lyric = new SampleLyricParser().parse(src2)
                        console.info("abc", JSON.stringify(this.lyric))
                        // this.setupDataSource();
                        this.lyric = undefined
                        // replay
                        this.mockPlayer()
                    })
            }.width("100%")
            .justifyContent(FlexAlign.SpaceEvenly)
        }
        .height('100%')
        .width('100%')
    }

    private setupDataSource() {
        if (this.lrcDataSource === undefined) {
            return
        }
        this.lrcDataSource.clear(false);
        for (let i = 0; i < this.middleLine; i++) {
            this.lrcDataSource.addData(undefined, false);
        }
        const lines = this.lyric!.lyricList;
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            // todo 测量，是否换行
            const view = new LrcLineView(line);
            view.setTextSize(this.controller.textSize);
            view.setTextColor(this.controller.textColor);
            view.setTextHighlightColor(this.controller.textHighlightColor);
            this.lrcDataSource.addData(view, false);
        }
        for (let i = 0; i < this.middleLine; i++) {
            this.lrcDataSource.addData(undefined, false);
        }
        this.lrcDataSource.notifyDataReload();
        this.scroller.scrollToIndex(0);
    }

    private updatePosition(position: number) {
        if (this.lrcDataSource === undefined || this.lyric === undefined) {
            return
        }
        if (this.focusView !== undefined) {
            this.focusView.play(position)
        }
        const beginIndex = this.middleLine
        const endIndex = this.lrcDataSource.totalCount() - 1
        for (let i = beginIndex; i < endIndex; i++) {
            const lyric = this.lrcDataSource.getData(i)
            if (lyric === undefined) {
                continue
            }
            const lyricLine = lyric.getLyric()
            const start = lyricLine.beginTime
            const end = lyricLine.endTime
            if (position >= start && position < end) {
                console.error("abc", "-----" + lyricLine.text + ", " + i)
                if (this.focusIndex != i) {
                    if (this.focusView) {
                        this.focusView.stop()
                        this.focusView = undefined
                    }
                    this.focusView = this.lrcDataSource.getData(i)
                    this.focusIndex = i
                    const centerScrollIndex = i - this.middleLine
                    this.scroller.scrollToIndex(centerScrollIndex, true)
                }
                break
            }
        }
    }

    private mockPlayer() {
        clearInterval(this.timer)
        this.progress = 0
        this.timer = setInterval(() => {
            this.progress += 300
            this.updatePosition(this.progress)
        }, 300)
    }
}

class LrcLineView extends NodeController {
    private context: UIContext | null = null
    private lyricLine: LrcLine
    private lyricTextView: LrcTextView | null = null
    private rootView: FrameNode | null = null
    private isEmptyLine = false
    private textSize: number = -1
    private textColor: number = -1
    private textHighlightColor: number = -1

    public setTextSize(size: number) {
        this.textSize = size
        this.lyricTextView?.setTextSize(size)
    }

    public setTextColor(color: number) {
        this.textColor = color
        this.lyricTextView?.setTextColor(color)
    }

    public setTextHighlightColor(color: number) {
        this.textHighlightColor = color
        this.lyricTextView?.setTextHighlightColor(color)
    }

    constructor(lyricLine: LrcLine) {
        super()
        this.lyricLine = lyricLine
        this.isEmptyLine = lyricLine.text === undefined || lyricLine.text.length <= 0
    }

    /**
     * Check the lyric text is empty or not.
     * @returns The lyric is empty or not.
     */
    isEmpty(): boolean {
        return this.isEmptyLine
    }

    /**
     * Return the lyric data of this view.
     * @returns The lyric data {@link LyricLine}.
     */
    getLyric(): LrcLine {
        return this.lyricLine
    }

    /**
     * Play the effect animation.
     * @param position The playing position of media player.
     */
    play(position: number) {
        this.lyricTextView?.update(position)
    }

    /**
     * Stop the effect animation.
     */
    stop() {
        this.lyricTextView?.reset()
    }

    aboutToResize(size: Size): void {
        if (this.isEmptyLine) {
            // todo warning
            return
        }
        if (this.lyricTextView === null) {
            this.lyricTextView = new LrcTextView(this.context!, this.lyricLine)
            this.lyricTextView.onSizeChanged(size.width, size.height)
            if (this.textSize !== -1) {
                this.setTextSize(this.textSize)
            }
            if (this.textColor !== -1) {
                this.setTextColor(this.textColor)
            }
            if (this.textHighlightColor !== -1) {
                this.setTextHighlightColor(this.textHighlightColor)
            }
            const renderNode = this.rootView?.getRenderNode()
            if (renderNode) {
                renderNode.appendChild(this.lyricTextView)
            }
        } else {
            this.lyricTextView.onSizeChanged(size.width, size.height)
        }
    }

    makeNode(uiContext: UIContext): FrameNode | null {
        if (this.rootView == null) {
            this.context = uiContext
            this.rootView = new FrameNode(uiContext)
        }
        return this.rootView
    }
}

class LrcTextView extends RenderNode {
    private context: UIContext
    private lyricLine: LrcLine
    private normalPen: drawing.Brush = new drawing.Brush()
    private highlightPen: drawing.Brush = new drawing.Brush()
    private font = new drawing.Font()
    private readonly defaultTextSize = 16 //vp
    private textSize: number = 0 //vp
    private textColor: common2D.Color = {
        red: 0,
        green: 0,
        blue: 0,
        alpha: 255
    }
    private textHighlightColor: number = 0xFFFF0000
    // "#ffff0000"
    private lyricTextBlob?: drawing.TextBlob = undefined
    private anim?: AnimatorResult = undefined
    private textWidth: number = 0
    private textHeight: number = 0
    private beginX = -1
    private beginY = -1
    private relativePosition = -1
    private totalDuration = 0
    private drawBeginWidth = 0
    private drawingWidth = 0
    private endPoint: common2D.Point = { x: 0, y: 0 }
    private isKrc = false

    constructor(uiContext: UIContext, lyricLine: LrcLine) {
        super()
        this.context = uiContext
        this.textSize = uiContext.vp2px(this.defaultTextSize)
        this.lyricLine = lyricLine
        this.isKrc = lyricLine.wordList != undefined && lyricLine.wordList.length > 0
        this.totalDuration = this.lyricLine.endTime - this.lyricLine.beginTime
        this.initAnimation()
        this.updateConfig()
    }

    private initAnimation() {
        this.anim = this.context.createAnimator({
            duration: 250,
            delay: 0,
            easing: "linear",
            fill: 'forwards',
            direction: "normal",
            iterations: 1,
            begin: 0,
            end: 1
        })
        this.anim.onFrame = (progress) => {
            this.drawingWidth = progress
            this.invalidate()
        }
    }

    setTextSize(size: number) {
        this.textSize = this.context.vp2px(size)
        this.updateConfig()
    }

    setTextColor(textColor: number) {
        const colors = SimpleColor.hex2Argb(textColor) //argb
        this.textColor = {
            red: colors[1],
            green: colors[2],
            blue: colors[3],
            alpha: colors[0]
        }
        this.updateConfig()
    }

    setTextHighlightColor(textColor: number) {
        this.textHighlightColor = textColor
        this.updateConfig()
    }

    private updateConfig() {
        this.normalPen.setColor(this.textColor)
        this.font.setSize(this.textSize)
        this.lyricTextBlob = drawing.TextBlob.makeFromString(this.lyricLine.text, this.font, drawing.TextEncoding.TEXT_ENCODING_UTF8)
        const bound = this.lyricTextBlob.bounds()
        this.textWidth = bound.right - bound.left
        this.textHeight = bound.bottom - bound.top
        this.beginX = (this.context.vp2px(this.frame.width) - this.textWidth) / 2
        this.beginY = this.context.vp2px(this.frame.height / 2) + this.textHeight / 2
        this.invalidate()
    }

    onSizeChanged(width: number, height: number) {
        this.frame = {
            x: 0,
            y: 0,
            width: width,
            height: height
        }
        this.beginX = (width - this.textWidth) / 2
        this.beginY = height / 2 + this.textHeight / 2
        this.invalidate()
    }

    update(position: number) {
        this.relativePosition = position - this.lyricLine.beginTime
        // console.info("abc", "current pos= " + position + ", relative pos= " + this.relativePosition + ", start pos= " + this.lyricLine.beginTime +
        //     ", total duration= " + this.totalDuration + ", " + this.lyricLine.text)
        this.updateDrawParams()
    }

    reset() {
        this.anim!.finish()
        this.relativePosition = -1
        this.drawBeginWidth = 0
        this.drawingWidth = 0
        this.invalidate()
    }

    private updateDrawParams() {
        const currentPercent = this.relativePosition / this.totalDuration
        const drawTargetWidth = this.textWidth * currentPercent
        this.anim!.reset({
            duration: 250,
            delay: 0,
            easing: "linear",
            fill: 'forwards',
            direction: "normal",
            iterations: 1,
            begin: this.drawBeginWidth,
            end: drawTargetWidth
        })
        this.anim!.play()
        this.drawBeginWidth = drawTargetWidth
    }

    draw(context: DrawContext): void {
        const canvas = context.canvas
        // draw background
        this.drawNormal(canvas)
        // draw foreground
        this.drawHighlight(canvas)
    }

    private drawNormal(canvas: drawing.Canvas) {
        canvas.attachBrush(this.normalPen)
        canvas.drawTextBlob(this.lyricTextBlob, this.beginX, this.beginY)
        canvas.detachBrush()
    }

    private drawHighlight(canvas: drawing.Canvas) {
        if (this.relativePosition > 0) {
            this.endPoint.x = this.drawingWidth + this.beginX
            const shaderEffect = drawing.ShaderEffect.createLinearGradient({ x: 0, y: 0 }, this.endPoint,
                [this.textHighlightColor, this.textHighlightColor], drawing.TileMode.DECAL)
            this.highlightPen.setShaderEffect(shaderEffect)
            canvas.attachBrush(this.highlightPen)
            canvas.drawTextBlob(this.lyricTextBlob, this.beginX, this.beginY)
            canvas.detachBrush()
        }
    }
}


interface LrcWord {
    text: string; // 单个字符
    startTime: number; // 开始时间(ms)
    endTime: number; // 结束时间(ms)
}

interface LrcLine {
    text: string; // 完整文本
    beginTime: number; // 行开始时间(ms)
    endTime: number; // 行结束时间(ms)
    wordList: LrcWord[]; // 逐字歌词
}

interface Lrc {
    artist?: string; // 艺术家
    title?: string; // 标题
    album?: string; // 专辑
    by?: string; // 制作
    offset?: number; // 偏移量(ms)
    lyricList: LrcLine[]; // 歌词行列表
}

class SampleLyricParser {
    parse(lyricLines: string[]): Lrc {
        const lyric: Lrc = {
            lyricList: []
        };
        let offset = 0; // 偏移量，默认0ms
        // 解析元数据和歌词行
        for (const line of lyricLines) {
            // 匹配元数据行（如[ar:阿桑]、[ti:一直很安静]等）
            const metaMatch = line.match(/^\[(ar|ti|al|by|offset):(.*)\]$/);
            if (metaMatch) {
                // const [, key, value] = metaMatch;
                const key = metaMatch[1]
                const value = metaMatch[2]
                switch (key) {
                    case 'ar':
                        lyric.artist = value.trim();
                        break;
                    case 'ti':
                        lyric.title = value.trim();
                        break;
                    case 'al':
                        lyric.album = value.trim();
                        break;
                    case 'by':
                        lyric.by = value.trim();
                        break;
                    case 'offset':
                        offset = parseInt(value.trim(), 10) || 0;
                        lyric.offset = offset;
                        break;
                }
                continue; // 处理完元数据，继续下一行
            }
            // 解析歌词行（带时间标签的行）
            // 分割时间标签和字符（例如[00:00.195]阿 → 分割为时间和字符）
            const parts = line.split(/\[(\d+:\d+\.\d+)\]/);
            const times: number[] = []; // 时间数组（毫秒）
            const chars: string[] = []; // 字符数组
            // 提取时间（索引1,3,5...）并转换为毫秒
            for (let i = 1; i < parts.length; i += 2) {
                const timeStr = parts[i];
                const split1 = timeStr.split(':');
                const mmStr = split1[0];
                const ssPart = split1[1];
                if (!ssPart) {
                    continue
                }
                // 无效格式跳过
                const split2 = ssPart.split('.');
                const ssStr = split2[0];
                const sssStr = split2[1];
                if (!sssStr) {
                    continue
                }
                // 无效格式跳过
                const mm = parseInt(mmStr, 10) || 0;
                const ss = parseInt(ssStr, 10) || 0;
                const sss = parseInt(sssStr, 10) || 0;
                const ms = mm * 60 * 1000 + ss * 1000 + sss;
                times.push(ms + offset); // 加上偏移量
            }
            // 提取字符（索引2,4,6...）
            for (let i = 2; i < parts.length; i += 2) {
                const char = parts[i].trim();
                if (char) {
                    chars.push(char);
                }
            }
            // 验证格式：时间数量应为字符数量+1（每个字符对应一个开始时间，最后一个时间是结束时间）
            if (times.length !== chars.length + 1) {
                continue
            }
            // 生成逐字歌词列表
            const wordList: LrcWord[] = chars.map((text, i) => {
                const data: LrcWord = {
                    text,
                    startTime: times[i],
                    endTime: times[i + 1]
                }
                return data
            });
            // 生成歌词行
            const lyricLine: LrcLine = {
                text: chars.join(''), // 行完整文本
                beginTime: times[0], // 行开始时间（第一个字符的开始时间）
                endTime: times[times.length - 1], // 行结束时间（最后一个字符的结束时间）
                wordList
            };
            lyric.lyricList.push(lyricLine);
        }
        return lyric;
    }
}

export class SimpleColor {
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
            return SimpleColor.hexNumber2Argb(hex)
        } else {
            let hexString = hex.replace("#", "")
            if (hexString.length < 8) {
                hexString = "ff" + hexString
            }
            let hex2 = Number.parseInt(hexString, 16)
            return SimpleColor.hexNumber2Argb(hex2)
        }
    }
}