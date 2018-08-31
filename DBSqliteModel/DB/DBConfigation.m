//
//  DBConfigation.m
//  DBSqliteModel
//
//  Created by EISOO on 2018/8/14.
//  Copyright © 2018年 eisoo. All rights reserved.
//

#import "DBConfigation.h"
// 数据库中常见的几种类型
NSString * const SQL_TEXT = @"TEXT";//文本
NSString * const SQL_INTEGER = @"INTEGER";//int long integer ...
NSString * const SQL_REAL = @"REAL";//浮点
NSString * const SQL_BLOB = @"BLOB";//data

@implementation DBConfigation

-(instancetype)init{
    if (self = [super init]) {
        //默认的数据库名称
        self.dbName = @"KVINDB.sqlite";
        //默认的数据库路径
        self.dbPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        //默认表的名字
        self.tableName = @"KVINTable";
        
    }
    return self;
}

@end
