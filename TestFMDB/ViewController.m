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
@property (nonatomic, strong) FMDatabase *fmdb;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *randData;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *path = [[NSBundle mainBundle]pathForResource:@"data" ofType:@"plist"];
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
//    NSLog(@"%@",dic);
    [self creatDatabase];
    [self inquiryData:self.fmdb];
    
//    [self creatTable:self.fmdb];
//    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [self addData:self.fmdb andTitle:key content:obj];
//    }];

}

- (void)randArray{
   
    NSMutableArray *array = self.data;
    NSMutableArray *randomArray = [[NSMutableArray alloc] init];
    while ([randomArray count] < 35) {
        int r = arc4random() % [array count];
        [randomArray addObject:[array objectAtIndex:r]];
        [array removeObject:[array objectAtIndex:r]];
        
    }
    self.randData = randomArray;
}

- (IBAction)clickBtn:(id)sender {
    [self randNum];

   
    
    
}

- (void)randNum{
    static int x = 0;
    
    if (x == 35) {
        NSLog(@"做完题了");
        return;
    }
    NSDictionary *dic = self.randData[x];
    self.titleLbl.text = [NSString stringWithFormat:@"题目%d: %@",x+1,dic[@"title"]];
    self.contentView.text = dic[@"content"];
    ++x;
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

- (void)creatTable:(FMDatabase *)fmdb{
    BOOL executeUpdate = [fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS question(id integer PRIMARY KEY AUTOINCREMENT,title text NOT NULL,content text NOT NULL, level integer NOT NULL DEFAULT '0' );"];
    if (executeUpdate){
        NSLog(@"创建表成功");
    }else{
        NSLog(@"创建表失败");
    }
}

- (void)addData:(FMDatabase *)fmdb andTitle:(NSString *)title content:(NSString *)content{
    BOOL result = [fmdb executeUpdate:@"INSERT INTO question(title,content) VALUES(?,?)",title,content];
    if (result) {
        NSLog(@"插入成功");
    }else{
        NSLog(@"插入失败");
    }
}


- (void)inquiryData:(FMDatabase *)fmdb{
    FMResultSet *resultSet = [fmdb executeQuery:@"select * from question"];
    while ([resultSet next]) {
        NSString *title = [resultSet objectForColumn:@"title"];
        NSString *content = [resultSet objectForColumn:@"content"];
        [self.data addObject:@{@"title":title,
                               @"content":content}];
    }
    [self.fmdb close];
    [self randArray];
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

@end
