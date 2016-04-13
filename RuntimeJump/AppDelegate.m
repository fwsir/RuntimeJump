//
//  AppDelegate.m
//  RuntimeJump
//
//  Created by BOOM on 16/4/5.
//  Copyright © 2016年 DEVIL. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self test];
    });
    
    return YES;
}

- (void)test{
    
    NSDictionary *userInfo = @{
                               @"class":@"FeedViewController",
                               @"property":@{
                                       @"ID":@"123",
                                       @"type":@"12"
                                       }
                               };
    
    [self push:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    [self push:userInfo];
}

- (void)push:(NSDictionary *)params{
    
    NSString *className = params[@"class"];
    Class newClass = NSClassFromString(className);
    
    if (!newClass) {
        
        Class superClass = [UIViewController class];
        newClass = objc_allocateClassPair(superClass, [className UTF8String], 0);
        
        // 注册这个类
        objc_registerClassPair(newClass);
    }
    
    // 创建对象
    id instance = [[newClass alloc] init];
    
    NSDictionary *propertys = params[@"property"];
    [propertys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        // 检测这个对象是否存在该属性
        if ([self checkPropertyWithInstance:instance verifyPropertyName:key]) {
            
            // 利用kvc赋值
            [instance setValue:obj forKey:key];
        }
    }];
    
    // 获取导航控制器
    UITabBarController *tabVC = (UITabBarController *)self.window.rootViewController;
    UINavigationController *pushClassStance = (UINavigationController *)tabVC.viewControllers[tabVC.selectedIndex];
    
    // 跳转到对应的控制器
    [pushClassStance pushViewController:instance animated:YES];
}

// 检查对象是否存在该属性
- (BOOL)checkPropertyWithInstance:(id)instance verifyPropertyName:(NSString *)verifyPropertyName{
    
    unsigned int outCount;
    
    // 获取属性列表
    objc_property_t *properties = class_copyPropertyList([instance class], &outCount);
    for (int i = 0; i < outCount; ++i) {
        objc_property_t property = properties[i];
        
        // 属性名转成字符串
        NSString *propertyName = [[NSString alloc] initWithUTF8String:property_getName(property)];
        
        // 判断属性是否存在
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    
    free(properties);
    return NO;
}

@end
