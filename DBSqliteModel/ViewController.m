//
//  ViewController.m
//  DBSqliteModel
//
//  Created by EISOO on 2018/8/14.
//  Copyright © 2018年 eisoo. All rights reserved.
//

#import "ViewController.h"
#import "KvinDbShift.h"
#import "Student.h"
#import <objc/runtime.h>
@interface ViewController ()
@property (nonatomic ,retain) Student * stu;
@property (nonatomic ,retain) UIPageControl * pageContr;
@end

@implementation ViewController
__weak id reference = nil;
- (void)viewDidLoad {
    [super viewDidLoad];
    KvinDbShift  * kvinDB = [KvinDbShift shareInstance];
    [kvinDB createTableWithParams:[Student new]];
    Student * s = [[Student alloc]init];
    s.name = @"111";
//    s.age = @"2";
    [kvinDB insertDicOrModel:s];
    NSString *str = [NSString stringWithFormat:@"sunnyxx"];    // str是一个autorelease对象，设置一个weak的引用来观察它
    
    reference = str;
   Student* stu = [[Student alloc]init];
//    [stu printF];
    [stu performSelectorOnMainThread:@selector(printF) withObject:nil waitUntilDone:YES];
    //
//    [_stu addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
//    _pageContr = [[UIPageControl alloc]init];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    _stu.age = @"10";
    [_stu setValue:@"10" forKey:@"age"];
//    [_stu printF];
//    [self getProperties];
//    [self getAllIvarList];
//    [_stu  valueForKey:@"age10"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context{

}


-(void)getProperties{
    u_int count = 0;
    objc_property_t *properties = class_copyPropertyList([UIPageControl class], &count);
    NSMutableArray  * m_Arr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * m_Arr1 = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        const char *attributes = property_getAttributes(properties[i]);
        NSString *str = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSString *attributesStr = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
        [m_Arr addObject:str];
        [m_Arr1 addObject:attributesStr];
        NSLog(@"propertyName : %@", str);
        NSLog(@"attributesStr : %@", attributesStr);
    }
    
    
}
- (void) getAllIvarList {
    unsigned int methodCount = 0;

    Ivar * ivars = class_copyIvarList([UIPageControl class], &methodCount);
    NSMutableArray  * m_Arr = [NSMutableArray arrayWithCapacity:0];

    for (unsigned int i = 0; i < methodCount; i ++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        const char * type = ivar_getTypeEncoding(ivar);
        NSString *name_str = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];

        [m_Arr addObject:name_str];
        NSLog(@"Person拥有的成员变量的类型为%s，名字为 %s ",type, name);
    }
    free(ivars);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@", reference); // Console: sunnyxx
    
}
-(void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
    NSLog(@"%@", reference); // Console: (null)}
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
