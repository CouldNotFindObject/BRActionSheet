//
//  JWDConfirOrderController.h
//  JueweiEBuy
//
//  Created by 白蕊 on 15/12/11.
//  Copyright © 2015年 书海. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWDConfirOrderController : UIViewController

@property (nonatomic,strong)NSMutableArray * confirmOrderArr;


//接收user的字典
@property (nonatomic,strong)NSMutableDictionary *userDictionary;

//接收cart的数组
@property (nonatomic,strong)NSMutableArray *cartArray;

//接收开始时间
@property (nonatomic,copy)NSNumber *stary_time;

//接收结束时间
@property (nonatomic,copy)NSNumber *end_time;
@end
