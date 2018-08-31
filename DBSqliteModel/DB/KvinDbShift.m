//
//  KvinDbShift.m
//  DBSqliteModel
//
//  Created by EISOO on 2018/8/14.
//  Copyright © 2018年 eisoo. All rights reserved.
//

#import "KvinDbShift.h"
#import "FMDB.h"
#import <objc/runtime.h>
@interface KvinDbShift()

/**
 数据库路径
 */
@property (nonatomic, strong)NSString *dbPath;

/**
 FMDatabaseQueue保证线程安全
 */
@property (nonatomic, strong)FMDatabaseQueue *dbQueue;

/**
 数据库
 */
@property (nonatomic, strong)FMDatabase *db;

/**
 数据库表的名字
 */
@property (nonatomic ,strong) NSString * tableName;


@end

@implementation KvinDbShift
static  KvinDbShift *shiftDb = nil;

+ (instancetype)shareInstance{
    return [self shareInstance:nil];
}

+ (instancetype)shareInstance:(DBConfigation *)configation{
    if (!shiftDb) {
        NSString * path;
        NSString * dbName;
        if (!configation) {
            configation = [[DBConfigation alloc]init];
        }
        dbName = configation.dbName;
        path = [configation.dbPath stringByAppendingPathComponent:dbName];
        FMDatabase * fmdb = [FMDatabase databaseWithPath:path];
        if ([fmdb open]) {
            shiftDb = KvinDbShift.new;
            shiftDb.db = fmdb;
            shiftDb.dbPath = path;
            shiftDb.tableName = configation.tableName;
        }
    }
    if (![shiftDb.db open]) {
        NSLog(@"database can not open !");
        return nil;
    }
    return shiftDb;
}
-(instancetype)initWithDBConfigation:(DBConfigation *)configation{
    NSString * path;
    NSString * dbName;
    if (!configation) {
        configation = [[DBConfigation alloc]init];
    }
    dbName = configation.dbName;
    path = [configation.dbPath stringByAppendingPathComponent:dbName];
    FMDatabase * fmdb = [FMDatabase databaseWithPath:path];
    if ([fmdb open]) {
        self = [super init];
        if (self) {
            self.db = fmdb;
            self.dbPath = path;
            self.tableName = configation.tableName;
        }
    }
    if (![fmdb open]) {
        NSLog(@"database can not open !");
        return nil;
    }
    return nil;
}
-(BOOL)createTableWithParams:(id)params
{
    return [self createTableWithParams:params excludeName:nil];
}
-(BOOL)createTableWithParams:(id)params excludeName:(NSArray *)nameArr{
    NSDictionary * dic;
    if ([params isKindOfClass:[NSDictionary class]]) {
        dic = [self dicValueTypeConvert:params];
    }else{
        Class CLS;
        if ([params isKindOfClass:[NSString class]]) {
            CLS =NSClassFromString(params);
        }else if ([params isKindOfClass:[NSObject class]]){
            CLS = [params class];
        }else{
            CLS = params;
        }
        dic = [self modelToDictionary:CLS excludePropertyName:nameArr];
    }
    NSMutableDictionary * muDIC = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSString *key in dic) {
        [muDIC setObject:dic[key] forKey:key];
    }
    [muDIC removeObjectForKey:@"pkid"];
    NSMutableString * fieldStr = [[NSMutableString alloc]initWithFormat:@"CREATE TABLE %@ (pkid INTEGER PRIMARY KEY,",_tableName];
    int keyCount = 0;
    for (NSString * key in muDIC) {
        keyCount++;
        if (nameArr && [nameArr containsObject:key]) {
            continue;
        }
        if (keyCount == muDIC.count) {
            [fieldStr appendFormat:@" %@ %@)",key,dic[key]];
            break;
        }
        [fieldStr appendFormat:@" %@ %@,",key,dic[key]];
    }
    BOOL creatFLag;
    creatFLag = [_db executeUpdate:fieldStr];
    return creatFLag;
}


#pragma mark runtime
-(NSDictionary *)modelToDictionary:(Class)cls excludePropertyName:(NSArray *)nameArr{
    NSMutableDictionary * mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    for (int i = 0 ; i<outCount; i++) {
        NSString * name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if ([nameArr containsObject:nameArr]) continue;
        //@note The format of the attribute string is described in Declared Properties in Objective-C Runtime Programming Guide
        NSString * type = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
        id value = [self propertTypeConvert:type];
        if (value) {
            [mDic setObject:value forKey:name];
        }
    }
    free(properties);
    return mDic;
}
//获取model的key和value
-(NSDictionary *)getModelKeyAndValue:(id)model clomnArr:(NSArray *)clomnArr{
    NSMutableDictionary * mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t * properties = class_copyPropertyList([model class], &outCount);
    for (int i =0 ; i<outCount; i++) {
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if (![clomnArr containsObject:name]) {
            continue;
        }
        
        id value = [model valueForKey:name];
        if (value) {
            [mDic setObject:value forKey:name];
        }
    }
    free(properties);
    
    return mDic;
}
-(NSDictionary *)dicValueTypeConvert:(NSDictionary *)params{
    NSMutableDictionary * mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSString * key in params.allKeys) {
        id value = params[key];
        if ([value isKindOfClass:[NSString class]]) {
            [mDic setObject:SQL_TEXT forKey:key];
        }else if ([value isKindOfClass:[NSData class]]){
            [mDic setObject:SQL_BLOB forKey:key];
        }else{
            [mDic setObject:SQL_INTEGER forKey:key];
        }
    }
    return mDic;
}
- (NSString *)propertTypeConvert:(NSString *)typeStr
{
    NSString *resultStr = nil;
    if ([typeStr hasPrefix:@"T@\"NSString\""]) {
        resultStr = SQL_TEXT;
    } else if ([typeStr hasPrefix:@"T@\"NSData\""]) {
        resultStr = SQL_BLOB;
    } else if ([typeStr hasPrefix:@"Ti"]||[typeStr hasPrefix:@"TI"]||[typeStr hasPrefix:@"Ts"]||[typeStr hasPrefix:@"TS"]||[typeStr hasPrefix:@"T@\"NSNumber\""]||[typeStr hasPrefix:@"TB"]||[typeStr hasPrefix:@"Tq"]||[typeStr hasPrefix:@"TQ"]) {
        resultStr = SQL_INTEGER;
    } else if ([typeStr hasPrefix:@"Tf"] || [typeStr hasPrefix:@"Td"]){
        resultStr= SQL_REAL;
    }
    
    return resultStr;
}
//得到表里字段的名称
-(NSArray *)getTableColumn:(NSString *)tableName andDB:(FMDatabase *)db{
    NSMutableArray * mArr = [NSMutableArray arrayWithCapacity:0];
    FMResultSet * resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        [mArr addObject:[resultSet stringForColumn:@"name"]];
    }
    return mArr;
    
}

#pragma mark 增删改查

-(BOOL)insertDicOrModel:(id)parameters{
    NSArray * columnArr = [self getTableColumn:_tableName andDB:_db];
    return [self insertDicOrModel:parameters columnArr:columnArr];
}
-(BOOL)insertDicOrModel:(id)parameters columnArr:(NSArray*)columnArr{
    BOOL flag;
    NSDictionary *dic;
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else{
        dic = [self getModelKeyAndValue:parameters clomnArr:columnArr];
    }
    NSMutableString *finalStr = [[NSMutableString alloc]initWithFormat:@"INSERT INTO %@ (",_tableName];
    NSMutableString * tempStr = [NSMutableString stringWithCapacity:0];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    for (NSString * key in dic) {
        if (![columnArr containsObject:key]||[key isEqualToString:@"pkid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@,",key];
        [tempStr appendString:@"?,"];
        [argumentsArr addObject:dic[key]];
    }
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (tempStr.length)
        [tempStr deleteCharactersInRange:NSMakeRange(tempStr.length-1, 1)];
    [finalStr appendFormat:@") values (%@)", tempStr];
    flag = [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    return flag;
}


-(BOOL)deleteWhereFormat:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    NSString * where = format ?[[NSString alloc]initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    BOOL flag;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"delete from %@  %@", _tableName,where];
    flag = [_db executeUpdate:finalStr];
    return flag;
}
-(BOOL)updateDicOrModel:(id)parameters whereFormat:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    NSString * where  = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    BOOL flag;
    NSDictionary *dic;
    NSArray * clomnArr = [self getTableColumn:_tableName andDB:_db];
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else{
        dic = [self getModelKeyAndValue:parameters clomnArr:clomnArr];
    }
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"update %@ set ", _tableName];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    for (NSString *key in dic) {
        
        if (![clomnArr containsObject:key] || [key isEqualToString:@"pkid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@ = %@,", key, @"?"];
        [argumentsArr addObject:dic[key]];
    }
    
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (where.length) [finalStr appendFormat:@" %@", where];
    
    
    flag =  [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    
    return flag;
}
-(NSArray *)lookupDicOrModel:(id)parameters whereFormat:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *dic;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"select * from %@ %@", _tableName, where?where:@""];
    NSArray *clomnArr = [self getTableColumn:_tableName andDB:_db];
    FMResultSet *set = [_db executeQuery:finalStr];
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
        while ([set next]) {
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:0];
            for (NSString *key in dic) {
                if ([dic[key] isEqualToString:SQL_TEXT]) {
                    id value = [set stringForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                } else if ([dic[key] isEqualToString:SQL_INTEGER]) {
                    [resultDic setObject:@([set longLongIntForColumn:key]) forKey:key];
                } else if ([dic[key] isEqualToString:SQL_REAL]) {
                    [resultDic setObject:[NSNumber numberWithDouble:[set doubleForColumn:key]] forKey:key];
                } else if ([dic[key] isEqualToString:SQL_BLOB]) {
                    id value = [set dataForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                }
                
            }
            if (resultDic) [resultMArr addObject:resultDic];
        }
    }else{
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        
        if (CLS) {
            NSDictionary * propertyType = [self modelToDictionary:CLS excludePropertyName:nil];
            while ([set next]) {
                id model = CLS.new;
                for (NSString *name in clomnArr) {
                    if ([propertyType[name] isEqualToString:SQL_TEXT]) {
                        id value = [set stringForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_INTEGER]) {
                        [model setValue:@([set longLongIntForColumn:name]) forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_REAL]) {
                        [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:name]] forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_BLOB]) {
                        id value = [set dataForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    }
                }
                [resultMArr addObject:model];
            }
        }
    }
    return resultMArr;
}
-(NSArray *)insertTableDicOrModelArray:(NSArray *)dicOrModelArray{
    int errorIndex = 0;
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *columnArr = [self getTableColumn:_tableName andDB:_db];
    
    for (id parameters in dicOrModelArray) {
        
        BOOL flag = [self insertDicOrModel:parameters columnArr:columnArr];
        if (!flag) {
            [resultMArr addObject:@(errorIndex)];
        }
        errorIndex++;
    }
    
    return resultMArr;

}

-(BOOL)deleteTable{
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", _tableName];

    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
     return YES;
}
-(BOOL)deleteAllDataFormTable{
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", _tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    
    return YES;

}
-(BOOL)isExistTable{
    FMResultSet *set = [_db executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", _tableName];
    while ([set next])
    {
        NSInteger count = [set intForColumn:@"count"];
        if (count == 0) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;

}
-(NSArray *)columnNameArray{
    return [self getTableColumn:_tableName andDB:_db];
}
-(int)tableItemCount{
    
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", _tableName];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        return [set intForColumn:@"count"];
    }
    return 0;
}

- (void)close
{
    [_db close];
}

- (void)open
{
    [_db open];
}

- (NSInteger)lastInsertPrimaryKeyId{
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM %@ where pkid = (SELECT max(pkid) FROM %@)", _tableName, _tableName];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        return [set longLongIntForColumn:@"pkid"];
    }
    return 0;
}
@end
