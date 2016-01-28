//
//  JWDChooseCouponController.m
//  JueweiEBuy
//
//  Created by 白蕊 on 15/12/22.
//  Copyright © 2015年 书海. All rights reserved.
//
/** 订单里面的选择红包 */
#define JWDChooseCouponURL @"http://testapi.juewei.com/api/my/coupon"

#import "JWDChooseCouponController.h"

#import "ChosecouponCell.h"
#import "CouponFooterView.h"
#import "CouponHeaderView.h"
#import "Coupon.h"
#import "JWDHisCouponController.h"
#import "JWDCouponIntroduceController.h"
#import "AFNetworking.h"
#define AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES
@interface JWDChooseCouponController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionReusableView *reusableview;
@property (nonatomic,strong)NSString *reduceMoney;
@property (nonatomic,copy)NSMutableArray *dataArray;


@property (nonatomic,strong)ChosecouponCell *couponCell;
@end

@implementation JWDChooseCouponController

//懒加载


- (NSInteger)countt{
    
    if (!_countt) {
        self.countt = 0;
    }
    return _countt;
}
- (NSMutableArray *)couponArr{

    if (!_couponArr) {
        
        self.couponArr = [NSMutableArray array];
    }
    
    return _couponArr;
}
- (NSMutableArray *)dataArray{
    
    if (!_dataArray) {
        
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"优惠券";
   [self updataChooseCoupon];
    self.view.backgroundColor = [UIColor colorWithRed:242.0/256 green:242.0/256 blue:242.0/256 alpha:1.0];
    //右边的navigation隐藏
    self.navigationItem.rightBarButtonItem = nil;
    
}
//请求数据
- (void)updataChooseCoupon{
    
    JWLog(@"fansi le 乐乐%@",TOKEN);
    NSDictionary *dict = @{
                           @"uuid":USERS_ID,
                           @"type":@"order",
                           @"page":@1,
                           @"money":_pay_money,
                           @"token":TOKEN
                               };
    //请求数据
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [mgr POST:JWDChooseCouponURL parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
               if ([responseObject[@"code"] isEqual:@0]){
        
                NSMutableArray *dataArr = responseObject[@"data"];
        
                self.dataArray = dataArr;
                    JWLog(@"dataArr : %@",dataArr);
        
                    for (NSDictionary *dataDic in dataArr) {
        
                        Coupon *coupon = [Coupon new];
        
                        [coupon setValuesForKeysWithDictionary:dataDic];
        
                        self.reduceMoney = coupon.money;
        
                        [self.couponArr addObject:coupon];
        
                    }
                //布局优惠券
                [self layoutCoupon];
                [self.collectionView reloadData];
                }else{
                    
        #pragma mark -
                    
                }
     
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
//布局优惠券
- (void)layoutCoupon{

    JWLog(@"lalalla %ld",_dataArray.count);
    
    if (_dataArray.count == 0) {
        //布局button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.frame = CGRectMake(SCREEN_WIDTH - 70, 10, 10, 10);
        
        [button setBackgroundImage:[UIImage imageNamed:@"tip_coupon"] forState:(UIControlStateNormal)];
        //添加action
        [button addTarget:self action:@selector(butAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:button];
        //布局labble
        UILabel *useInfo = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 10, 50, 12)];
        useInfo.text = @"使用说明";
        useInfo.textAlignment = 1;
        useInfo.tintColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0];
        useInfo.font = [UIFont systemFontOfSize:10.0];
        [self.view addSubview:useInfo];
        //布局 图片
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wu_coupon"]];
        
        image.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 3);
        image.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.view addSubview:image];
        
        //布局 过期优惠券 按钮
        //布局button
        UIButton *outbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        outbutton.frame = CGRectMake(0, SCREEN_HEIGHT - 164, SCREEN_WIDTH, 60);
        [outbutton setTitle:@"过期优惠券查询" forState:(UIControlStateNormal)];
        outbutton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        
        [outbutton setTitleColor:[UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0] forState:(UIControlStateNormal)];
        //添加action
        [outbutton addTarget:self action:@selector(outbuttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        
        [self.view addSubview:outbutton];
              
    }
    else{
    // 2.创建UICollectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) collectionViewLayout:layout];

    collectionView.backgroundColor =[UIColor colorWithRed:242.0/256 green:242.0/256 blue:242.0/256 alpha:1.0];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    //注册cell
    [collectionView registerNib:[UINib nibWithNibName:@"ChosecouponCell" bundle:nil] forCellWithReuseIdentifier:@"coupon"];
    
    //注册自定义页眉
[collectionView registerNib:[UINib nibWithNibName:@"CouponHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];

    //注册自定义页脚
    [collectionView registerNib:[UINib nibWithNibName:@"CouponFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    
    self.collectionView = collectionView;
    
    [self.view addSubview:collectionView];
    }
    
}
#pragma mark - UICollectionViewDataSource UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

     JWLog(@"%ld",_couponArr.count);
    return _couponArr.count;
   
}

//header
- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    self.reusableview = nil;
    
     if (kind == UICollectionElementKindSectionHeader) {
        CouponHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        
         //添加轻拍手势
         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(UseCoupon:)];
         
         tap.numberOfTapsRequired = 1;
         
         
        _reusableview = headerView;
         
         [self.reusableview addGestureRecognizer:tap];
         

        _reusableview.backgroundColor = [UIColor whiteColor];
         
     }else {
     
         CouponFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];

         _reusableview = footerView;

         _reusableview.backgroundColor = [UIColor colorWithRed:242.0/256 green:242.0/256 blue:242.0/256 alpha:1.0];
         
         //添加轻拍手势
         UITapGestureRecognizer *tap  =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hisCoupon:)];
         
         tap.numberOfTapsRequired = 1;
         
         
         [_reusableview addGestureRecognizer:tap];
   
     }
    return _reusableview;
    
}

//header高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(SCREEN_WIDTH, 50);
    
}
//footer高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    return CGSizeMake(SCREEN_WIDTH, 60);
    
}

// 红包使用规则说明
- (void)UseCoupon:(UITapGestureRecognizer *)useCoupon{

    JWLog(@"红包使用规则说明");
    JWDCouponIntroduceController *couponIntro = [JWDCouponIntroduceController new];
    
    [self.navigationController pushViewController:couponIntro animated:YES];
   

}
- (void)butAction:(UIButton *)coupon{
    
    JWLog(@"红包使用规则说明");
    JWDCouponIntroduceController *couponIntro = [JWDCouponIntroduceController new];
    
    [self.navigationController pushViewController:couponIntro animated:YES];
}


- (void)outbuttonAction:(UIButton *)his{
    
    JWLog(@"过期红包纪录");
    JWDHisCouponController *hisVC = [JWDHisCouponController new];
    
    [self.navigationController pushViewController:hisVC animated:YES];
    
}

//过期红包纪录
- (void)hisCoupon:(UITapGestureRecognizer *)historyCoupn{
    
    JWLog(@"过期红包纪录");
    JWDHisCouponController *hisVC = [JWDHisCouponController new];
    
    [self.navigationController pushViewController:hisVC animated:YES];
    
}

//设置cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ChosecouponCell *choose = [collectionView dequeueReusableCellWithReuseIdentifier:@"coupon" forIndexPath:indexPath];
#warning 新家
    BOOL isSelectCell = indexPath.section == _path.section && indexPath.row == _path.row;
    if (isSelectCell)
    {
        _couponCell.pic_choose.image = [UIImage imageNamed:@"choose_coupon"];
    }
    /////////////
    
    Coupon *chooseCoupon = _couponArr[indexPath.row];
    
    if ([chooseCoupon.ID isEqualToString:_coupon.ID]) {
        
        
        chooseCoupon = _coupon;
    }
    
    
    if ([chooseCoupon.is_used isEqualToString:@"0"]) {
        
        //背景图片
        choose.pic_image.image = [UIImage imageNamed:@"bg_coupon_hong"];
        
        //满 元
        NSInteger allM = [chooseCoupon.full_money integerValue];
        NSString *all_money = [NSString stringWithFormat:@"满%ld元",allM];
        choose.money.text = all_money;

        //减 元        CGFloat reduce = [chooseCoupon.money floatValue];
        CGFloat reduce = [chooseCoupon.money floatValue];
        NSString *re = [NSString stringWithFormat:@"%.0f",reduce];
        choose.reduce_money.text = re;
        
        //日期 时间戳转时间
       NSDate *dates = [NSDate dateWithTimeIntervalSince1970:[chooseCoupon.end_time integerValue]];
        choose.date.text = [[NSString stringWithFormat:@"%@",dates] substringToIndex:10];
        
        //结束时间的 月
        NSDateFormatter *formatterMend = [NSDateFormatter new];
        //        [formatterNow setDateStyle:NSDateFormatterMediumStyle];
        [formatterMend setDateFormat:@"MM"];
        NSDate  *dateMend = [formatterMend dateFromString:chooseCoupon.end_time];
        NSString *dateMendStr = [NSString stringWithFormat:@"%@",dateMend];
        NSInteger dateMendIn = [dateMendStr integerValue];
        
        // 日
        NSDateFormatter *formatterDend = [NSDateFormatter new];
        [formatterDend setDateFormat:@"dd"];
        NSDate *dateDend = [formatterDend dateFromString:chooseCoupon.end_time];
        NSString *dateDendStr = [NSString stringWithFormat:@"%@",dateDend];
        NSInteger dateDendIn = [dateDendStr integerValue];

        //所剩天数
        //获取当前的时间 月
        NSDateFormatter *formatterM= [NSDateFormatter new];
//        [formatterNow setDateStyle:NSDateFormatterMediumStyle];
        [formatterM setDateFormat:@"MM"];
        NSString *dateM = [formatterM stringFromDate:[NSDate date]];
        NSInteger dateI = [dateM integerValue];
        // 日
        NSDateFormatter *formatterD = [NSDateFormatter new];
        [formatterD setDateFormat:@"dd"];
        NSString *dateD = [formatterD stringFromDate:[NSDate date]];
        NSInteger dateDi = [dateD integerValue];
        
        NSInteger dateC = dateDendIn - dateDi;
        if (dateMendIn == dateI && dateC > 0) {
            
            //剩下几天过期
            choose.days.text = [NSString stringWithFormat:@"还有%ld天过期",dateC];
        }
        if (dateMendIn != dateI) {
            
            if (dateMendIn == 1 || dateMendIn == 3 ||dateMendIn == 5 ||dateMendIn == 7 ||dateMendIn == 8 ||dateMendIn == 10 ||dateMendIn == 12 ) {
                choose.days.text = [NSString stringWithFormat:@"还有%ld天过期",dateMendIn + 31 - dateDi];

            }else if (dateMendIn == 2){
                choose.days.text = [NSString stringWithFormat:@"还有%ld天过期",dateMendIn + 28 - dateDi];

            }
            else{
            
                choose.days.text = [NSString stringWithFormat:@"还有%ld天过期",dateMendIn + 30 - dateDi];
            }
            
        }
        
    }else{
        
        //背景图片
        choose.pic_image.image = [UIImage imageNamed:@"bg_coupon_hui"];
        
        //满 元
        NSInteger allM = [chooseCoupon.full_money integerValue];
        NSString *all_money = [NSString stringWithFormat:@"满%ld元",allM];
        choose.money.text = all_money;
        
        //减 元
        CGFloat reduce = [chooseCoupon.money floatValue];
        NSString *re = [NSString stringWithFormat:@"减%.0f",reduce];
        choose.reduce_money.text = re;
        JWLog(@"re:%@",re);

        //日期 时间戳转时间
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"dd"];
        NSDate *date = [formatter dateFromString:chooseCoupon.end_time];
        
        NSString *dateS =[NSString stringWithFormat:@"%@",date];
        choose.date.text = dateS;
        
        
        //结束时间的 月
        NSDateFormatter *formatterMend = [NSDateFormatter new];
        //        [formatterNow setDateStyle:NSDateFormatterMediumStyle];
        [formatterMend setDateFormat:@"MM"];
        NSDate  *dateMend = [formatterMend dateFromString:chooseCoupon.end_time];
        NSString *dateMendStr = [NSString stringWithFormat:@"%@",dateMend];
        NSInteger dateMendIn = [dateMendStr integerValue];
        
        // 日
        NSDateFormatter *formatterDend = [NSDateFormatter new];
        [formatterDend setDateFormat:@"dd"];
        NSDate *dateDend = [formatterDend dateFromString:chooseCoupon.end_time];
        NSString *dateDendStr = [NSString stringWithFormat:@"%@",dateDend];
        NSInteger dateDendIn = [dateDendStr integerValue];
 
        //所剩天数
        //获取当前的时间 月
        NSDateFormatter *formatterM= [NSDateFormatter new];
        //        [formatterNow setDateStyle:NSDateFormatterMediumStyle];
        [formatterM setDateFormat:@"MM"];
        NSString *dateM = [formatterM stringFromDate:[NSDate date]];
        NSInteger dateI = [dateM integerValue];
        // 日
        NSDateFormatter *formatterD = [NSDateFormatter new];
        [formatterD setDateFormat:@"dd"];
        NSString *dateD = [formatterD stringFromDate:[NSDate date]];
        NSInteger dateDi = [dateD integerValue];
        
        NSInteger dateC = dateDendIn - dateDi;
        if (dateMendIn == dateI && dateC > 0) {
            
            //剩下几天过期
            choose.days.text = [NSString stringWithFormat:@"还有%ld天过期",dateC];
     
        }
        if (dateMendIn != dateI) {
            
            if (dateMendIn == 1 || dateMendIn == 3 ||dateMendIn == 5 ||dateMendIn == 7 ||dateMendIn == 8 ||dateMendIn == 10 ||dateMendIn == 12 ) {
                choose.days.text = [NSString stringWithFormat:@"还有%ld天过期",dateMendIn + 31 - dateDi];
                
            }else if (dateMendIn == 2){
                choose.days.text = [NSString stringWithFormat:@"还有%ld天过期",dateMendIn + 28 - dateDi];
                
            }
            else{
                
                choose.days.text = [NSString stringWithFormat:@"还有%ld天过期",dateMendIn + 30 - dateDi];
            }
            
        }
  
    }
    self.couponCell = choose;
    choose.backgroundColor = [UIColor whiteColor];
    return choose;
}

//点击collectionView的item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //获取选中的item
    _couponCell = (ChosecouponCell *)[collectionView cellForItemAtIndexPath:indexPath];
    JWLog(@"indexpath:%@",indexPath);
    
    self.coupon = _couponArr[indexPath.row];
//     _countt ++;
    
#warning xinjia

    self.path = indexPath;
    
    [collectionView reloadData];
    
    self.passValueBlock(_coupon);
    [self.navigationController popViewControllerAnimated:YES];
    
//   ///////////////////////
//    if (_countt % 2 == 1) {
//        JWLog(@"选中优惠券，打对勾");
//         _couponCell.pic_choose.image = [UIImage imageNamed:@"choose_coupon"];
//        //在打对勾的情况下 把优惠券减少的钱数，传到上一个页面
//        self.passValueBlock(_coupon);
//        [self.navigationController popViewControllerAnimated:YES];
//        JWLog(@"优惠券减少的钱数%@",_couponCell.reduce_money.text);
//        
//
//    }else{
//        JWLog(@"再点击，去掉对勾");
//         _couponCell.pic_choose.image = nil;
//        //不勾选对勾的情况下 优惠券的优惠金钱没有
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

//不点击cell
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Coupon *chooseCoupon = _couponArr[indexPath.row];
    
    if (![chooseCoupon.is_used isEqualToString:@"0"]) {
        
        [self.couponCell endEditing:NO];
        
    }
    _couponCell.pic_choose.image = nil;
    
}

//item 大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(SCREEN_WIDTH, 150);
    
}
//item  左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)
collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}
//上下间距
- (CGFloat)collectionView: (UICollectionView *)collectionView
                   layout: (UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex: (NSInteger)section{
    
    return 0.0;
}

//边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.delegate passValueAboutIndexPath:self.path];
}



@end
