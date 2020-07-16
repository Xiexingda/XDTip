//
//  XDTip.m
//  XDActionBox
//
//  Created by 谢兴达 on 2020/4/17.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDTip.h"
@class _XXTipSheetUI,_XXTipAlertUI,_XXTipSheetCell, _XXTipAlertItem ,_XXTipAlertLayout;

#define XDTipSheetWidth ([UIScreen mainScreen].bounds.size.width - 32)
#define XDTipAlertWidth (MIN(CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds))-100)
#define XDTipSheetCancelBtnEdge 8
#define XDTipDefaultTopEdge 10
#define XDTipDefaultLREdge 10
#define XDTipSheetCorner 10
#define XDTipAlertCorner 10
#define XDTipDefaultColor UIColor.blackColor
#define XDTipHighliteColor UIColor.greenColor
#define XDTipIsIphoneX YES

@interface XDTip ()
@property (nonatomic,   copy) void(^tipCanShowBlock)(_XXTipType type);
@property (nonatomic, strong) _XXTipSheetUI *sheetUI;
@property (nonatomic, strong) _XXTipAlertUI *alertUI;
@property (nonatomic, strong) _XXTipModel *model;
@property (nonatomic,   copy) void(^sheetAction)(NSInteger index, NSString *text, BOOL cancelByBtn, BOOL cancelByErea);
@property (nonatomic,   copy) void(^alertAction)(NSInteger index, NSString *text, BOOL cancelByErea);
@end

@implementation XDTip

+ (XDTipItem *)sheet {
    return [[XDTipItem alloc]initByType:_XXTip_Sheet];
}

+ (XDTipItem *)alert {
    return [[XDTipItem alloc]initByType:_XXTip_Alert];
}

+ (void)showSheetTitle:(XDTipItem *)title subTitle:(XDTipItem *)subTitle elements:(NSArray<XDTipItem *> *)elements cancelBtnTitle:(XDTipItem *)cancelBtnTitle cancelByErea:(BOOL)cancelByErea action:(void (^)(NSInteger, NSString *, BOOL, BOOL))action {
    
    [[self xd_keyWindow]endEditing:YES];
    
    XDTip *sheet = [[self alloc]
                    initSheetTitle:title
                    subTitle:subTitle
                    elements:elements
                    cancelBtnTitle:cancelBtnTitle
                    cancelByErea:cancelByErea
                    action:action];
    
    UIViewController *c_vc = [self xd_keyController];
    
    if ([c_vc isBeingDismissed]) {
        
        if (c_vc.presentingViewController) {
            [c_vc.presentingViewController presentViewController:sheet animated:NO completion:^{
                if (sheet.tipCanShowBlock) {
                    sheet.tipCanShowBlock(_XXTip_Sheet);
                }
            }];
        }
        
    } else {
        
        [c_vc presentViewController:sheet animated:NO completion:^{
            if (sheet.tipCanShowBlock) {
                sheet.tipCanShowBlock(_XXTip_Sheet);
            }
        }];
        
    }
}

+ (void)showAlertTitle:(XDTipItem *)title subTitle:(XDTipItem *)subTitle content:(XDTipItem *)content elements:(NSArray<XDTipItem *> *)elements cancelByErea:(BOOL)cancelByErea action:(void (^)(NSInteger, NSString *, BOOL))action {
    
    [[self xd_keyWindow]endEditing:YES];
    
    XDTip *alert = [[self alloc]
                    initAlertTitle:title
                    subTitle:subTitle
                    content:content
                    elements:elements
                    cancelByErea:cancelByErea
                    action:action];
     
    UIViewController *c_vc = [self xd_keyController];
    
    if ([c_vc isBeingDismissed]) {
        
        if (c_vc.presentingViewController) {
            [c_vc.presentingViewController presentViewController:alert animated:NO completion:^{
                if (alert.tipCanShowBlock) {
                    alert.tipCanShowBlock(_XXTip_Alert);
                }
            }];
        }
        
    } else {
        
        [c_vc presentViewController:alert animated:NO completion:^{
            if (alert.tipCanShowBlock) {
                alert.tipCanShowBlock(_XXTip_Alert);
            }
        }];
        
    }
}

- (instancetype)initSheetTitle:(XDTipItem *)title subTitle:(XDTipItem *)subTitle elements:(NSArray<XDTipItem *> *)elements cancelBtnTitle:(XDTipItem *)cancelBtnTitle cancelByErea:(BOOL)cancelByErea action:(void (^)(NSInteger, NSString *, BOOL, BOOL))action {
    
    self = [super init];
    
    if (self) {
        
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        self.model = [[_XXTipModel alloc]init];
        self.model.tipTitle = title;
        self.model.tipSubTitle = subTitle;
        self.model.tipElements = elements;
        self.model.tipCancelTitle = cancelBtnTitle;
        self.model.cancelByErea = cancelByErea;
        self.sheetAction = action;
    }
    
    return self;
}

- (instancetype)initAlertTitle:(XDTipItem *)title subTitle:(XDTipItem *)subTitle content:(XDTipItem *)content elements:(NSArray<XDTipItem *> *)elements cancelByErea:(BOOL)cancelByErea action:(void (^)(NSInteger, NSString *, BOOL))action {
    
    self = [super init];
    
    if (self) {
        
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        self.model = [[_XXTipModel alloc]init];
        self.model.tipContent = content;
        self.model.tipTitle = title;
        self.model.tipSubTitle = subTitle;
        self.model.tipElements = elements;
        self.model.cancelByErea = cancelByErea;
        self.alertAction = action;
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"释放XDTip");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    
    [self setTipCanShowBlock:^(_XXTipType type) {
        
        if (type == _XXTip_Sheet) {
            [weakSelf showSheet];
            
        } else if (type == _XXTip_Alert) {
            [weakSelf showAlert];
        }
        
    }];
}

#pragma mark - UI for sheet
- (void)showSheet {
    [[XDTip xd_keyWindow] addSubview:self.sheetUI];
}

- (void)hiddenSheet {
    [self.sheetUI removeFromSuperview];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UI for alert
- (void)showAlert {
    [[XDTip xd_keyWindow] addSubview:self.alertUI];
}

- (void)hiddenAlert {
    [self.alertUI removeFromSuperview];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - lazy load
- (_XXTipSheetUI *)sheetUI {
    
    if (!_sheetUI) {
        
        __weak typeof(self) weakSelf = self;
        
        _sheetUI = [[_XXTipSheetUI alloc]initWithFrame:self.view.bounds model:self.model action:^(NSInteger index, NSString *text, BOOL cancelByBtn, BOOL cancelByErea) {
            
            if (weakSelf.sheetAction) {
                weakSelf.sheetAction(index, text, cancelByBtn, cancelByErea);
            }
            
        } hiddenFinish:^{
            [weakSelf hiddenSheet];
        }];
    }
    
    return _sheetUI;
}

- (_XXTipAlertUI *)alertUI {
    
    if (!_alertUI) {
        
        __weak typeof(self) weakSelf = self;
        
        _alertUI = [[_XXTipAlertUI alloc]initWithFrame:self.view.bounds model:self.model action:^(NSInteger index, NSString *text, BOOL cancelByErea) {
            
            if (weakSelf.alertAction) {
                weakSelf.alertAction(index, text, cancelByErea);
            }
            
        } hiddenFinish:^{
            [weakSelf hiddenAlert];
        }];
    }
    
    return _alertUI;
}

#pragma mark - private method
+ (UIViewController *)xd_keyController {
    
    UIViewController *c_VC = nil;
    
    UIViewController *r_VC = [self xd_keyWindow].rootViewController;
    
    while (true) {
        
        if ([r_VC isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *n_VC = (UINavigationController *)r_VC;
            UIViewController *vc = n_VC.visibleViewController;
            c_VC = vc;
            r_VC = vc.presentedViewController;
            continue;
            
        } else if([r_VC isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController *t_VC = (UITabBarController *)r_VC;
            c_VC = t_VC;
            r_VC = [t_VC.viewControllers objectAtIndex:t_VC.selectedIndex];
            continue;
            
        } else if([r_VC isKindOfClass:[UIViewController class]]) {
            
            UIViewController *vc = (UIViewController *)r_VC;
            c_VC = vc;
            r_VC = vc.presentedViewController;
            continue;
            
        } else {
            break;
        }
    }
    
    return c_VC;
}

//获取当前keyWindow
+ (UIWindow *)xd_keyWindow {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
    
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    window = windowScene.windows.firstObject;
                    break;
                }
            }
        }
    
    return window;
}

#pragma mark - system method
// 禁止当前屏幕旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

// 推迟边缘手势
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return  UIRectEdgeAll;
}

@end






#pragma mark - class XDTipItem()

@interface XDTipItem ()
@property (nonatomic, strong) _XXTipData *data;
@property (nonatomic, assign) _XXTipType type;
@end
@implementation XDTipItem

- (XDTipItem * (^)(NSString *))title {
    return ^(NSString *text) {
        self.data.text = text;
        self.data.color = [UIColor redColor];
        self.data.font = [UIFont systemFontOfSize:12];
        self.data.height = 20;
        self.data.numberOfLines = 2;
        return self;
    };
}

- (XDTipItem *(^)(NSString *))subTitle {
    return ^(NSString *text) {
        self.data.text = text;
        self.data.color = [UIColor grayColor];
        self.data.font = [UIFont systemFontOfSize:10];
        self.data.height = 20;
        self.data.numberOfLines = 1;
        return self;
    };
}

- (XDTipItem *(^)(NSString *))cancelBtnTitle {
    return ^(NSString *text) {
        self.data.text = text;
        self.data.color = [UIColor redColor];
        self.data.focusColor = [UIColor redColor];
        self.data.font = [UIFont systemFontOfSize:16];
        self.data.height = 50;
        self.data.numberOfLines = 1;
        return self;
    };
}

- (XDTipItem * (^)(NSString *))element {
    return ^(NSString *text) {
        self.data.text = text;
        self.data.font = [UIFont systemFontOfSize:14];
        self.data.height = self.type == _XXTip_Sheet ? 50 : 40;
        self.data.numberOfLines = 1;
        return self;
    };
}

- (XDTipItem *(^)(NSString *))content {
    return ^(NSString *text) {
        self.data.text = text;
        self.data.color = [UIColor orangeColor];
        self.data.font = [UIFont systemFontOfSize:16];
        self.data.height = 50;
        self.data.numberOfLines = 0;
        return self;
    };
}

- (XDTipItem *(^)(UIColor *))color {
    return ^(UIColor *color) {
        self.data.color = color;
        return self;
    };
}

- (XDTipItem *(^)(UIColor *))focusColor {
    return ^(UIColor *focusColor) {
        self.data.focusColor = focusColor;
        return self;
    };
}

- (XDTipItem *(^)(UIFont *))font {
    return ^(UIFont *font) {
        self.data.font = font;
        return self;
    };
}

- (XDTipItem *(^)(NSString *))text {
    return ^(NSString *text) {
        self.data.text = text;
        return self;
    };
}

- (XDTipItem *(^)(CGFloat))height {
    return ^(CGFloat height) {
        self.data.height = height;
        return self;
    };
}

- (XDTipItem *(^)(NSInteger))numberOfLines {
    return ^(NSInteger numberOfLines) {
        self.data.numberOfLines = numberOfLines;
        return self;
    };
}

- (XDTipItem *(^)(UIColor *))backDefaultColor {
    return ^(UIColor *backDefaultColor) {
        self.data.backDefaultColor = backDefaultColor;
        return self;
    };
}

- (XDTipItem *(^)(UIColor *))backHightlightColor {
    return ^(UIColor *backHightlightColor) {
        self.data.backHightlightColor = backHightlightColor;
        return self;
    };
}

- (_XXTipData *)data {
    
    if (!_data) {
        _data = [[_XXTipData alloc]init];
    }
    
    return _data;
}

- (instancetype)initByType:(_XXTipType)type {
    
    self = [super init];
    
    if (self) {
        self.type = type;
    }
    
    return self;
}

@end







#pragma mark - class XXTipData()

@implementation _XXTipData

- (instancetype)init {
   
    self = [super init];
    
    if (self) {
        
        _text = nil;
        _color = UIColor.whiteColor;
        _focusColor = UIColor.whiteColor;
        _font = [UIFont systemFontOfSize:16];
        _height = 50;
        _numberOfLines = 0;
        _backDefaultColor = XDTipDefaultColor;
        _backHightlightColor = XDTipHighliteColor;
        
    }
    
    return self;
}

@end






#pragma mark - class XXTipModel()

@implementation _XXTipModel

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

@end






#pragma mark - class XXTipSheetUI()

@interface _XXTipSheetUI ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,   copy) void(^tipHiddenBlock)(void);
@property (nonatomic,   copy) void(^tapBlock)(void);
@property (nonatomic,   copy) void(^actionBlock)(NSInteger index, NSString *text, BOOL cancelByBtn, BOOL cancelByErea);
@property (nonatomic, strong) UIView *alphaBackView;
@property (nonatomic, strong) UIView *sheetHeader;
@property (nonatomic, strong) UIView *sheetFooter;
@property (nonatomic, strong) UITableView *sheetMainTable;
@property (nonatomic, strong) _XXTipModel *model;
@end
@implementation _XXTipSheetUI

- (instancetype)initWithFrame:(CGRect)frame model:(_XXTipModel *)model action:(void (^)(NSInteger, NSString *, BOOL, BOOL))action hiddenFinish:(void (^)(void))finish {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.model = model;
        self.actionBlock = action;
        self.tipHiddenBlock = finish;
        [self sheetShow];
    }
    
    return self;
}

- (void)sheetShow {
    
    [self configModel];
    [self configHeader];
    [self configFooter];
    [self configTable];
    
    [self addSubview:self.alphaBackView];
    [self addSubview:self.sheetMainTable];
    
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                  withRadii:CGSizeMake(XDTipSheetCorner, XDTipSheetCorner)
                    forView:self.sheetMainTable];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alphaBackView.alpha = 0.5;
        
        CGRect cframe = self.sheetMainTable.frame;
        cframe.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(self.sheetMainTable.frame);
        [self.sheetMainTable setFrame:cframe];
        
    }];
}

- (void)sheetHiddenIndex:(NSInteger)index cancelByTitle:(BOOL)cancelByTitle cancelByErea:(BOOL)cancelByErea {
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alphaBackView.alpha = 0;
        
        CGRect cframe = self.sheetMainTable.frame;
        cframe.origin.y = CGRectGetHeight(self.bounds);
        [self.sheetMainTable setFrame:cframe];
        
    } completion:^(BOOL finished) {
        if (self.tipHiddenBlock) {
            self.tipHiddenBlock();
        }
        
        NSString *text = index >= 0 ? self.model.tipElements[index].data.text : nil;
        if (self.actionBlock) {
            self.actionBlock(index, text, cancelByTitle, cancelByErea);
        }
    }];
}

- (void)configModel {
    
    [self.model.tipElements enumerateObjectsUsingBlock:^(XDTipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        _XXTipData *data = obj.data;
            
        UILabel *mid = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, XDTipSheetWidth-2*XDTipDefaultLREdge, 0)];
        
        mid.textAlignment = NSTextAlignmentCenter;
        mid.numberOfLines = data.numberOfLines;
        mid.textColor = data.color;
        mid.font = data.font;
        mid.text = data.text;
        
        CGSize size = [mid sizeThatFits:CGSizeMake(XDTipSheetWidth-2*XDTipDefaultLREdge, MAXFLOAT)];
    
        if (size.height > data.height-2*XDTipDefaultTopEdge) {
            data.height = size.height+2*XDTipDefaultTopEdge;
        }
        
        mid = nil;
        
    }];
}

- (void)configHeader {
    
    CGFloat titleToTop = XDTipDefaultTopEdge;
    CGFloat titleToEdge = XDTipDefaultLREdge;
    
    UILabel *title, *subTitle;
    
    if (self.model.tipTitle) {
        
        _XXTipData *data = self.model.tipTitle.data;
        
        title = [[UILabel alloc]initWithFrame:CGRectMake(titleToEdge,
                                                         titleToTop,
                                                         XDTipSheetWidth-2*titleToEdge,
                                                         0)];
        title.textAlignment = NSTextAlignmentCenter;
        title.backgroundColor = UIColor.clearColor;
        title.numberOfLines = data.numberOfLines;
        title.textColor = data.color;
        title.font = data.font;
        title.text = data.text;
        
        CGSize titleSize = [title sizeThatFits:CGSizeMake(XDTipSheetWidth-2*titleToEdge, MAXFLOAT)];
        CGFloat titleHeight = data.height < titleSize.height ? titleSize.height : data.height;
        
        [title setFrame:CGRectMake(CGRectGetMinX(title.frame),
                                   CGRectGetMinY(title.frame),
                                   CGRectGetWidth(title.frame),
                                   titleHeight)];
        
        CGFloat headerHeight = CGRectGetMaxY(title.frame)+titleToTop;
        [self.sheetHeader setFrame:CGRectMake(0,
                                              0,
                                              XDTipSheetWidth,
                                              headerHeight)];
        
        [self.sheetHeader addSubview:title];
    }
    
    if (self.model.tipSubTitle) {
        
        _XXTipData *data = self.model.tipSubTitle.data;
        
        CGFloat offy = title ? CGRectGetMaxY(title.frame)+5 : titleToTop;
        subTitle = [[UILabel alloc]initWithFrame:CGRectMake(titleToEdge,
                                                            offy,
                                                            XDTipSheetWidth-2*titleToEdge,
                                                            0)];
        subTitle.textAlignment = NSTextAlignmentCenter;
        subTitle.backgroundColor = UIColor.clearColor;
        subTitle.numberOfLines = data.numberOfLines;
        subTitle.textColor = data.color;
        subTitle.font = data.font;
        subTitle.text = data.text;
        
        CGSize subTitleSize = [subTitle sizeThatFits:CGSizeMake(XDTipSheetWidth-2*titleToEdge, MAXFLOAT)];
        CGFloat subTitleHeight = data.height < subTitleSize.height ? subTitleSize.height : data.height;
        
        [subTitle setFrame:CGRectMake(CGRectGetMinX(subTitle.frame),
                                      CGRectGetMinY(subTitle.frame),
                                      CGRectGetWidth(subTitle.frame),
                                      subTitleHeight)];
        
        CGFloat headerHeight = CGRectGetMaxY(subTitle.frame)+titleToTop;
        [self.sheetHeader setFrame:CGRectMake(0,
                                              0,
                                              XDTipSheetWidth,
                                              headerHeight)];
        
        [self.sheetHeader addSubview:subTitle];
    }
}

- (void)configFooter {
    CGRect cframe = self.sheetFooter.frame;
    
    if (XDTipIsIphoneX) {
        cframe.size.height += 22;
        [self.sheetFooter setFrame:cframe];
    }
}

- (void)configTable {
    __block CGFloat height = CGRectGetHeight(self.sheetHeader.frame) + CGRectGetHeight(self.sheetFooter.frame) + XDTipSheetCancelBtnEdge + self.model.tipCancelTitle.data.height;
    
    [self.model.tipElements enumerateObjectsUsingBlock:^(XDTipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        height += obj.data.height;
    }];
    
    CGFloat offx = (CGRectGetWidth([UIScreen mainScreen].bounds)-XDTipSheetWidth)/2.0;
    [self.sheetMainTable setFrame:CGRectMake(offx,
                                             CGRectGetMaxY(self.bounds),
                                             XDTipSheetWidth,
                                             height)];
    
    self.sheetMainTable.tableHeaderView = self.sheetHeader;
    self.sheetMainTable.tableFooterView = self.sheetFooter;
}

#pragma mark - tableview delegate source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.tipCancelTitle ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.model.tipElements.count;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return self.model.tipElements[indexPath.row].data.height+0.5;
    }
    
    return self.model.tipCancelTitle.data.height;;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0 : XDTipSheetCancelBtnEdge;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        UIView *edgeView = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   XDTipSheetWidth,
                                                                   XDTipSheetCancelBtnEdge)];
        edgeView.backgroundColor = [UIColor clearColor];
        return edgeView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _XXTipSheetCell *cell;
    
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"_XDTipSheeCell"];
        
        if (!cell) {
            cell = [[_XXTipSheetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_XDTipSheeCell"];
        }
        
        BOOL isEnd = (indexPath.row == (self.model.tipElements.count-1)) ? YES : NO;
        [cell configCellByModel:self.model.tipElements[indexPath.row] isTheEndCell:isEnd isCancelBtn:NO];
        
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"_XDTipSheetCancelCell"];
        
        if (!cell) {
            cell = [[_XXTipSheetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_XDTipSheetCancelCell"];
        }
        
        [cell configCellByModel:self.model.tipCancelTitle isTheEndCell:YES isCancelBtn:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self sheetHiddenIndex:indexPath.row cancelByTitle:NO cancelByErea:NO];
    } else {
        [self sheetHiddenIndex:-1 cancelByTitle:YES cancelByErea:NO];
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    _XXTipSheetCell *cell = ((_XXTipSheetCell*)[tableView cellForRowAtIndexPath:indexPath]);
    [cell highlightCell];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    _XXTipSheetCell *cell = ((_XXTipSheetCell*)[tableView cellForRowAtIndexPath:indexPath]);
    [cell defaultCell];
}

#pragma mark - lazy load
- (UIView *)alphaBackView {
    if (!_alphaBackView) {
        _alphaBackView = [[UIView alloc]initWithFrame:self.bounds];
        _alphaBackView.alpha = 0;
        _alphaBackView.backgroundColor = [UIColor blackColor];
        
        __weak typeof(self) weakSelf = self;
        [self tapView:_alphaBackView action:^{
            if (weakSelf.model.cancelByErea) {
                [weakSelf sheetHiddenIndex:-1 cancelByTitle:NO cancelByErea:YES];
            }
        }];
    }
    
    return _alphaBackView;
}

- (UIView *)sheetHeader {
    
    if (!_sheetHeader) {
        _sheetHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, XDTipSheetWidth, 0)];
        _sheetHeader.backgroundColor = XDTipDefaultColor;
    }
    
    return _sheetHeader;
}

- (UIView *)sheetFooter {
   
    if (!_sheetFooter) {
        _sheetFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, XDTipSheetWidth, 10)];
    }
    
    return _sheetFooter;
}

- (UITableView *)sheetMainTable {
   
    if (!_sheetMainTable) {
        _sheetMainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds), XDTipSheetWidth, 0) style:UITableViewStylePlain];
        _sheetMainTable.delegate = self;
        _sheetMainTable.dataSource = self;
        _sheetMainTable.scrollEnabled = NO;
        _sheetMainTable.backgroundColor = UIColor.clearColor;
        _sheetMainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _sheetMainTable;
}

#pragma mark - private method
- (void)tapView:(UIView *)view action:(void(^)(void))action {
    self.tapBlock = action;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(alphaTap)];
    [view addGestureRecognizer:tap];
}

- (void)alphaTap {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (void)addRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii forView:(UIView *)view {
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}

@end






#pragma mark - class sheetCell()

@interface _XXTipSheetCell ()
@property (nonatomic, strong) UIView *sheetContainer;
@property (nonatomic, strong) UILabel *sheetLabel;
@property (nonatomic, strong) UIView *spaceLine;
@property (nonatomic, strong) XDTipItem *model;
@end

@implementation _XXTipSheetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _sheetContainer = [[UIView alloc]initWithFrame:CGRectZero];
        _sheetContainer.backgroundColor = XDTipDefaultColor;
        [self.contentView addSubview:_sheetContainer];
        
        _sheetLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _sheetLabel.textAlignment = NSTextAlignmentCenter;
        _sheetLabel.backgroundColor = UIColor.clearColor;
        [_sheetContainer addSubview:_sheetLabel];
        
        _spaceLine = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                             CGRectGetMaxY(_sheetLabel.frame),
                                                             CGRectGetWidth(self.frame),
                                                             0.5)];
        _spaceLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_spaceLine];
        
        _sheetContainer.translatesAutoresizingMaskIntoConstraints = NO;
        _sheetLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _spaceLine.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *contain_top = [NSLayoutConstraint constraintWithItem:_sheetContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *contain_left = [NSLayoutConstraint constraintWithItem:_sheetContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *contain_bottom = [NSLayoutConstraint constraintWithItem:_sheetContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_spaceLine attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *contain_right = [NSLayoutConstraint constraintWithItem:_sheetContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        [NSLayoutConstraint activateConstraints:@[contain_top,contain_left,contain_bottom,contain_right]];
        
        NSLayoutConstraint *sheet_top = [NSLayoutConstraint constraintWithItem:_sheetLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_sheetContainer attribute:NSLayoutAttributeTop multiplier:1 constant:XDTipDefaultTopEdge];
        NSLayoutConstraint *sheet_left = [NSLayoutConstraint constraintWithItem:_sheetLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_sheetContainer attribute:NSLayoutAttributeLeading multiplier:1 constant:XDTipDefaultLREdge];
        NSLayoutConstraint *sheet_bottom = [NSLayoutConstraint constraintWithItem:_sheetLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_sheetContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:-XDTipDefaultTopEdge];
        NSLayoutConstraint *sheet_right = [NSLayoutConstraint constraintWithItem:_sheetLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_sheetContainer attribute:NSLayoutAttributeTrailing multiplier:1 constant:-XDTipDefaultLREdge];
        [NSLayoutConstraint activateConstraints:@[sheet_top,sheet_left,sheet_bottom,sheet_right]];
        
        NSLayoutConstraint *line_top = [NSLayoutConstraint constraintWithItem:_spaceLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_sheetContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *line_left = [NSLayoutConstraint constraintWithItem:_spaceLine attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *line_bottom = [NSLayoutConstraint constraintWithItem:_spaceLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *line_rigth = [NSLayoutConstraint constraintWithItem:_spaceLine attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *line_height = [NSLayoutConstraint constraintWithItem:_spaceLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5];
        [NSLayoutConstraint activateConstraints:@[line_top,line_left,line_bottom,line_rigth,line_height]];
        
        [_sheetContainer setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [_spaceLine setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }
    
    return self;
}

- (void)configCellByModel:(XDTipItem *)model isTheEndCell:(BOOL)isEnd isCancelBtn:(BOOL)isCancelBtn {
    _sheetLabel.font = model.data.font;
    _sheetLabel.numberOfLines = model.data.numberOfLines;
    _sheetLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _sheetLabel.text = model.data.text;
    _sheetLabel.textColor = model.data.color;
    
    _model = model;
    _spaceLine.hidden = isEnd;
    
    if (isCancelBtn) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addRoundedCorners:UIRectCornerAllCorners
            withRadii:CGSizeMake(XDTipSheetCorner, XDTipSheetCorner)
                            forView:self.sheetContainer];
        });
        
    
    } else if (isEnd) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addRoundedCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
            withRadii:CGSizeMake(XDTipSheetCorner, XDTipSheetCorner)
                            forView:self.sheetContainer];
        });
    }
}

- (void)highlightCell {
    _sheetContainer.backgroundColor = _model.data.backHightlightColor;
    _sheetLabel.textColor = _model.data.focusColor;
}

- (void)defaultCell {
    _sheetContainer.backgroundColor = _model.data.backDefaultColor;
    _sheetLabel.textColor = _model.data.color;
}

- (void)addRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii forView:(UIView *)view {
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}

@end




 
#pragma mark - class XXTipAlertUI()
@interface _XXTipAlertUI () <UICollectionViewDataSource, _XXTipAlertLayoutDelegate, UICollectionViewDelegate>
@property (nonatomic,   copy) void(^tipHiddenBlock)(void);
@property (nonatomic,   copy) void(^tapBlock)(void);
@property (nonatomic,   copy) void(^actionBlock)(NSInteger index, NSString *text, BOOL cancelByErea);
@property (nonatomic, strong) UIView *alphaBackView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *alertHeader;
@property (nonatomic, strong) UICollectionView *alertView;
@property (nonatomic, strong) _XXTipAlertLayout *layout;
@property (nonatomic, strong) _XXTipModel *model;
@end
@implementation _XXTipAlertUI

- (instancetype)initWithFrame:(CGRect)frame model:(_XXTipModel *)model action:(void (^)(NSInteger, NSString *, BOOL))action hiddenFinish:(void (^)(void))finish {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.actionBlock = action;
        self.tipHiddenBlock = finish;
        self.model = model;
        [self alertShow];
    }
    
    return self;
}

- (void)alertShow {
    [self configModel];
    [self configHeader];
    [self configAlert];
    [self configContainer];
    
    [self addSubview:self.alphaBackView];
    [self addSubview:self.containerView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alphaBackView.alpha = 0.5;
        self.containerView.alpha = 1;
    }];
}

- (void)alertHiddenIndex:(NSInteger)index cancelByErea:(BOOL)cancelByErea {
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.alphaBackView.alpha = 0;
        self.containerView.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (self.tipHiddenBlock) {
            self.tipHiddenBlock();
        }
        NSString *text = index >= 0 ? self.model.tipElements[index].data.text : nil;
        if (self.actionBlock) {
            self.actionBlock(index, text, cancelByErea);
        }
    }];
}

- (void)configModel {
    NSInteger elementCount = self.model.tipElements.count;
    [self.model.tipElements enumerateObjectsUsingBlock:^(XDTipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        _XXTipData *data = obj.data;
        CGFloat itemWidth = elementCount == 2 ? (XDTipAlertWidth/2.0-2*XDTipDefaultLREdge) : (XDTipAlertWidth-2*XDTipDefaultLREdge);
        UILabel *mid = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, itemWidth, 0)];
        
        mid.textAlignment = NSTextAlignmentCenter;
        mid.numberOfLines = data.numberOfLines;
        mid.textColor = data.color;
        mid.font = data.font;
        mid.text = data.text;
        
        CGSize size = [mid sizeThatFits:CGSizeMake(itemWidth, MAXFLOAT)];
        
        if (size.height > data.height-2*XDTipDefaultTopEdge) {
            data.height = size.height+2*XDTipDefaultTopEdge;
        }
        
        mid = nil;
        
    }];
}

- (void)configHeader {
    CGFloat titleToTop = XDTipDefaultTopEdge*2.5;
    CGFloat titleToEdge = XDTipDefaultLREdge;
    
    UILabel *title, *subTitle, *content;
    
    if (self.model.tipTitle) {
        _XXTipData *data = self.model.tipTitle.data;
        title = [[UILabel alloc]initWithFrame:CGRectMake(titleToEdge,
                                                         titleToTop,
                                                         XDTipAlertWidth-2*titleToEdge,
                                                         0)];
        title.textAlignment = NSTextAlignmentCenter;
        title.backgroundColor = UIColor.clearColor;
        title.numberOfLines = data.numberOfLines;
        title.textColor = data.color;
        title.font = data.font;
        title.text = data.text;
        
        CGSize titleSize = [title sizeThatFits:CGSizeMake(XDTipAlertWidth-2*titleToEdge, MAXFLOAT)];
        CGFloat titleHeight = data.height < titleSize.height ? titleSize.height : data.height;
        
        [title setFrame:CGRectMake(CGRectGetMinX(title.frame),
                                   CGRectGetMinY(title.frame),
                                   CGRectGetWidth(title.frame),
                                   titleHeight)];
        
        CGFloat headerHeight = CGRectGetMaxY(title.frame)+titleToTop;
        [self.alertHeader setFrame:CGRectMake(0,
                                              0,
                                              XDTipAlertWidth,
                                              headerHeight)];
        
        [self.alertHeader addSubview:title];
    }
    
    if (self.model.tipSubTitle) {
        _XXTipData *data = self.model.tipSubTitle.data;
        CGFloat offy = title ? CGRectGetMaxY(title.frame)+5 : titleToTop;
        subTitle = [[UILabel alloc]initWithFrame:CGRectMake(titleToEdge,
                                                            offy,
                                                            XDTipAlertWidth-2*titleToEdge,
                                                            0)];
        subTitle.textAlignment = NSTextAlignmentCenter;
        subTitle.backgroundColor = UIColor.clearColor;
        subTitle.numberOfLines = data.numberOfLines;
        subTitle.textColor = data.color;
        subTitle.font = data.font;
        subTitle.text = data.text;
        
        CGSize subTitleSize = [subTitle sizeThatFits:CGSizeMake(XDTipAlertWidth-2*titleToEdge, MAXFLOAT)];
        CGFloat subTitleHeight = data.height < subTitleSize.height ? subTitleSize.height : data.height;
        
        [subTitle setFrame:CGRectMake(CGRectGetMinX(subTitle.frame),
                                      CGRectGetMinY(subTitle.frame),
                                      CGRectGetWidth(subTitle.frame),
                                      subTitleHeight)];
        
        CGFloat headerHeight = CGRectGetMaxY(subTitle.frame)+titleToTop;
        [self.alertHeader setFrame:CGRectMake(0,
                                              0,
                                              XDTipAlertWidth,
                                              headerHeight)];
        
        [self.alertHeader addSubview:subTitle];
    }
    
    if (self.model.tipContent) {
        _XXTipData *data = self.model.tipContent.data;
        
        CGFloat offy = 0;
        if (title) {
            offy = CGRectGetMaxY(title.frame)+10;
        }
        if (subTitle) {
            offy = CGRectGetMaxY(subTitle.frame)+10;
        }
        
        content = [[UILabel alloc]initWithFrame:CGRectMake(titleToEdge,
                                                           offy,
                                                           XDTipAlertWidth-2*titleToEdge,
                                                           0)];
        content.backgroundColor = UIColor.clearColor;
        content.clipsToBounds = YES;
        content.numberOfLines = data.numberOfLines;
        content.textColor = data.color;
        content.font = data.font;
        content.text = data.text;
        
        CGSize desSize = [content sizeThatFits:CGSizeMake(XDTipAlertWidth-2*titleToEdge, MAXFLOAT)];
        
        CGFloat offx = (XDTipAlertWidth-desSize.width)/2.0;
        CGFloat width = desSize.width;
        
        if (desSize.width > XDTipAlertWidth-2*titleToEdge) {
            offx = titleToEdge;
            width = XDTipAlertWidth-2*titleToEdge;
        }
        
        [content setFrame:CGRectMake(offx, offy, width, desSize.height)];
        
        CGFloat headerHeight = CGRectGetMaxY(content.frame)+titleToTop;
        [self.alertHeader setFrame:CGRectMake(0,
                                              0,
                                              XDTipAlertWidth,
                                              headerHeight)];
        
        [self.alertHeader addSubview:content];
    }
}

- (void)configAlert {
    NSInteger elementCount = self.model.tipElements.count;
    
    __block CGFloat height = 0;
    
    if (elementCount == 2) {
        height = MAX(self.model.tipElements.firstObject.data.height, self.model.tipElements.lastObject.data.height)+0.5;
    } else {
        [self.model.tipElements enumerateObjectsUsingBlock:^(XDTipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            height += obj.data.height + 0.5;
        }];
    }
    
    [self.alertView setFrame:CGRectMake(0,
                                        CGRectGetMaxY(self.alertHeader.frame),
                                        XDTipAlertWidth,
                                        height)];
}

- (void)configContainer {
    
    CGFloat height = CGRectGetHeight(self.alertHeader.frame)+CGRectGetHeight(self.alertView.frame);
    CGFloat offx = (CGRectGetWidth([UIScreen mainScreen].bounds)-XDTipAlertWidth)/2.0;
    CGFloat offy = (CGRectGetHeight([UIScreen mainScreen].bounds)-height)*0.5;
    
    [self.containerView setFrame:CGRectMake(offx,
                                            offy,
                                            XDTipAlertWidth,
                                            height)];
    
    [self.containerView addSubview:self.alertHeader];
    [self.containerView addSubview:self.alertView];
    
    [self addRoundedCorners:UIRectCornerAllCorners
                  withRadii:CGSizeMake(XDTipAlertCorner, XDTipAlertCorner)
                    forView:self.containerView];
}

#pragma mark - lazy load
- (UIView *)alphaBackView {
    if (!_alphaBackView) {
        _alphaBackView = [[UIView alloc]initWithFrame:self.bounds];
        _alphaBackView.alpha = 0;
        _alphaBackView.backgroundColor = [UIColor blackColor];
        __weak typeof(self) weakSelf = self;
        [self tapView:_alphaBackView action:^{
            if (weakSelf.model.cancelByErea) {
                [weakSelf alertHiddenIndex:-1 cancelByErea:YES];
            }
        }];
    }
    
    return _alphaBackView;
}

- (UIView *)alertHeader {
    
    if (!_alertHeader) {
        _alertHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, XDTipAlertWidth, XDTipDefaultTopEdge*2.5)];
        _alertHeader.backgroundColor = XDTipDefaultColor;
    }
    
    return _alertHeader;
}

- (UIView *)containerView {
    
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
        _containerView.alpha = 0;
        _containerView.backgroundColor = UIColor.lightGrayColor;
    }
    
    return _containerView;
}

- (UICollectionView *)alertView {
    if (!_alertView) {
        _layout = [_XXTipAlertLayout layout];
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 0;
        _layout.delegate = self;
        
        _alertView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, XDTipAlertWidth, 30) collectionViewLayout:_layout];
        _alertView.backgroundColor = UIColor.lightGrayColor;
        _alertView.delegate = self;
        _alertView.dataSource = self;
        [_alertView registerClass:_XXTipAlertItem.class forCellWithReuseIdentifier:@"_XXTipAlertItem"];
    }
    
    return _alertView;
}

#pragma mark - collection delegate datasouce
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.tipElements.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _XXTipAlertItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"_XXTipAlertItem" forIndexPath:indexPath];
    [item configCellByModel:self.model.tipElements[indexPath.row]];
    
    return item;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self alertHiddenIndex:indexPath.row cancelByErea:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    _XXTipAlertItem *item = ((_XXTipAlertItem*)[collectionView cellForItemAtIndexPath:indexPath]);
    [item highlightItem];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    _XXTipAlertItem *item = ((_XXTipAlertItem*)[collectionView cellForItemAtIndexPath:indexPath]);
    [item defaultItem];
}

#pragma mark - layout deletate

- (CGFloat)_xx_layoutItemVerticalSpaceInSection:(NSInteger)section {
    return 0.5;
}

- (CGFloat)_xx_layoutItemHorizontalSpaceInSection:(NSInteger)section {
    return 0.5;
}

- (CGFloat)_xx_layoutItemHeightByWidth:(CGFloat)itemWidth indexPath:(NSIndexPath *)indexPath {
    return self.model.tipElements[indexPath.row].data.height;
}

#pragma mark - private method
- (void)tapView:(UIView *)view action:(void(^)(void))action {
    self.tapBlock = action;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(alphaTap)];
    [view addGestureRecognizer:tap];
}

- (void)alphaTap {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (void)addRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii forView:(UIView *)view {
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}

@end







#pragma mark - class XXTipAlertItem()

@interface _XXTipAlertItem ()
@property (nonatomic, strong) UIView *alertContainer;
@property (nonatomic, strong) UILabel *alertLabel;
@property (nonatomic, strong) XDTipItem *model;
@end
@implementation _XXTipAlertItem

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        
        _alertContainer = [[UIView alloc]initWithFrame:CGRectZero];
        _alertContainer.backgroundColor = XDTipDefaultColor;
        _alertContainer.clipsToBounds = YES;
        [self.contentView addSubview:_alertContainer];
        
        _alertLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.backgroundColor = UIColor.clearColor;
        
        [_alertContainer addSubview:_alertLabel];
        
        _alertContainer.translatesAutoresizingMaskIntoConstraints = NO;
        _alertLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *contain_top = [NSLayoutConstraint constraintWithItem:_alertContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *contain_left = [NSLayoutConstraint constraintWithItem:_alertContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *contain_bottom = [NSLayoutConstraint constraintWithItem:_alertContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *contain_right = [NSLayoutConstraint constraintWithItem:_alertContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        [NSLayoutConstraint activateConstraints:@[contain_top,contain_left,contain_bottom,contain_right]];
        
        NSLayoutConstraint *alert_top = [NSLayoutConstraint constraintWithItem:_alertLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_alertContainer attribute:NSLayoutAttributeTop multiplier:1 constant:XDTipDefaultTopEdge];
        NSLayoutConstraint *alert_left = [NSLayoutConstraint constraintWithItem:_alertLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_alertContainer attribute:NSLayoutAttributeLeading multiplier:1 constant:XDTipDefaultLREdge];
        NSLayoutConstraint *alert_bottom = [NSLayoutConstraint constraintWithItem:_alertLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_alertContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:-XDTipDefaultTopEdge];
        NSLayoutConstraint *alert_right = [NSLayoutConstraint constraintWithItem:_alertLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_alertContainer attribute:NSLayoutAttributeTrailing multiplier:1 constant:-XDTipDefaultLREdge];
        [NSLayoutConstraint activateConstraints:@[alert_top,alert_left,alert_bottom,alert_right]];
    }
    
    return self;
}

- (void)configCellByModel:(XDTipItem *)model {
    _alertLabel.font = model.data.font;
    _alertLabel.numberOfLines = model.data.numberOfLines;
    _alertLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _alertLabel.text = model.data.text;
    _alertLabel.textColor = model.data.color;
    
    _model = model;
}

- (void)highlightItem {
    _alertContainer.backgroundColor = _model.data.backHightlightColor;
    _alertLabel.textColor = _model.data.focusColor;
}

- (void)defaultItem {
    _alertContainer.backgroundColor = _model.data.backDefaultColor;
    _alertLabel.textColor = _model.data.color;
}

@end








#pragma mark - class XXTipAlertLayout()

@interface _XXTipAlertLayout ()
@property (nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *>*attributesArray;
@property (nonatomic, assign) CGFloat v_cursor;
@property (nonatomic, assign) CGFloat max_vcursor;
@property (nonatomic, assign) NSInteger columnCount;
@end
@implementation _XXTipAlertLayout

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)layout{
    return [[self alloc]init];
}

- (NSMutableArray *)attributesArray {
    if (!_attributesArray) {
        _attributesArray = [NSMutableArray array];
    }
    return _attributesArray;
}

- (void)prepareLayout {
    [super prepareLayout];
    [self.attributesArray removeAllObjects];
    
    if (@available(iOS 10.0, *)) {
        if ([self.collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            self.collectionView.prefetchingEnabled = NO;
        }
    }
    
    self.v_cursor = 0;
    self.max_vcursor = 0;
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    _columnCount = itemCount == 2 ? 2 : 1;
    
    for (int j = 0; j < itemCount; j ++) {
        
        UICollectionViewLayoutAttributes *rowAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:0]];
        
        self.v_cursor = _columnCount==2 ? 0 : self.max_vcursor;
        
        [self.attributesArray addObject:rowAttr];
    }
    
    self.v_cursor = _columnCount==2 ? self.max_vcursor : self.v_cursor;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    
    CGFloat hspace = 0;
    
    if ([self.delegate respondsToSelector:@selector(_xx_layoutItemHorizontalSpaceInSection:)]) {
        hspace = [self.delegate _xx_layoutItemHorizontalSpaceInSection:indexPath.section];
    }
    
    hspace = hspace > 0 ? hspace : 0;
    
    CGFloat vspace = 0;
    if ([self.delegate respondsToSelector:@selector(_xx_layoutItemVerticalSpaceInSection:)]) {
        vspace = [self.delegate _xx_layoutItemVerticalSpaceInSection:indexPath.section];
    }
    vspace = vspace > 0 ? vspace : 0;
    
    CGFloat itemWidth = (collectionViewWidth - hspace*(_columnCount - 1))/_columnCount;
    
    if (_columnCount == 2) {
        CGFloat scale = 1.0/[UIScreen mainScreen].scale;
        itemWidth = round(itemWidth) > itemWidth ? ceil(itemWidth)+2*scale: ceil(itemWidth)+scale;
    }
    
    CGFloat itemHeight = 0;
    
    if ([self.delegate respondsToSelector:@selector(_xx_layoutItemHeightByWidth:indexPath:)]) {
        itemHeight = [self.delegate _xx_layoutItemHeightByWidth:itemWidth indexPath:indexPath];
    }
    
    itemHeight = itemHeight > 0 ? itemHeight : 0;
    
    // 当前列
    NSInteger currentColumn = indexPath.row%_columnCount;
    
    //orgin.x
    CGFloat x = (hspace + itemWidth) * currentColumn;
    //orgin.y
    CGFloat y = vspace + self.v_cursor;
    
    CGFloat fixWidth = (currentColumn == _columnCount-1 && _columnCount==2) ? (collectionViewWidth-(hspace+itemWidth)*(_columnCount - 1)) : itemWidth;
    attributes.frame = CGRectMake(x, y, fixWidth, itemHeight);
    
    if (_columnCount == 2) {
        _max_vcursor = _max_vcursor < itemHeight ? itemHeight : _max_vcursor;
    } else {
        _max_vcursor += vspace + itemHeight;
    }
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), self.v_cursor);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributesArray;
}

@end
