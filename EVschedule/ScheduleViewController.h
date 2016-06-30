//
//  ScheduleViewController.h
//  EVschedule
//
//  Created by 陈鹤 on 16/4/17.
//  Copyright © 2016年 陈鹤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "LEAFConnection.h"
#import "AppDelegate.h"
#import "MBProgressHUD+NJ.h"

@interface ScheduleViewController : UITableViewController<UITextFieldDelegate>

@property (strong,nonatomic) IBOutlet UITableView *ScheduleTableView;

- (IBAction)refresh:(id)sender;
@end
