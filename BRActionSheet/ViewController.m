//
//  ViewController.m
//  BRActionSheet
//
//  Created by 佟锡杰 on 16/1/10.
//  Copyright © 2016年 tongxijie. All rights reserved.
//

#import "ViewController.h"
#import "BRSheetView.h"

@interface ViewController ()<BRSheetViewDelegate>
@property (nonatomic, strong) BRSheetView *sheetView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.sheetView = [BRSheetView sheetViewWithDelegate:self];
    self.sheetView.customLabel.text = @"白蕊sheet";
    self.sheetView.subLabel.text = @"多少字都行";
}


- (IBAction)aaaaup:(id)sender {
    //show之前给他赋值
    self.sheetView.recordIndexPath = [[NSIndexPath alloc] initWithIndex:0];
    [self.sheetView showBRSheet];

}
//三个代理方法,三个时机,不过差不多
- (void)brsheetDidShow:(BRSheetView *)sheet
{
    NSLog(@"sheet show --- %@",sheet.contentStr);

}
- (void)brsheetsaveButtonClicked:(BRSheetView *)sheet
{
    NSLog(@"save button cliked %@",sheet.contentStr);
}
- (void)brsheetDidHide:(BRSheetView *)sheet
{
    
    NSLog(@"sheet hide --- %@",sheet.contentStr);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
