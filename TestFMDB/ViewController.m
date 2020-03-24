//
//  ViewController.m
//  TestFMDB
//
//  Created by QPP on 2020/2/21.
//  Copyright © 2020年 QPP. All rights reserved.
//

#import "ViewController.h"
#import "FMDatabase.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UITextView *contentView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, strong) FMDatabase *fmdb;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *randData;
@property (nonatomic, assign) NSInteger num;//题号
@property (nonatomic, strong) CALayer *layer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dataInit];
    
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:248.0/255.0 blue:252.0/255.0 alpha:1];
    self.contentView.layer.cornerRadius = 6.0;
    self.contentView.alpha = 0;
    self.layer.hidden = true;
    
}



- (void)dataInit{
    [self creatDatabase];
    if (![self inquiryData:self.fmdb]) {
        NSLog(@"创建表");
        if ([self creatTable:self.fmdb]) {
            NSLog(@"插入数据");
            NSString *path = [[NSBundle mainBundle]pathForResource:@"data" ofType:@"plist"];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [self addData:self.fmdb andTitle:key content:obj];
            }];
            [self inquiryData:self.fmdb];
        }
    }else{
        [self showItem];
    }
}



- (void)randArray{
    NSMutableArray *array = [self.data mutableCopy];
    NSMutableArray *randomArray = [[NSMutableArray alloc] init];
    while ([randomArray count] < self.data.count) {
        int r = arc4random() % [array count];
        [randomArray addObject:[array objectAtIndex:r]];
        [array removeObject:[array objectAtIndex:r]];
        
    }
    self.randData = randomArray;
}

- (IBAction)clickForword:(id)sender {
    if (self.num-1<0) {
        NSLog(@"已是第一题");
        return;
    }
    --self.num;
    [self showItem];
    self.contentView.alpha = 0;
}


- (IBAction)clickNext:(id)sender {
    if (self.num+1 == self.randData.count) {
        NSLog(@"最后一题");
        return;
    }
    ++self.num;
    [self showItem];
    self.contentView.alpha = 0;

}

- (IBAction)clickAnswer:(id)sender {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.contentView.alpha = 1;
        self.layer.hidden = false;
        self.layer.frame = self.contentView.frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)moveSlider:(UISlider *)sender {
    if (self.num != (int)sender.value) {
        self.num = (int)sender.value;
        [self showItem];
        self.contentView.alpha = 0;
    }
}



- (void)showItem{
    self.layer.hidden = true;
    NSDictionary *dic = self.randData[self.num];
    self.titleLbl.text = [NSString stringWithFormat:@"题目%ld: %@",self.num+1,dic[@"title"]];
    self.contentView.text = dic[@"content"];
}


- (void)creatDatabase{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];//获取沙盒地址
    NSString *fileName = [docPath stringByAppendingPathComponent:@"test.db"];//设置数据库名称
    NSLog(@"%@",docPath);
    FMDatabase *fmdb = [FMDatabase databaseWithPath:fileName];//创建并获取数据库信息
    if ([fmdb open]) {
        NSLog(@"数据库打开成功");
    }else{
        NSLog(@"数据库打开失败");
    }
    self.fmdb = fmdb;
}

- (BOOL)creatTable:(FMDatabase *)fmdb{
    BOOL executeUpdate = [fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS question(id integer PRIMARY KEY AUTOINCREMENT,title text NOT NULL,content text NOT NULL, level integer NOT NULL DEFAULT '0' );"];
    if (executeUpdate){
        NSLog(@"创建表成功");
    }else{
        NSLog(@"创建表失败");
    }
    return executeUpdate;
}

- (void)addData:(FMDatabase *)fmdb andTitle:(NSString *)title content:(NSString *)content{
    BOOL result = [fmdb executeUpdate:@"INSERT INTO question(title,content) VALUES(?,?)",title,content];
    if (result) {
        NSLog(@"插入成功");
    }else{
        NSLog(@"插入失败");
    }
}


- (BOOL)inquiryData:(FMDatabase *)fmdb{
    FMResultSet *resultSet = [fmdb executeQuery:@"select * from question"];
    while ([resultSet next]) {
        NSString *title = [resultSet objectForColumn:@"title"];
        NSString *content = [resultSet objectForColumn:@"content"];
        [self.data addObject:@{@"title":title,
                               @"content":content}];
    }
    if (self.data.count>0) {
        [self.fmdb close];
        [self randArray];
        [self showItem];
        NSLog(@"打乱数组");
        self.slider.maximumValue = self.randData.count-1;
        self.slider.minimumValue = 0;
        return true;
    }else{
        NSLog(@"查询数据失败");
        return false;
    }
}

//删除表
- (void)deleteTable:(FMDatabase *)fmdb{
    BOOL result = [fmdb executeUpdate:@"drop table if exists question"];
    if (result) {
        NSLog(@"删除表成功");
    }else{
        NSLog(@"删除表失败");
    }
}


- (NSMutableArray *)data{
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

- (NSMutableArray *)randData{
    if (!_randData) {
        _randData = [NSMutableArray array];
    }
    return _randData;
}

- (CALayer *)layer{
    if (!_layer) {
        _layer = [CALayer layer];
        _layer.frame = self.contentView.frame;
        _layer.cornerRadius = 6.0;
        _layer.backgroundColor = [UIColor whiteColor].CGColor;
        _layer.shadowColor = [UIColor grayColor].CGColor;
        _layer.shadowOffset = CGSizeMake(10,10);
        _layer.shadowRadius = 5.0;
        _layer.shadowOpacity = 1.0;
        [self.view.layer insertSublayer:_layer below:self.contentView.layer];
    }
    return _layer;
}


- (float)getTotalPrice:(NSString *)type price:(float)price{
    if ([type  isEqual: @"9折"]) {
        return price*0.9;
    }else if ([type  isEqual: @"8折"]) {
        return price*0.8;
    }else if ([type  isEqual: @"300-50"]) {
        return price-30;
    }
    return price;
}



@end


@interface Dicounnt : NSObject
- (float)discount:(float)price;
@end
@implementation Dicounnt
- (float)discount:(float)price{
    return 0;
}
@end

@interface discountNight : Dicounnt
@end
@implementation discountNight
- (float)discount:(float)price{
    return price*0.9;
}
@end

@interface discountSeven : Dicounnt
@end
@implementation discountSeven
- (float)discount:(float)price{
    return price*0.7;
}
@end

@interface discountCutThirty : Dicounnt
@end
@implementation discountCutThirty
- (float)discount:(float)price{
    return price-30;
}
@end


@interface Price : NSObject
@property (nonatomic, strong) Dicounnt *type;
- (float)getTotalPrice:(float)price;
@end

@implementation Price
- (float)getTotalPrice:(float)price{
    return [self.type discount:price];
}

@end





