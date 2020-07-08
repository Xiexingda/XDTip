# XDTip
提示框类

```
// sheet
XDTipItem *title = XDTip.sheet.title(@"哈哈哈哈哈哈哈哈哈哈").numberOfLines(1);
XDTipItem *subTitle = XDTip.sheet.title(@"副标题").color(UIColor.grayColor);
XDTipItem *e1 = XDTip.sheet.element(@"1").numberOfLines(1);
XDTipItem *e2 = XDTip.sheet.element(@"2").backHightlightColor(UIColor.orangeColor);
XDTipItem *e3 = XDTip.sheet.element(@"3");
XDTipItem *e4 = XDTip.sheet.element(@"4");

XDTipItem *cancelTitle = XDTip.sheet.cancelBtnTitle(@"取消");

[XDTip showSheetTitle:title subTitle:subTitle elements:@[e1,e2,e3,e4] cancelBtnTitle:cancelTitle cancelByErea:YES action:^(NSInteger index, NSString *text, BOOL cancelByBtn, BOOL cancelByErea) {
  
}];
```

```
// alert
XDTipItem *title = XDTip.alert.title(@"标题");
XDTipItem *subTitle = XDTip.alert.subTitle(@"副标题");
XDTipItem *content = XDTip.alert.content(@"这是aler的内容，该内容没有任何效果，但是我还是要把它说出来");

XDTipItem *ele1 = XDTip.alert.element(@"确定");
XDTipItem *ele2 = XDTip.alert.element(@"取消").color(UIColor.redColor);

[XDTip showAlertTitle:title subTitle:subTitle content:content elements:@[ele1,ele2] cancelByErea:YES action:^(NSInteger index, NSString *text ,BOOL cancelByErea) {
    
}];

// 完全自定义字段可以这么写
XDTipItem *element = XDTip
                    .alert                                      // 自定义的话这里用.alert 和 .sheet 是一样的
                    .text(@"element")                           // 自定义字段
                    .color(UIColor.redColor)                    // 字段颜色
                    .focusColor(UIColor.greenColor)             // 字段高光颜色
                    .font([UIFont systemFontOfSize:16])         // 字段字体大小
                    .numberOfLines(1)                           // 该字段是否可换行，可换几行，0表示无线行
                    .height(20)                                 // 该字段所在元素的高度
                    .backDefaultColor(UIColor.blackColor)       // 该字段所在元素的默认背景色
                    .backHightlightColor(UIColor.orangeColor);  // 该字段所在元素点击时的背景色
```
