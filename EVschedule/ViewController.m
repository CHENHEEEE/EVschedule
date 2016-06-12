//
//  ViewController.m
//  EVschedule
//
//  Created by 陈鹤 on 16/3/31.
//  Copyright © 2016年 陈鹤. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    MBProgressHUD *HUD;
    LEAFConnection *_lcon;
    AppDelegate *appdelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _username.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    _username.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* imgUser = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 22, 22)];
    imgUser.image = [UIImage imageNamed:@"iconfont-user"];
    [_username.leftView addSubview:imgUser];

    _password.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    _password.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* imgPwd = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 22, 22)];
    imgPwd.image = [UIImage imageNamed:@"iconfont-password"];
    [_password.leftView addSubview:imgPwd];
    
    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUD];
    
    [_username setDelegate:self];
    [_password setDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [HUD showWhileExecuting:@selector(loginWithUsername) onTarget:self withObject:nil animated:YES];
}

- (IBAction)forgetpss:(id)sender {
}

- (IBAction)EndEditTap:(id)sender {
    [self.view endEditing:YES];
}

// 服务器交互进行用户名，密码认证
-(void)loginWithUsername{
    HUD.labelText = @"登录中";
    appdelegate = [[UIApplication sharedApplication]delegate];
    appdelegate.state = NSlogin;
    
    LEAFSoapComplete cblock = ^(BOOL isSuccess, LEAFStatusType status, NSString * requestString){
        if(isSuccess){
            NSLog(@"status:%ld",(long)status);
            NSLog(@"requestString:%@",requestString);
            if([@"ok"  isEqual: requestString]){
                //保存用户状态
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:self.username.text forKey:@"username"];
                //[userDefaults setObject:self.password.text forKey:@"password"];
                [userDefaults synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"toMainView" sender:self];
                });
            }else if([@"incorrect" isEqual: requestString]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showError:@"密码错误"];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showError:@"未注册或其他原因"];
                });
            }
        }else{
            NSLog(@"Failed->status:%ld\n r:%@",(long)status,requestString);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:@"网络错误，请重试"];
            });
        }
    };
    
    LEAFSoapEntity *lse = [[LEAFSoapEntity alloc]init];
    lse.requestUrl = @"http://370381b0.nat123.net:18506/";
    lse.soapUrl = @"WebService1.asmx";
    lse.functionName = @"Login";
    lse.nameSpace = @"http://tempuri.org/";
    lse.soapActionUrl = @"http://tempuri.org/Login";
    lse.verifyKey = @"LoginResult";
    lse.isSyschronized = YES;
    lse.isStrongQuote = YES;
    [lse setParameterStringValue:self.username.text forKey:@"Sname"];
    [lse setParameterStringValue:self.password.text forKey:@"pss"];
    _lcon = [LEAFConnection LEAFConnectionWithConfigurateEntity:lse];
    [_lcon startRequestWithCompleteBlock:cblock];
}

//返回键事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.username){
        [self.username resignFirstResponder];
        [self.password becomeFirstResponder];
    }else{
        [self.password resignFirstResponder];
        [HUD showWhileExecuting:@selector(loginWithUsername) onTarget:self withObject:nil animated:YES];
    }
    return YES;
}

//改变状态看字体颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
