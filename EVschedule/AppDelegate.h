//
//  AppDelegate.h
//  EVschedule
//
//  Created by 陈鹤 on 16/3/31.
//  Copyright © 2016年 陈鹤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

typedef enum{
    NSlogin  = 0,
    NSStuList,
    NSSchedule,
    NSUpdatetime,
    NSUpdateSchedule
} NetState;

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) UINavigationController *navigationcontroller;

//全局变量
@property(nonatomic,retain)NSMutableArray *StuList;
@property(nonatomic)NetState state;
@property(nonatomic,retain)NSMutableArray *Schedule;
@property(nonatomic,retain)NSMutableArray *updatetime;
@property(nonatomic,retain)NSString *selectedname;
@property(nonatomic)BOOL Scheduleneedrefresh;
@property(nonatomic)BOOL updatetimeneedrefresh;

@end

