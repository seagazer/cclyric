@Entry
@Component
struct Index {
    build() {
        Column() {
            Text("CcLyricView")
                .width("100%")
                .height(50)
                .fontSize(24)
                .textAlign(TextAlign.Center)
                .border({ radius: 4 })
                .backgroundColor("#cc87d0b5")
                .onClick(() => {
                    this.getUIContext().getRouter().pushUrl({
                        url: "pages/CcLyricViewSample"
                    })
                })
            Text("CustomSeekUI")
                .width("100%")
                .height(50)
                .fontSize(24)
                .textAlign(TextAlign.Center)
                .border({ radius: 4 })
                .backgroundColor("#cc87d0b5")
                .onClick(() => {
                    this.getUIContext().getRouter().pushUrl({
                        url: "pages/CustomSeekUISample"
                    })
                })
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .padding(16)
    }
}
