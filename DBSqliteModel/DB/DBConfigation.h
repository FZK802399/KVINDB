//
//  DBConfigation.h
//  DBSqliteModel
//
//  Created by EISOO on 2018/8/14.
//  Copyright © 2018年 eisoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBConfigation : NSObject
// 数据库中常见的几种类型
extern NSString * const SQL_TEXT;
extern NSString * const SQL_INTEGER;
extern NSString * const SQL_REAL;
extern NSString * const SQL_BLOB;
/**
 数据库的路径
 */
@property (nonatomic,retain) NSString *dbPath;

/**
 数据库的名字
 */
@property (nonatomic,retain) NSString *dbName;

/**
 表的名字
 */
@property (nonatomic,retain) NSString *tableName;

@end
