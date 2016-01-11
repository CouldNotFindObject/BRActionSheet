//
//  BRSheetView.h
//  BRActionSheet
//
//  Created by 佟锡杰 on 16/1/10.
//  Copyright © 2016年 tongxijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  BRSheetView;

@protocol BRSheetViewDelegate <NSObject>
@optional
- (void)brsheetDidShow:(BRSheetView *)sheet;
- (void)brsheetDidHide:(BRSheetView *)sheet;
- (void)brsheetsaveButtonClicked:(BRSheetView *)sheet;

@end

@interface BRSheetView : UIView
/**标题*/
@property (weak, nonatomic) IBOutlet UILabel *customLabel;
/**副标题*/
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
/**文本输入框*/
@property (weak, nonatomic) IBOutlet UITextField *contentTf;
/**保存按钮*/
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
/**文本输入框内容*/
@property (nonatomic, strong) NSString *contentStr;

@property (nonatomic, weak) id<BRSheetViewDelegate> delegate;
/**初始化方法*/
+ (instancetype)sheetViewWithDelegate:(id<BRSheetViewDelegate>)delegate;

/**
 *  弹出SheetView
 *
 */
- (void)showBRSheet;
/**
 *  隐藏SheetView
 */
- (void)hideBRSheet;
@end
