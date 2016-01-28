//
//  JWDChooseCouponController.h
//  JueweiEBuy
//
//  Created by 白蕊 on 15/12/22.
//  Copyright © 2015年 书海. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coupon.h"
///////////////////
@protocol BaiRuiDelegate <NSObject>

- (void)passValueAboutIndexPath:(NSIndexPath *)indexPath;

@end

//////////////////


typedef void (^PassValueBlock)(Coupon *);


@interface JWDChooseCouponController : UIViewController

//声明Block的属性
@property (nonatomic,copy)PassValueBlock passValueBlock;

@property (nonatomic,strong)NSMutableArray *couponArr;

@property (nonatomic,assign)NSInteger countt;
//接收前一个页面的钱数
@property (nonatomic,copy)NSString *pay_money;
@property (nonatomic,strong)Coupon *coupon;




#warning 新家
@property (nonatomic, strong) NSIndexPath *path;

@property (nonatomic, assign) id <BaiRuiDelegate> delegate;

////////////////////
@end
