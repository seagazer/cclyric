# cclyric

## ���

**cclyric** ��һ��Ϊ **OpenHarmony** �� **HaromonyOS** �����ֲ��Ÿ�ʿ⡣

- ֧�ָ�ʽ���
- ֧�ָ�ʹ�����ʾ
- ֧���Զ�����ʽ��������������С/��ɫ���۽���С/��ɫ����ʾģʽ��

## ������ʽ

```ts
ohpm install @seagazer/cclyric
```

## �ӿ�����

**cclyric** �ṩ**LyricParser **���и�ʽ����� ��ͼ��� **LyricView** ���û�����ͨ�� **LyricController **������������û�Ҳ�����Լ�ʵ��**IParser**�ӿڱ�д�Լ��ĸ�ʽ���ҵ��

### Lyric

������ݽṹ

| ����      | ��������          | ����˵��     |
| --------- | ----------------- | ------------ |
| artist    | string            | ������       |
| title     | string            | ����         |
| album     | string            | ר��         |
| by        | string            | ����         |
| offset    | number            | ʱ���ƫ���� |
| lyricList | Array\<LyricLine> | ���������   |

### LyricLine

���и�����ݽṹ

| ����      | �������� | ����˵��             |
| --------- | -------- | -------------------- |
| text      | string   | �������             |
| beginTime | number   | ��ǰ�и����ʼʱ��� |
| nextTime  | number   | ��һ�и����ʼʱ��� |

### IParser

��ʽ����ӿ�

parse(src: Array\<string>): Lyric
�������

| ���� | ��������       | ����˵��       |
| ---- | -------------- | -------------- |
| src  | Array\<string> | ����ı������� |

### LyricController

LyricView ���������

#### setLyric(lyric: Lyric): LyricController

���ø�����ݣ���Ҫͨ���ṩ�� LyricParser �����Զ��� IParser ������ʡ�

| ����  | �������� | ����˵�� |
| ----- | -------- | -------- |
| lyric | Lyric    | ���     |

#### updatePosition(mediaPosition: number)

����ý�岥�Ž��ȣ�������Զ�ˢ�¸����ʾ��

| ����          | �������� | ����˵��              |
| ------------- | -------- | --------------------- |
| mediaPosition | number   | ý�岥�Ž���(��λ ms) |

#### setTextSize(textSize: number): LyricController

���ø���ı��ߴ磬Ĭ��Ϊ 18px��

| ����     | �������� | ����˵��              |
| -------- | -------- | --------------------- |
| textSize | number   | ����ı��ߴ�(��λ px) |

#### setTextColor(color: string): LyricController

���ø���ı���ͨ��ɫ��Ĭ��Ϊ#80000000��

| ����  | �������� | ����˵��     |
| ----- | -------- | ------------ |
| color | string   | �ı���ͨ��ɫ |

#### setHighlightColor(color: string): LyricController

���ø���ı��۽���ɫ����ǰ���ŵĸ�����ھ۽�״̬��Ĭ��Ϊ#000000��

| ����  | �������� | ����˵��     |
| ----- | -------- | ------------ |
| color | string   | �ı��۽���ɫ |

#### setHighlightScale(scale: number): LyricController

���ø���ı��۽����ţ���ǰ���ŵĸ�����ھ۽�״̬��Ĭ��Ϊ 1.2f��

| ����  | �������� | ����˵��         |
| ----- | -------- | ---------------- |
| scale | number   | �ı��۽����ű��� |

#### setHighlightStyle(isBold: boolean): LyricController

���ø���ı��۽�ʱ�Ƿ���壬��ǰ���ŵĸ�����ھ۽�״̬��Ĭ��Ϊ true��

| ����   | �������� | ����˵��           |
| ------ | -------- | ------------------ |
| isBold | boolean  | �ı��۽�ʱ�Ƿ���� |

#### setEdgeColor(color: string): LyricController

���ø�����±�Ե������ɫ��Ĭ��Ϊ#ffffff��

| ����  | �������� | ����˵��         |
| ----- | -------- | ---------------- |
| color | string   | ��ʱ�Ե������ɫ |

#### setLineSpace(lineSpace: number): LyricController

���ø���м�࣬Ĭ��Ϊ 16px��

| ����      | �������� | ����˵��            |
| --------- | -------- | ------------------- |
| lineSpace | number   | ����м��(��λ px) |

#### setAnimationDuration(duration: number): LyricController

���ø�ʹ�����Чʱ����Ĭ��Ϊ 300ms��

| ����     | �������� | ����˵��                  |
| -------- | -------- | ------------------------- |
| duration | number   | ��ʹ�����Чʱ��(��λ ms) |

#### setCacheSize(cacheSize: number): LyricController

���ø�ʻ��ƵĻ�����������Ļ���Ԥ����һ�������ĸ�ʣ��������»�������ʾ���ܣ�Ĭ��Ϊ 2 �С�

| ����      | �������� | ����˵��     |
| --------- | -------- | ------------ |
| cacheSize | number   | ���ƻ������� |

#### setEmptyHint(hint: string): LyricController

�����޸��ʱ����ʾ�Ĭ��Ϊ`--`��

| ���� | �������� | ����˵��         |
| ---- | -------- | ---------------- |
| hint | string   | �޸��ʱ����ʾ�� |

#### setAlignMode(align: "left" | "center"): LyricController

���ø����ʾģʽ��Ŀǰ֧�־�����ʾ�;�����ʾ��Ĭ��Ϊ"left"�������ʾ��

| ����  | ��������          | ����˵��     |
| ----- | ----------------- | ------------ |
| align | "left" ��"center" | �����ʾģʽ |

#### invalidate()

����ˢ���ػ棬�÷���ֻ�ᴥ�����»��ƣ����ᴥ�����²��֡�

### LyricHelper

��ʹ����֧࣬�ָ���ý�岥�Ž��Ȳ�ѯ��ǰ��ʡ�

#### setLyricData(data: Lyric)

���ø�����ݡ�

| ���� | �������� | ����˵�� |
| ---- | -------- | -------- |
| data | Lyric    | ������� |

#### getLyric(position: number): string

����ý�岥�Ž��ȣ���ѯ��ǰ�ĸ�����ݣ����ص�ǰ������ı���

| ����     | �������� | ����˵��     | ����ֵ         |
| -------- | -------- | ------------ | -------------- |
| position | number   | ý�岥�Ž��� | ��ǰ������ı� |

## ����ʾ��

- �����ǻ���ʾ����ʹ�÷�ʽ��

```ts
@Entry
@Component
struct Index {
    // 1.��ʼ��controller
    private lyricController: LyricController = new LyricController()
    private parser = new LyricParser()

    aboutToAppear() {
        // 2.�Զ�����ʽ����
        this.lyricController
            .setTextSize(24)
            .setCacheSize(4)
            .setTextColor("#8c000000")
            .setHighlightColor("#ff000000")
            .setLineSpace(16)
            .setHighlightStyle(false)
            .setEmptyHint("��ǰû�и��")
            .setAlignMode("center")
        // 3.�������
        let lyric = this.parser.parse(MockData.src1)
        // 4.���ø��
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

- ����ʹ�ó�����ʾ�������Բο��������ֵ� entry ���̣�https://github.com/seagazer/cclyric
- ��ϲ�����ʹ�õĸ���ʾ�������Բο��������ֲ�������Ŀ��https://github.com/seagazer/cclisten
