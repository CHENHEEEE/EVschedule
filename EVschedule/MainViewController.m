//
//  MainViewController.m
//  EVschedule
//
//  Created by 陈鹤 on 16/4/12.
//  Copyright © 2016年 陈鹤. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController{
    MBProgressHUD *HUD;
    LEAFConnection *_lcon;
    AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addFooterButton];
    
    appDelegate = [[UIApplication sharedApplication]delegate];
    HUD = [[MBProgressHUD alloc] initWithView:self->appDelegate.window];
    [self->appDelegate.window addSubview:HUD];
    
    // 载入用户数据
    HUD.labelText = @"载入中";
    HUD.dimBackground = YES;
    appDelegate.state = NSStuList;
    [HUD showWhileExecuting:@selector(loadStuList) onTarget:self withObject:nil animated:YES];
    
    NSLog(@"Stulist:%@",appDelegate.StuList);
    self.StuTableView.delegate = self;
    self.StuTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 载入用户数据
-(void)loadStuList{
    LEAFSoapComplete cblock = ^(BOOL isSuccess, LEAFStatusType status, NSString * requestString){
        if(isSuccess){
            NSLog(@"status:%ld",(long)status);
            NSLog(@"requestString:%@",requestString);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.StuTableView reloadData];
            });
        }else{
            NSLog(@"Failed->status:%ld\n r:%@",(long)status,requestString);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:@"载入失败，请刷新"];
            });
        }
    };
    
    appDelegate.state = NSStuList;
    
    LEAFSoapEntity *lse = [[LEAFSoapEntity alloc]init];
    lse.requestUrl = @"http://370381b0.nat123.net:18506/";
    lse.soapUrl = @"WebService1.asmx";
    lse.functionName = @"getStudentList";
    lse.nameSpace = @"http://tempuri.org/";
    lse.soapActionUrl = @"http://tempuri.org/getStudentList";
    lse.verifyKey = @"getStudentListResult";
    lse.isSyschronized = YES;
    lse.isStrongQuote = YES;
    _lcon = [LEAFConnection LEAFConnectionWithConfigurateEntity:lse];
    [_lcon startRequestWithCompleteBlock:cblock];
}

#pragma mark - TableView设置

#pragma mark 设置分组的组数:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark 设置分组的标题:
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"EVTeam成员列表";
//}

#pragma mark 设置每个分组下内容的个数:
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"StuList.length:%lu",(unsigned long)[appDelegate.StuList count]);
    return [appDelegate.StuList count];
}

#pragma mark 设置每个分组下的具体内容:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setText:[appDelegate.StuList objectAtIndex:indexPath.row]];
    //UIColor *color = [[UIColor alloc]initWithRed:255 green:100 blue:97 alpha:1];
    //cell.textLabel.textColor = color;
    //cell.textLabel.textAlignment = NSTextAlignmentCenter;
    NSLog(@"%@",[appDelegate.StuList objectAtIndex:indexPath.row]);
    return cell;
}

#pragma mark 设置分组标题和底部的高度:
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

#pragma mark 设置点击事件:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *content;
//    content=[NSString stringWithFormat:@"%@",[appDelegate.StuList objectAtIndex:indexPath.row]];
//    
//    //初始化提示框；
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:content preferredStyle:  UIAlertControllerStyleAlert];
//    
//    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        //点击按钮的响应事件；
//    }]];
//    
//    //弹出提示框；
//    NSLog(@"%@",content);
//    [self presentViewController:alert animated:true completion:nil];
    
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    appDelegate.selectedname = [NSString stringWithFormat:@"%@",[appDelegate.StuList objectAtIndex:indexPath.row]];
    appDelegate.selectedname = [appDelegate.selectedname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"selectedname:%@",appDelegate.selectedname);
    //[self performSegueWithIdentifier:@"toScheduleView" sender:self];
    
    //获取storyboard: 通过bundle根据storyboard的名字来获取我们的storyboard,
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    UIViewController *myView = [story instantiateViewControllerWithIdentifier:@"ScheduleView"];
    
    //由navigationController推向我们要推向的view
    //[self.navigationController pushViewController:myView animated:YES];
    [MBProgressHUD showMessage:@"载入中"];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    //这句就是push了，所以在push前加上这样一句，就保留了系统的自带的“<"，并且文字为空
    [self.navigationController pushViewController:myView animated:YES];
    
    myView.title = appDelegate.selectedname;
}

#pragma mark - 增加注销按钮
-(void)addFooterButton
{
    //1.初始化Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //2.设置文字和文字颜色
    [button setTitle:@"注销" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //3.设置圆角幅度
    button.layer.cornerRadius = 10.0;
    button.layer.borderWidth = 0;
    
    //4.设置frame
    button.frame = CGRectMake(0, 100, 20, 44);
    
    //5.设置背景色
    UIColor *bgcolor = [[UIColor alloc]initWithRed:1 green:100.0/255 blue:97.0/255 alpha:1];
    button.backgroundColor = bgcolor;
    
    //6.设置触发事件
    [button addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    
    //7.添加到tableView tableFooterView中
    self.StuTableView.tableFooterView = button;
}

- (void)logout:(id)sender {
    //获取UserDefaults单例
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //移除UserDefaults中存储的用户信息
    [userDefaults removeObjectForKey:@"username"];
    [userDefaults synchronize];
    //获取storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    //获取注销后要跳转的页面
    id view = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    
    [appDelegate.StuList removeAllObjects];
    
    //模态展示出登陆页面
    [self presentViewController:view animated:YES completion:^{
    }];
}

#pragma mark 刷新键
- (IBAction)refresh:(id)sender {
    [appDelegate.StuList removeAllObjects];
    [HUD showWhileExecuting:@selector(loadStuList) onTarget:self withObject:nil animated:YES];
}
@end
