//
//  ViewController.h
//  EVschedule
//
//  Created by 陈鹤 on 16/3/31.
//  Copyright © 2016年 陈鹤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "LEAFConnection.h"
#import "AppDelegate.h"
#import "MBProgressHUD+NJ.h"

@interface ViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIView *loginview;

- (IBAction)login:(id)sender;
- (IBAction)forgetpss:(id)sender;
- (IBAction)EndEditTap:(id)sender;

@end

