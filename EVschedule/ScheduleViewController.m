//
//  ScheduleViewController.m
//  EVschedule
//
//  Created by 陈鹤 on 16/4/17.
//  Copyright © 2016年 陈鹤. All rights reserved.
//

#import "ScheduleViewController.h"

@interface ScheduleViewController ()

@end

@implementation ScheduleViewController{
    LEAFConnection *_lcon;
    AppDelegate *appDelegate;
    UIAlertController *customAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    appDelegate = [[UIApplication sharedApplication]delegate];

    [MBProgressHUD showMessage:@"载入中"];
    
    [self performSelectorInBackground:@selector(loadSchedule) withObject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder {
    return true;
}

#pragma mark - 联网线程
#pragma mark 载入用户日程
-(void)loadSchedule{
    LEAFSoapComplete cblock = ^(BOOL isSuccess, LEAFStatusType status, NSString * requestString){
        if(isSuccess){
            NSLog(@"status:%ld",(long)status);
            NSLog(@"requestString:%@",requestString);
            appDelegate.Scheduleneedrefresh = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadupdatetime];
            });
        }else{
            NSLog(@"Failed->status:%ld\n r:%@",(long)status,requestString);
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"载入失败，请刷新"];
        }
    };
    
    appDelegate.state = NSSchedule;
    
    LEAFSoapEntity *lse = [[LEAFSoapEntity alloc]init];
    lse.requestUrl = @"http://370381b0.nat123.net:18506/";
    lse.soapUrl = @"WebService1.asmx";
    lse.functionName = @"selectStudentInfo";
    lse.nameSpace = @"http://tempuri.org/";
    lse.soapActionUrl = @"http://tempuri.org/selectStudentInfo";
    lse.verifyKey = @"selectStudentInfoResult";
    [lse setParameterStringValue:appDelegate.selectedname forKey:@"Sname"];
    lse.isSyschronized = YES;
    lse.isStrongQuote = YES;
    _lcon = [LEAFConnection LEAFConnectionWithConfigurateEntity:lse];
    [_lcon startRequestWithCompleteBlock:cblock];
}

#pragma mark 载入更新时间
-(void)loadupdatetime{
    LEAFSoapComplete cblock = ^(BOOL isSuccess, LEAFStatusType status, NSString * requestString){
        if(isSuccess){
            NSLog(@"status:%ld",(long)status);
            NSLog(@"requestString:%@",requestString);
            appDelegate.updatetimeneedrefresh = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ScheduleTableView reloadData];
            });
            [MBProgressHUD hideHUD];
        }else{
            NSLog(@"Failed->status:%ld\n r:%@",(long)status,requestString);
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"载入失败，请刷新"];
        }
    };
    
    appDelegate.state = NSUpdatetime;
    
    LEAFSoapEntity *lse = [[LEAFSoapEntity alloc]init];
    lse.requestUrl = @"http://370381b0.nat123.net:18506/";
    lse.soapUrl = @"WebService1.asmx";
    lse.functionName = @"selectStudentInfo";
    lse.nameSpace = @"http://tempuri.org/";
    lse.soapActionUrl = @"http://tempuri.org/selectStudentInfo";
    lse.verifyKey = @"selectStudentInfoResult";
    NSString *time = [@"1" stringByAppendingString:appDelegate.selectedname];
    [lse setParameterStringValue:time forKey:@"Sname"];
    lse.isSyschronized = YES;
    lse.isStrongQuote = YES;
    _lcon = [LEAFConnection LEAFConnectionWithConfigurateEntity:lse];
    [_lcon startRequestWithCompleteBlock:cblock];
}

#pragma mark 更新日程
-(void)updateSchedule:(NSMutableArray *)array{
    NSString *when = array[0];
    NSNumber *index = array[1];
    NSString *what = array[2];
    
    LEAFSoapComplete cblock = ^(BOOL isSuccess, LEAFStatusType status, NSString * requestString){
        if(isSuccess && [requestString  isEqual: @"true"]){
            NSLog(@"status:%ld",(long)status);
            NSLog(@"requestString:%@",requestString);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showMessage:@"更新失败\n刷新重试"];
                [self loadSchedule];
            });
        }
    };
    
    appDelegate.state = NSUpdateSchedule;
    
    //获取当前时间，若非本人修改，再加上修改者姓名
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    [formater setDateFormat:@"MM月dd日 HH:mm"];
    NSDate *curDate = [NSDate date];//获取当前日期
    NSString * curTime = [formater stringFromDate:curDate];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *name = [userDefault objectForKey:@"username"];
    if(![appDelegate.selectedname isEqualToString:name]){
        curTime = [NSString stringWithFormat:@"%@%@(改)",curTime,name];
    }
    
    //修改日程
    [appDelegate.Schedule replaceObjectAtIndex:[index intValue] withObject:what];
    [appDelegate.updatetime replaceObjectAtIndex:[index intValue] withObject:curTime];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.ScheduleTableView reloadData];
    });
    
    LEAFSoapEntity *lse = [[LEAFSoapEntity alloc]init];
    lse.requestUrl = @"http://370381b0.nat123.net:18506/";
    lse.soapUrl = @"WebService1.asmx";
    lse.functionName = @"updateStudentInfo";
    lse.nameSpace = @"http://tempuri.org/";
    lse.soapActionUrl = @"http://tempuri.org/updateStudentInfo";
    lse.verifyKey = @"updateStudentInfoResult";
    //设置参数
    [lse setParameterStringValue:appDelegate.selectedname forKey:@"Sname"];
    [lse setParameterStringValue:when forKey:@"when"];
    [lse setParameterStringValue:what forKey:@"what"];
    [lse setParameterStringValue:curTime forKey:@"time"];
    
    lse.isSyschronized = YES;
    lse.isStrongQuote = YES;
    _lcon = [LEAFConnection LEAFConnectionWithConfigurateEntity:lse];
    [_lcon startRequestWithCompleteBlock:cblock];
}


#pragma mark - Table view data source
#pragma mark 设置分组的组数:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}

#pragma mark 返回每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

#pragma mark 设置分组的标题:
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"星期一";
            break;
        case 1:
            return @"星期二";
            break;
        case 2:
            return @"星期三";
            break;
        case 3:
            return @"星期四";
            break;
        case 4:
            return @"星期五";
            break;
        case 5:
            return @"星期六";
            break;
        case 6:
            return @"星期天";
            break;
        default:
            return nil;
            break;
    }
}

#pragma mark 设置每个分组下的具体内容:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    if([appDelegate.Schedule count] != 0 || [appDelegate.updatetime count] != 0){
        NSInteger index = indexPath.section*2 + indexPath.row;
        if(index>=0 && index<appDelegate.Schedule.count){
            [cell.textLabel setText:[appDelegate.Schedule objectAtIndex:index]];
        }
        if(index>=0 && index<appDelegate.updatetime.count){
            [cell.detailTextLabel setText:[appDelegate.updatetime objectAtIndex:index]];
        }
        //UIColor *color = [[UIColor alloc]initWithRed:255 green:100 blue:97 alpha:1];
        //cell.textLabel.textColor = color;
        //cell.textLabel.textAlignment = NSTextAlignmentCenter;
        //NSLog(@"%@",[appDelegate.StuList objectAtIndex:indexPath.row]);
    }
    return cell;
}

#pragma mark 设置分组标题和底部的高度:
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}

#pragma mark 设置点击事件:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *content;
    NSInteger index = indexPath.section*2 + indexPath.row;
    
    if(index<0 ||index>= appDelegate.Schedule.count) return;

    NSInteger temp = index +1;
    NSString *when = [NSString stringWithFormat:@"a%ld",(long)temp];
    
    if(index>=0 && index<appDelegate.Schedule.count){
        content=[NSString stringWithFormat:@"%@",[appDelegate.Schedule objectAtIndex:index]];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObject:when];
    [array addObject:[NSNumber numberWithInteger:index]];
    //初始化提示框；
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更新" message:content preferredStyle:  UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"输入新日程";
        textField.delegate = self;
        textField.tag = 999;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        
    }];
    
    UIAlertAction *okaction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
        UITextField *newSchedule = alert.textFields.firstObject;
        [newSchedule resignFirstResponder];
        [array addObject:newSchedule.text];
        [self performSelectorInBackground:@selector(updateSchedule:) withObject:array];
        
        //[self updateSchedule:newSchedule.text withString:when Integer:index];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    }];
    okaction.enabled = NO;
    [alert addAction:okaction];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"实验室" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        [array addObject:@"实验室"];
        [self performSelectorInBackground:@selector(updateSchedule:) withObject:array];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"东莞研究院" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        [array addObject:@"东莞研究院"];
        [self performSelectorInBackground:@selector(updateSchedule:) withObject:array];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"出差" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        [array addObject:@"出差"];
        [self performSelectorInBackground:@selector(updateSchedule:) withObject:array];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"上课" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        [array addObject:@"上课"];
        [self performSelectorInBackground:@selector(updateSchedule:) withObject:array];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"请假" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        [array addObject:@"请假"];
        [self performSelectorInBackground:@selector(updateSchedule:) withObject:array];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    //弹出提示框；
    NSLog(@"%@",content);
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma 检查日程文本框的内容
-(void)alertTextFieldDidChange:(NSNotification *)notification{
    UIAlertController *alertcontroller = (UIAlertController *)self.presentedViewController;
    if(alertcontroller){
        UITextField *textfield = alertcontroller.textFields.firstObject;
        UIAlertAction *action = alertcontroller.actions.firstObject;
        action.enabled = textfield.text.length>1;
    }
}
#pragma 文本框开始编辑
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField.tag==999){
        textField.tag=0;
        return NO;
    }else return YES;
}

#pragma mark - 导航栏按钮事件
#pragma mark 刷新键
- (IBAction)refresh:(id)sender {
    [MBProgressHUD showMessage:@"载入中"];
    [self loadSchedule];
}
@end
