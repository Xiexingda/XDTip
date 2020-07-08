//
//  ViewController.m
//  Demo
//
//  Created by 谢兴达 on 2020/4/20.
//  Copyright © 2020 xie. All rights reserved.
//

#import "ViewController.h"
#import "XDTip.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showSheet)];
    [view addGestureRecognizer:tap1];
    
    
    UIView *alert = [[UIView alloc]initWithFrame:CGRectMake(100,300, 100, 100)];
    alert.backgroundColor = UIColor.blueColor;
    [self.view addSubview:alert];
   
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAlert)];
    [alert addGestureRecognizer:tap];
}



- (void)showSheet {
    XDTipItem *title = XDTip.sheet.title(@"哈哈哈哈哈哈哈哈哈哈").numberOfLines(1);
    XDTipItem *subTitle = XDTip.sheet.title(@"副标题").color(UIColor.grayColor);
    XDTipItem *e1 = XDTip.sheet.element(@"1").numberOfLines(1);
    XDTipItem *e2 = XDTip.sheet.element(@"2").backHightlightColor(UIColor.orangeColor);
    XDTipItem *e3 = XDTip.sheet.element(@"3");
    XDTipItem *e4 = XDTip.sheet.element(@"4");

    XDTipItem *cancelTitle = XDTip.sheet.cancelBtnTitle(@"取消");

    [XDTip showSheetTitle:title subTitle:subTitle elements:@[e1,e2,e3,e4] cancelBtnTitle:cancelTitle cancelByErea:YES action:^(NSInteger index, NSString *text, BOOL cancelByBtn, BOOL cancelByErea) {
      
    }];
}

- (void)showAlert {
    XDTipItem *title = XDTip.alert.title(@"标题");
    XDTipItem *subTitle = XDTip.alert.subTitle(@"副标题");
    XDTipItem *content = XDTip.alert.content(@"这是aler的内容，该内容没有任何效果，但是我还是要把它说出来");
    
    XDTipItem *ele1 = XDTip.alert.element(@"确定");
    XDTipItem *ele2 = XDTip.alert.element(@"取消").color(UIColor.redColor);
    
    [XDTip showAlertTitle:title subTitle:subTitle content:content elements:@[ele1,ele2] cancelByErea:YES action:^(NSInteger index, NSString *text ,BOOL cancelByErea) {
        
    }];
}

@end
