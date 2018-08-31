//
//  Student.m
//  DBSqliteModel
//
//  Created by EISOO on 2018/8/15.
//  Copyright © 2018年 eisoo. All rights reserved.
//

#import "Student.h"
#import "InvocationObj.h"
@interface Student ()
@property (nonatomic ,retain)InvocationObj * someObjc;
@end

@implementation Student
{
    NSString * _age;
    NSString * isAge10;

    
}
-(instancetype)init{
    if (self = [super init]) {
        _someObjc = [[InvocationObj alloc]init];
    }
    return self;
}
//+(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key{
//    
//    if ([key isEqualToString:@"age"]) {
//        return YES;
//    }else{
//        return [super automaticallyNotifiesObserversForKey:key];
//    }
//    
//}
//-(void)printF{
//    NSLog(@"%@",_age);
//}
//-(void)setAge:(NSString *)age{
//    [self willChangeValueForKey:@"age"];
//    _age = age;
//    [self didChangeValueForKey:@"age"];
    
//}
-(NSMethodSignature * )methodSignatureForSelector:(SEL)aSelector{
//    NSMethodSignature * sign = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    NSMethodSignature * sig = [super methodSignatureForSelector:aSelector];
    if (!sig) {
        sig = [_someObjc methodSignatureForSelector:aSelector];
    }
    return sig;
    }
-(void)forwardInvocation:(NSInvocation *)anInvocation{
    if ([_someObjc respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_someObjc];
    }else{
    [super forwardInvocation:anInvocation];
    }
    
}
-(void)doesNotRecognizeSelector:(SEL)aSelector{
    NSLog(@"crrash***********");
    NSString *selectedStr = NSStringFromSelector(aSelector);
    [self crashHandle:selectedStr];

    
}
- (void)crashHandle:(NSString *)selName {
    
}
@end
