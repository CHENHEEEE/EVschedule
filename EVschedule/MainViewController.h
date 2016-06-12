//
//  MainViewController.h
//  EVschedule
//
//  Created by 陈鹤 on 16/4/12.
//  Copyright © 2016年 陈鹤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "LEAFConnection.h"
#import "AppDelegate.h"
#import "MBProgressHUD+NJ.h"

@interface MainViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *StuTableView;

- (IBAction)refresh:(id)sender;
@end
