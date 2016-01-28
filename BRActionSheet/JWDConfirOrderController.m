//
//  JWDConfirOrderController.m
//  JueweiEBuy
//
//  Created by 白蕊 on 15/12/11.
//  Copyright © 2015年 书海. All rights reserved.
//
/** 确认订单 */
#define JWDConfirOrderURL @"http://testapi.juewei.com/api/order/confirm"
#define JWDGOOD_ID @"e26f41f2-32bd-ca59-1421-ee713a98143b,951331db-09a2-3855-4bbe-14b3abba60d2,2371ece0-6111-6727-90ac-30d6bcbe1054"
#define JWDGOOD_amount @"9,7,8"

#import "JWDConfirOrderController.h"
#import "InformationCell.h"
#import "PayCell.h"
#import "SendCell.h"
#import "SendCostCell.h"
#import "ShopingCell.h"
#import "JWDNoGoodCell.h"
#import "Coupon.h"
#import "ConfirmOrder.h"
#import "ConfirmUser.h"
#import "JWDCancleOrderController.h"
#import "JWDChooseCouponController.h"
#import "JWDCancleController.h"
#import "AFNetworking.h"
#import "addController.h"
#import "JWDPayController.h"


#import "JWDAddressViewController.h"

@interface JWDConfirOrderController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate,JWDNoGoodCellDelegate,BaiRuiDelegate>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIView *cview;
@property (nonatomic,strong)UIButton *order;

@property (nonatomic,strong)InformationCell *infor;
@property (nonatomic,strong)PayCell *pay;
@property (nonatomic,strong)SendCell *send;
@property (nonatomic,strong)SendCostCell *sendCost;
@property (nonatomic,strong)ShopingCell *soping;
@property (nonatomic,strong)JWDNoGoodCell *noGoodCell;
@property (nonatomic,copy)NSString *amountt;
@property (nonatomic,strong)ConfirmUser *users;
@property (nonatomic,strong)NSString *reduceMoney;//满减优惠
@property (nonatomic,strong)NSString *couponMoney;//优惠券折扣
@property (nonatomic,strong)NSMutableDictionary *moneyDic;//接收优惠的字典
@property (nonatomic,strong)NSMutableDictionary *couponDic;
@property (nonatomic,strong)NSString *iscode;
@property (nonatomic,strong)NSString *cut_coupon;//接收减的优惠券的钱数
@property (nonatomic,strong)NSString *sumPrice;//总价钱
@property (nonatomic,assign)NSInteger counttt;//有货商品的数量
@property (nonatomic,assign)NSInteger saleCount;// 没有货的商品的数量

@property (nonatomic,strong)NSString *beizhuStr;
@property (nonatomic,assign)NSIndexPath *couponIndexpath;//红包的indexpath
//优惠券的属性
@property (nonatomic,strong)Coupon *Bcoupon;
@property (nonatomic,strong)UILabel *moneyLable;
@property (nonatomic, strong) NSMutableArray *ariveTimeArray;
@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSString *content;

@property (nonatomic,assign)NSInteger delegateRow;//记录需要删除的row
@end

@implementation JWDConfirOrderController

//懒加载
- (NSMutableDictionary *)moneyDic{
    
    if (!_moneyDic) {
        
        self.moneyDic = [NSMutableDictionary dictionary];
    }
    return _moneyDic;
}
- (NSMutableDictionary *)couponDic{
    
    if (!_couponDic) {
        
        self.couponDic = [NSMutableDictionary dictionary];
    }
    return _couponDic;
}

- (UIView *)cview{
    
    if (!_cview) {
        
        self.cview = [[UIView alloc] init];
    }
    return _cview;
    
}
- (UILabel *)moneyLable{
    
    if (!_moneyLable) {
        self.moneyLable = [[UILabel alloc] init];
    }
    
    return _moneyLable;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.counttt = 0;
    self.saleCount = 0;
    //请求数据
    [self updataConfirmOrder];
    self.title = @"确认订单";
    //修改navigationbar上字体的颜色和大小
    [self.navigationController.navigationBar setTitleTextAttributes:
  @{NSFontAttributeName:[UIFont systemFontOfSize:20],
NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor colorWithRed:242.0/256 green:242.0/256 blue:242.0/256 alpha:1.0];
    
    //隐藏右边的navigationBar
    self.navigationItem.rightBarButtonItem = nil;
    

    [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
    
}
- (NSMutableArray *)ariveTimeArray{
    if (!_ariveTimeArray) {
        
        self.ariveTimeArray = [NSMutableArray array];
    }
    return _ariveTimeArray;
    
}


////视图将要出现的时候刷新数据
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//
//    [self.tableView reloadData];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [self layoutContent];
//    });
//
//    //布局tableView
//    [self layoutTableView];
//     JWLog(@"dididiidididididididiidi%@",_moneyDic);
//    [self.tableView reloadData];//刷新页面
//    
//}

- (void)initAriveTimeArr
{
    
    NSDate *senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    //获取当前小时
    [dateformatter setDateFormat:@"HH"];
    NSString *timeH = [dateformatter stringFromDate:senddate];
    NSInteger timeHour = [timeH integerValue];
    
    //获取当前分钟
    [dateformatter setDateFormat:@"mm"];
    NSString *timeM = [dateformatter stringFromDate:senddate];
    NSInteger timeMinute = [timeM integerValue];
    
    JWLog(@"start%@",_stary_time);
    
//如果没有店铺没有营业
    if ((timeHour > [_stary_time integerValue])&& timeHour < ([_end_time integerValue] - 1)) {
        NSInteger timeH2 = timeHour + 1;
        
        if (timeMinute > 9) {
            NSString *imTime = [NSString stringWithFormat:@"立即送出%ld:%ld",timeH2,timeMinute];
            self.content = [NSString stringWithFormat:@"立即送出%ld:%ld",timeH2,timeMinute];
            
            [self.ariveTimeArray addObject:imTime];
            
            
        }else{
            NSString *imTime = [NSString stringWithFormat:@"立即送出%ld:0%ld",timeH2,timeMinute];
            
            self.content = [NSString stringWithFormat:@"立即送出%ld:0%ld",timeH2,timeMinute];
            [self.ariveTimeArray addObject:imTime];
        }
        
        for (int i = 0; i < 6; i++) {
            if (i == 0) {
                timeHour  = timeHour+2;
            }else{
                timeHour ++ ;
            }
            NSInteger timeH1 = timeHour + 1;
            
            if (timeHour < 22) {
                NSString *timeStr = [NSString stringWithFormat:@"%ld:00-%ld:00",timeHour,timeH1];
                [self.ariveTimeArray addObject:timeStr];
                
            }else{
                
                [self.ariveTimeArray addObject:@"明天10:00-20:00送达"];
                
                break;
    
        }
     }
    }
    else
    {
        self.content = [NSString stringWithFormat:@"明天10:00-20:00送达"];
        [self.ariveTimeArray addObject:@"明天10:00-20:00送达"];
    }
    
}

//请求数据
- (void)updataConfirmOrder{
    self.confirmOrderArr = [NSMutableArray array];
    self.cartArray = [NSMutableArray array];
    self.userDictionary = [NSMutableDictionary dictionary];
    
    JWLog(@"获取TOKEN%@",TOKEN);
    JWLog(@"USER_ID%@",USERS_ID);
    NSDictionary *dict = @{
                           @"user_id" :USERS_ID,
                           @"goods_id":JWDGOOD_ID,
                           @"goods_num":JWDGOOD_amount,
                           @"token":TOKEN,
                           };
    //请求数据
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
   // mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [mgr POST:JWDConfirOrderURL parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
  
      JWLog(@"%@",responseObject[@"data"]);
        
        if ([responseObject[@"code"] integerValue] == 0){
//#pragma mark - 写入到本地的plist文件
//             [responseObject writeToFile:[NSString stringWithFormat:@"/Users/shirozui/Desktop/ConfireOrder.plist"] atomically:YES];

        self.iscode = responseObject[@"code"];
        
        NSDictionary *dataDic = responseObject[@"data"];
        
        NSArray *cartArr = [dataDic valueForKey:@"cart"];
        self.userDictionary = [dataDic valueForKey:@"user"];
    
            //计算有货的商品的cell 数目，以便于没有获得时候进行cell的删除
            for (NSDictionary *diction in cartArr) {
                
                if ([[diction valueForKey:@"is_buy"] integerValue]== 1) {
                    
                    _counttt ++;
                }else if ([[diction valueForKey:@"is_buy"] integerValue] == 0){
                    
                    _saleCount ++;
                }
            }
            self.amountt = [dataDic valueForKey:@"coupons"];
            self.reduceMoney = [[dataDic valueForKey:@"user"] valueForKey:@"reduce_money"];
            self.sumPrice = [[dataDic valueForKey:@"user"] valueForKey:@"sum_price"];
            
            NSDictionary *dictionary =@{
                                        @"reduceMoney":_reduceMoney
                                        };
            
            self.moneyDic = [NSMutableDictionary dictionaryWithDictionary:dictionary];
            JWLog(@"moneyArray%@",_moneyDic);
            // 接收开始时间和结束时间
            self.stary_time = [dataDic valueForKey:@"start_time"];
            self.end_time = [dataDic valueForKey:@"end_time"];

            JWLog(@"ss%@",_stary_time);
        
            [self initAriveTimeArr];
        for (NSDictionary *dic in cartArr) {
            ConfirmOrder *confirmOrder = [ConfirmOrder new];
            [confirmOrder setValuesForKeysWithDictionary:dic];
            
            //记录cart 里面内容的数组
            [self.confirmOrderArr addObject:confirmOrder];
            
            JWLog(@"arrrrrrr%@",_confirmOrderArr);
            JWLog(@"123123  %@",confirmOrder.name);
        }
            [self layoutContent];

            //布局tableView
            [self layoutTableView];
        [self.tableView reloadData];
   
        }else{
#pragma mark -
            
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    JWLog(@"error : %@",error);
        
    }];
    
}

-(void)layoutTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 114)];
    self.tableView.backgroundColor = [UIColor colorWithRed:242.0/256 green:242.0/256 blue:242.0/256 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    //注册cell 标记
    [self.tableView registerNib:[UINib nibWithNibName:@"InformationCell" bundle:nil] forCellReuseIdentifier:@"information"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PayCell" bundle:nil] forCellReuseIdentifier:@"pay"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SendCell" bundle:nil] forCellReuseIdentifier:@"send"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SendCostCell" bundle:nil] forCellReuseIdentifier:@"sendcost"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShopingCell" bundle:nil] forCellReuseIdentifier:@"shoping"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JWDNoGoodCell" bundle:nil] forCellReuseIdentifier:@"noGood"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];

}

//布局确认订单
- (void)layoutContent{
    self.cview = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 114, SCREEN_WIDTH, 50)];
    _cview.backgroundColor = [UIColor whiteColor];
    self.order = [UIButton buttonWithType:UIButtonTypeCustom];
    _order.frame = CGRectMake(SCREEN_WIDTH - 100, 0, 100, 50);
    _order.backgroundColor = [UIColor redColor];
    [_order setTitle:@"确认订单" forState:(UIControlStateNormal)];
    _order.titleLabel.textColor = [UIColor whiteColor];
    _order.titleLabel.textAlignment = 1;
    
    //添加事件
    [self.order addTarget:self action:@selector(order:) forControlEvents:(UIControlEventTouchUpInside)];
    [_cview addSubview:_order];
    //总共的钱数
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 50)];
    NSInteger sumprice = ([_sumPrice integerValue] - [[_couponDic valueForKey:@"couponMoney"] integerValue]);
    
    //优惠的钱数
    NSInteger price = ([_reduceMoney integerValue] + [[_couponDic valueForKey:@"couponMoney"] integerValue]);
    NSDictionary *dict = @{
                          NSForegroundColorAttributeName : [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0],
                          NSFontAttributeName :Font(16)
                          };
    //设置不同字段的颜色
    lable.text = [NSString stringWithFormat:@"共￥%ld (已优惠%ld)",(long)sumprice,(long)price];
    //新建带样式的文字
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:lable.text attributes:dict];
    //查找的范围
    NSRange range1 = [[attrStr string] rangeOfString:[NSString stringWithFormat:@"￥%ld",(long)sumprice]];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:249.0/255 green:0 blue:0 alpha:1.0] range:range1];
    // 设置不同字段的大小
    NSRange range2 = [[attrStr string] rangeOfString:[NSString stringWithFormat:@"(已优惠%ld)",(long)price]];
    [attrStr addAttribute:NSFontAttributeName value:Font(12) range:range2];
    [lable setAttributedText:attrStr];
    
    JWLog(@"优惠券：%ld",[[_couponDic valueForKey:@"couponMoney"] integerValue]);
    JWLog(@"总价钱：%ld",(long)sumprice);
    JWLog(@"数据总钱:%@",_sumPrice);

    lable.textAlignment = 0;
   
    _moneyLable = lable;
    [_cview addSubview:lable];

    [self.view addSubview:_cview];
 
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1 :
            return 1;
            break;
        case 2 :
            return 3;
            break;
        case 3 :
            return 1;
            break;
        case 4 :
            return _confirmOrderArr.count;
            break;
        case 5:
            return 1;
            break;
         case 6:
            return _moneyDic.count;
            break;
        default:
            break;
    }
    return _couponDic.count ;
}

//设置cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //用户消息
    if (indexPath.section == 0) {
        InformationCell *infor =  [tableView dequeueReusableCellWithIdentifier:@"information" forIndexPath:indexPath];
        self.infor = infor;
        // 赋值
        infor.name.text = [_userDictionary valueForKey:@"address_user_name"];
        infor.phoneNumber.text = [_userDictionary valueForKey:@"phone"];
        infor.address.text = [_userDictionary valueForKey:@"map_addr"];
        //描边
        infor.layer.borderWidth = 0.9;
        infor.layer.borderColor = HEXCOLOR(0XCCCCCC).CGColor;

        return _infor;
    }else if (indexPath.section == 1){
        self.pay =  [tableView dequeueReusableCellWithIdentifier:@"pay" forIndexPath:indexPath];
        //支付方式
        _pay.layer.borderWidth = 0.9;
        _pay.selectionStyle = UITableViewCellSelectionStyleNone;
        _pay.layer.borderColor = HEXCOLOR(0XCCCCCC).CGColor;
        
        return _pay;
    }else if (indexPath.section == 2){
        self.send =  [tableView dequeueReusableCellWithIdentifier:@"send" forIndexPath:indexPath];
        
        //cell的边框
        if (indexPath.row == 0) {
            _send.remark.text = @"送达时间";
                    _send.layer.borderWidth = 0.9;
                    _send.layer.borderColor = HEXCOLOR(0XCCCCCC).CGColor;
            
             _send.require.text = self.content;
            
        }else if (indexPath.row == 1){
            _send.remark.text = @"备注";
            _send.require.text = _beizhuStr;

            
        }else if (indexPath.row == 2){
            _send.layer.borderWidth = 0.9;
            _send.layer.borderColor = HEXCOLOR(0XCCCCCC).CGColor;

            _send.remark.text = @"优惠券";
            
            if (_amountt.length == 0) {
                
                _send.require.text = @"无可用优惠券";
               
            }
            else{
                
                if (_cut_coupon.length == 0) {
                    NSString *str = [NSString stringWithFormat:@"%@张可用",_amountt];
                    JWLog(@"%@",_amountt);
                    _send.require.text = str;
                    
                }else{
                    
                    _send.require.text = [NSString stringWithFormat:@"%@元优惠券",_cut_coupon];
                }
                
            _send.require.textColor = [UIColor colorWithRed:249.0/256 green:0 blue:0 alpha:1.0];
    
            }
        }
    return _send;
    }else if (indexPath.section == 3){
        // 购物车
        self.soping =  [tableView dequeueReusableCellWithIdentifier:@"shoping" forIndexPath:indexPath];
        _soping.layer.borderWidth = 0.9;
        _soping.layer.borderColor = HEXCOLOR(0xccccccc).CGColor;
        _soping.good.text = @"购物车";
        _soping.taste.text = nil;
        _soping.amount.text  = nil;
        _soping.money.text = nil;
        _soping.symble.text = nil;
        _soping.redu.text = nil;
       //不可点击
        _soping.selectionStyle = UITableViewCellSelectionStyleNone;
        return _soping;

    }else if (indexPath.section == 4){
        //购物车中的商品
        ConfirmOrder *confirm = _confirmOrderArr[indexPath.row];
        
        //有货的情况下
        if ([confirm.is_buy integerValue] == 1) {
             self.soping =  [tableView dequeueReusableCellWithIdentifier:@"shoping" forIndexPath:indexPath];
            _soping.money.text = confirm.price;
            
            _soping.backgroundColor = [UIColor whiteColor];
            NSString *string = [NSString stringWithFormat:@"X%@",confirm.num];
            NSString *taste = [NSString stringWithFormat:@"(%@)",confirm.taste_name];
            _soping.good.text = confirm.name;
            _soping.amount.text  = string;
            _soping.taste.text = taste;
            _soping.redu.text = nil;

            _soping.selectionStyle = UITableViewCellSelectionStyleNone;
             return _soping;
  
        }else{
        //没有商品的情况下
            self.noGoodCell = [tableView dequeueReusableCellWithIdentifier:@"noGood" forIndexPath:indexPath];
            _noGoodCell.delegateGood.text = confirm.name;
            NSString *taste = [NSString stringWithFormat:@"(%@)",confirm.taste_name];
             NSString *string = [NSString stringWithFormat:@"X%@",confirm.num];
            //背景颜色
            _noGoodCell.backgroundColor = [UIColor colorWithRed:202.0/255 green:202.0/255 blue:202.0/255 alpha:1.0];
            _noGoodCell.delegateTaste.text = taste;
            _noGoodCell.delegateNum.text = string;
            _noGoodCell.delegate = self;
            _noGoodCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return _noGoodCell;
        }
        }else if(indexPath.section == 5){
       
            //配送费
            self.sendCost =  [tableView dequeueReusableCellWithIdentifier:@"sendcost" forIndexPath:indexPath];
            
            NSString *freight = [NSString stringWithFormat:@"￥%@",[_userDictionary valueForKey:@"freight"]];
            _sendCost.pay_money.text = freight;
            _sendCost.pay_send.text = [_userDictionary valueForKey:@"dis_service"];
                    _sendCost.layer.borderWidth = 0.9;
                    _sendCost.layer.borderColor = HEXCOLOR(0XCCCCCC).CGColor;
            _sendCost.selectionStyle = UITableViewCellSelectionStyleNone;
                    return _sendCost;
            
        }else if(indexPath.section == 6){
            
            JWLog(@"%@",_reduceMoney);
            //显示满减优惠 和优惠券折扣
             self.soping =  [tableView dequeueReusableCellWithIdentifier:@"shoping" forIndexPath:indexPath];

            JWLog(@"为什么总是调试不出来%@",_moneyDic);
            
            if ([_reduceMoney integerValue] > 0) {
                
                                    _soping.good.text = @"满减优惠";
                                    _soping.money.text = _reduceMoney;
                                    
                                }
   
            _soping.taste.text = nil;
            _soping.amount.text  = nil;
            _soping.money.textColor = [UIColor colorWithRed:249.0/256 green:0 blue:0 alpha:1.0];
            _soping.layer.borderWidth = 0.9;
            _soping.layer.borderColor = HEXCOLOR(0xccccccc).CGColor;
            _soping.good.textColor = [UIColor colorWithRed:249.0/256 green:0 blue:0 alpha:1.0];
            _soping.selectionStyle = UITableViewCellSelectionStyleNone;
            return _soping;
            
        }else if (indexPath.section == 7){
            
              self.soping =  [tableView dequeueReusableCellWithIdentifier:@"shoping" forIndexPath:indexPath];
            
            _soping.good.text = @"优惠券折扣";
            
           _soping.money.text = [_couponDic valueForKey:@"couponMoney"];
            _soping.taste.text = nil;
            _soping.amount.text  = nil;
            _soping.money.textColor = [UIColor colorWithRed:249.0/256 green:0 blue:0 alpha:1.0];
            // 描边
            _soping.layer.borderWidth = 0.9;
            _soping.layer.borderColor = HEXCOLOR(0xccccccc).CGColor;
            _soping.good.textColor = [UIColor colorWithRed:249.0/256 green:0 blue:0 alpha:1.0];
            _soping.selectionStyle = UITableViewCellSelectionStyleNone;
            return _soping;
    
        }
    return nil;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     addController *addc = [[addController alloc] init];
    
    //添加备注
    if (indexPath.section == 2 && indexPath.row == 1) {
  
        _send = [tableView cellForRowAtIndexPath:indexPath];
        //给block变量赋  接收后一个页面传过来的添加备注的值
        addc.passvalueBlock = ^(NSString *text){
            
            _send.require.text = text;
            
            self.beizhuStr = text;
            JWLog(@"lala jdihb%@",_send.require.text);
  
        };
       
        [self.navigationController pushViewController:addc animated:YES];
        
    }
    // 选择送达时间
    if (indexPath.section == 2 && indexPath.row == 0) {
        
        [self chooseArriveTime];
    }if (indexPath.section == 2 && indexPath.row == 2) {
        
        //跳转到选择优惠券那个页面
        JWDChooseCouponController *choseCoupon = [JWDChooseCouponController new];
        choseCoupon.pay_money = _sumPrice;
        JWLog(@"需要支付的钱数，判断可用优惠券的数目%@",choseCoupon.pay_money);
        _send = [tableView cellForRowAtIndexPath:indexPath];
        choseCoupon.passValueBlock = ^(Coupon *coupon){
            
            self.Bcoupon = coupon;
            self.cut_coupon = coupon.money;
            _send.require.text = coupon.money;//赋值选择优惠券的折扣

            self.couponMoney = coupon.money;
            [self.couponDic setValue:coupon.money forKey:@"couponMoney"];
            JWLog(@"iiiiiiiiiiiii%@",_send.require.text);
           
//            self.cut_coupon = text;
//            _send.require.text = text;//赋值选择优惠券的折扣
//            
//            JWLog(@"能不能显示出来就看你啦%@",text);
//            self.couponMoney = text;//赋值优惠券折扣
//            
//            [self.couponDic setValue:text forKey:@"couponMoney"];
//            JWLog(@" ajajjajjajja %@",self.couponMoney);
//            JWLog(@"iiiiiiiiiiiii%@",_send.require.text);
            
        };


        choseCoupon.coupon = _Bcoupon;
        choseCoupon.delegate = self;
        choseCoupon.path = self.couponIndexpath;
        
        [self.navigationController pushViewController:choseCoupon animated:YES];
    }
    
}
//实现协议中的方法  删除一行cell
- (void)tableViewCell:(UITableViewCell *)cell delegateCell:(UIButton *)button{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    JWLog(@"counttttt%ld",(long)_counttt);
    JWLog(@"%@",indexPath);
    //     通过获取的索引值删除数组中的值
    [self.confirmOrderArr removeObjectAtIndex:_delegateRow + _counttt];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];

    _saleCount -- ;
    [self.tableView reloadData];
    JWLog(@"删除啦删除啦");
    
}
#pragma mark UIPickerView  选择送达时间
- (void)chooseArriveTime
{
    self.blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.blackView.backgroundColor = [UIColor blackColor];
    self.blackView.alpha = 0.5;
    [self.view addSubview:self.blackView];
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(70, 150, [UIScreen mainScreen].bounds.size.width - 140, 250)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.alpha = 1;
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.view addSubview:self.pickerView];
    
}
//列数
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark 哪一列的行数
// returns the # of rows in each component.. 返回那一列的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.ariveTimeArray.count;
}

#pragma mark pickerView的选中
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (self.ariveTimeArray.count) {
        self.content = [self.ariveTimeArray objectAtIndex:row];
        self.pickerView.hidden = YES;
        self.blackView.hidden = YES;
        [self.tableView reloadData];
    }
    
}

#pragma mark - UIPickView 代理
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.ariveTimeArray[row];
}

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 75;
            break;
        case 5 :
            return 60;
            break;
                default:
            break;
    }
    return 50;
    
}

// footer的背景颜色
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [UIColor clearColor];
    
}

// footer高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0 || section == 1 || section == 2) {
        return 10;
         }
    else if (section == 4 ){
        
        if (_saleCount != 0) {
            return 32;
        }
        return 10;
    }

    return 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//确认订单
- (void)order:(UIButton *)roderbt{
    
//    JWDPayController *payVc = [[JWDPayController alloc] init];
//    
//    JWLog(@"%@",_iscode);
//    
//        [self.navigationController pushViewController:payVc animated:YES];

    JWDCancleOrderController *can = [JWDCancleOrderController new];
    [self.navigationController pushViewController:can animated:YES];
    
//        JWDCancleController *can = [JWDCancleController new];
//        [self.navigationController pushViewController:can animated:YES];
    

    
}

//／／／／／／／／／／／／／／／／／／／
- (void)passValueAboutIndexPath:(NSIndexPath *)indexPath{
    
    
    self.couponIndexpath = indexPath;
}

//删除
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        //        获取选中删除行索引值
        NSInteger row = [indexPath row];
        self.delegateRow = row;
        //        通过获取的索引值删除数组中的值
        [self.confirmOrderArr removeObjectAtIndex:row];
        //        删除单元格的某一行时，在用动画效果实现删除过程
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }  
}

#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    JWLog(@"section  %ld",(long)section);
    while (section == 4 && _saleCount != 0) {
        UIView *saleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
        saleView.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0];
        UIImageView *pic_image =[[ UIImageView alloc] initWithFrame:CGRectMake(10, 10, 12, 12)];
        pic_image.image = [UIImage imageNamed:@"tishi"];
        [saleView addSubview:pic_image];
        
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, 100, 32)];
        lable.textColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0];
        lable.text = @"商品已售完";
        
        lable.font = Font(12);
        [saleView addSubview:lable];
        return saleView;
    }
    return nil;
}

@end
