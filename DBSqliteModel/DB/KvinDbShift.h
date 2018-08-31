//
//  KvinDbShift.h
//  DBSqliteModel
//
//  Created by EISOO on 2018/8/14.
//  Copyright © 2018年 eisoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBConfigation.h"
@interface KvinDbShift : NSObject


/**
 DBConfigation(数据库的配置文件)
 @return 单例对象
 */
+(instancetype)shareInstance;
+(instancetype)shareInstance:(DBConfigation*)configation;

/**
 创建对象
 @param configation 数据库的配置文件
 @return 非单例对象
 */
-(instancetype)initWithDBConfigation:(DBConfigation*)configation;

/**
 创建表
 @param params 可以为字典{@"name":@"xiaoli"}或对象Model根据runtime去获取里面的属性
 @return 是否创建成功
 */
-(BOOL)createTableWithParams:(id)params;

/**
 同上
 @param params 同上
 @param nameArr 区别 创建表不包括的字段例如[@"age"]则不创建此字段
 @return 同上
 */
-(BOOL)createTableWithParams:(id)params excludeName:(NSArray*)nameArr;

/**
 向表里面插入数据
 
 @param parameters 要插入的数据可以是对象和DIC
 @return 是否插入成功
 */
-(BOOL)insertDicOrModel:(id)parameters;

/**
 删除满足条件表的数据

 @param format 条件语句SQL语句
 @return 是否删除成功
 */
-(BOOL)deleteWhereFormat:(NSString *)format,...;

/**
 根据条件去更新表里面的数据

 @param parameters 要更改的数据 可以为model 也可以为dic
 @param format 条件语句, 如:@"where ID = '123'"
 @return 更改是否成功
 */
-(BOOL)updateDicOrModel:(id)parameters whereFormat:(NSString *)format, ...;

/**
 根据条件查找表中的数据

 @param parameters 每条查找结果放入model(可以是[Person class] or @"Person" or Person实例)或dictionary中
 @param format 条件语句, 如:@"where name = '小李'",
 @return 将结果存入array,数组中的元素的类型为parameters的类型
 */
-(NSArray *)lookupDicOrModel:(id)parameters whereFormat:(NSString *)format, ...;

/**
 批量插入或者更改

 @param dicOrModelArray 要insert/update数据的数组,也可以将model和dictionary混合装入array
 @return 返回的数组存储未插入成功的下标,数组中元素类型为NSNumber
 */
-(NSArray *)insertTableDicOrModelArray:(NSArray *)dicOrModelArray;

/**
 删除数据库里面的表
 @return 是否删除成功
 */
-(BOOL)deleteTable;

/**
 删除数据表里面的所有数据
 @return 是否删除成功
 */
-(BOOL)deleteAllDataFormTable;


// `是否存在表
- (BOOL)isExistTable;

// `表中共有多少条数据
- (int)tableItemCount;

// `返回表中的字段名
- (NSArray *)columnNameArray;

// `关闭数据库
- (void)close;
// `打开数据库 (每次shareDatabase系列操作时已经open,当调用close后若进行db操作需重新open或调用shareDatabase)
- (void)open;

/**
 (主键id,自动创建) 返回最后插入的primary key id

 @return 返回最后插入的primary key id
 */
- (NSInteger)lastInsertPrimaryKeyId;
@end
