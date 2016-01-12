//
//  BRSheetView.m
//  BRActionSheet
//
//  Created by 佟锡杰 on 16/1/10.
//  Copyright © 2016年 tongxijie. All rights reserved.
//
#define kDuration 0.25
#define kKeyWindow ([UIApplication sharedApplication].keyWindow)
#import "BRSheetView.h"

@interface BRSheetView ()
//背景view
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) BOOL isAnimating;
@end

@implementation BRSheetView


+ (instancetype)sheetViewWithDelegate:(id<BRSheetViewDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate];
}

- (instancetype)initWithDelegate:(id<BRSheetViewDelegate>)delegate
{
    if (self = [super init]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"BRSheetView" owner:nil options:nil] lastObject];
        self.delegate = delegate;
        
    }
    return self;
}

/**
 *  显示
 *
 */
- (void)showBRSheet
{
    if (self.isAnimating) {
        return ;
    }
    if (self.backView == nil) {
        self.backView  = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.backView.backgroundColor = [UIColor blackColor];
        self.backView.alpha = 0.5;
        [kKeyWindow addSubview:self.backView];
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBRSheet)];
        [kKeyWindow addSubview:self];
        self.frame = CGRectMake(0, kKeyWindow.frame.size.height, kKeyWindow.frame.size.width, self.frame.size.height);
        
        
        [self.backView addGestureRecognizer:_tap];
        
        // 0.3秒后改变view的frame
        self.isAnimating = YES;
        [UIView animateWithDuration:kDuration animations:^{
            self.frame = CGRectMake(0, kKeyWindow.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished) {
            if([self.delegate respondsToSelector:@selector(brsheetDidShow:)]) {
                self.contentStr = self.contentTf.text;
                [self.delegate brsheetDidShow:self];
            }
            self.isAnimating = NO;
        }];
        
    }
    
}
/**
 *  隐藏
 */
- (void)hideBRSheet
{
    
    if (self.isAnimating) {
        return ;
    }
    self.isAnimating = YES;
    [UIView animateWithDuration:kDuration animations:^{
        self.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        if([self.delegate respondsToSelector:@selector(brsheetDidHide:)]) {
            self.contentStr = self.contentTf.text;
            [self.delegate brsheetDidHide:self];
        }
        [self.backView removeGestureRecognizer:self.tap];
        [self.backView removeFromSuperview];
        [self removeFromSuperview];
        self.backView = nil;
        self.contentTf.text = @"";
        self.isAnimating = NO;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
}

- (void)dealloc
{
    self.delegate = nil;
    NSLog(@"已经销毁");

}
- (IBAction)saveAction:(id)sender {
    if([self.delegate respondsToSelector:@selector(brsheetsaveButtonClicked:)]) {
        self.contentStr = self.contentTf.text;
        [self.delegate brsheetsaveButtonClicked:self];
    }
    [self hideBRSheet];
}

@end
