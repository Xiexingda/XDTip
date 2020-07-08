//
//  XDTip.h
//  XDActionBox
//
//  Created by 谢兴达 on 2020/4/17.
//  Copyright © 2020 xie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XDTipItem;

typedef NS_ENUM(NSInteger, _XXTipType) {
    _XXTip_Sheet,
    _XXTip_Alert
};

@interface XDTip : UIViewController

// sheet
+ (XDTipItem *)sheet;

+ (void)showSheetTitle:(XDTipItem *)title
              subTitle:(XDTipItem *)subTitle
              elements:(NSArray <XDTipItem *>*)elements
        cancelBtnTitle:(XDTipItem *)cancelBtnTitle
          cancelByErea:(BOOL)cancelByErea
                action:(void(^)(NSInteger index, NSString *text, BOOL cancelByBtn, BOOL cancelByErea))action;

// alert
+ (XDTipItem *)alert;

+ (void)showAlertTitle:(XDTipItem *)title
              subTitle:(XDTipItem *)subTitle
               content:(XDTipItem *)content
              elements:(NSArray <XDTipItem *>*)elements
          cancelByErea:(BOOL)cancelByErea
                action:(void(^)(NSInteger index, NSString *text, BOOL cancelByErea))action;
@end




@interface XDTipItem : NSObject
// 带有默认属性
- (XDTipItem *(^)(NSString *text))title;
- (XDTipItem *(^)(NSString *text))subTitle;
- (XDTipItem *(^)(NSString *text))cancelBtnTitle;
- (XDTipItem *(^)(NSString *text))element;
- (XDTipItem *(^)(NSString *text))content;

// 对应属性
- (XDTipItem *(^)(UIColor *color))color;
- (XDTipItem *(^)(UIColor *focusColor))focusColor;
- (XDTipItem *(^)(UIFont *font))font;
- (XDTipItem *(^)(NSString *text))text;
- (XDTipItem *(^)(CGFloat height))height;
- (XDTipItem *(^)(NSInteger numberOfLines))numberOfLines;
- (XDTipItem *(^)(UIColor *backDefaultColor))backDefaultColor;
- (XDTipItem *(^)(UIColor *backHightlightColor))backHightlightColor;

- (instancetype)initByType:(_XXTipType)type;
@end




@interface _XXTipData : NSObject
@property (nonatomic,   copy) NSString  *text;
@property (nonatomic, strong) UIColor   *color;
@property (nonatomic, strong) UIColor   *focusColor;
@property (nonatomic, strong) UIFont    *font;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger numberOfLines;
@property (nonatomic, strong) UIColor   *backDefaultColor;
@property (nonatomic, strong) UIColor   *backHightlightColor;
@end




@interface _XXTipModel : NSObject
@property (nonatomic, assign) BOOL cancelByErea;
@property (nonatomic, strong) XDTipItem *tipDes;
@property (nonatomic, strong) XDTipItem *tipTitle;
@property (nonatomic, strong) XDTipItem *tipSubTitle;
@property (nonatomic, strong) XDTipItem *tipCancelTitle;
@property (nonatomic, strong) NSArray<XDTipItem *> *tipElements;
@end




@interface _XXTipSheetUI : UIView
- (instancetype)initWithFrame:(CGRect)frame model:(_XXTipModel *)model action:(void(^)(NSInteger index, NSString *text, BOOL cancelByBtn, BOOL cancelByErea))action hiddenFinish:(void(^)(void))finish;

@end




@interface _XXTipSheetCell : UITableViewCell
- (void)configCellByModel:(XDTipItem *)model isTheEndCell:(BOOL)isEnd isCancelBtn:(BOOL)isCancelBtn;
- (void)highlightCell;
- (void)defaultCell;
@end




@interface _XXTipAlertUI : UIView
- (instancetype)initWithFrame:(CGRect)frame model:(_XXTipModel *)model action:(void(^)(NSInteger index, NSString *text, BOOL cancelByErea))action hiddenFinish:(void(^)(void))finish;

@end







@interface _XXTipAlertItem : UICollectionViewCell
- (void)configCellByModel:(XDTipItem *)model;
- (void)highlightItem;
- (void)defaultItem;
@end







@protocol _XXTipAlertLayoutDelegate <NSObject>
@optional

- (CGFloat)_xx_layoutItemHeightByWidth:(CGFloat)itemWidth indexPath:(NSIndexPath *)indexPath;

- (CGFloat)_xx_layoutItemVerticalSpaceInSection:(NSInteger)section;

- (CGFloat)_xx_layoutItemHorizontalSpaceInSection:(NSInteger)section;

@end

@interface _XXTipAlertLayout : UICollectionViewFlowLayout
@property (nonatomic, weak) id <_XXTipAlertLayoutDelegate> delegate;
+ (instancetype)layout;
@end



