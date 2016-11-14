//
//  ViewController.m
//  AddressBookDemo
//
//  Created by 徐勇 on 2016/10/28.
//  Copyright © 2016年 iamnowhere. All rights reserved.
//

#import "ViewController.h"
#import "YZAddressBookHelper.h"
#import "InviteFriendCell.h"

#import <MessageUI/MessageUI.h> //程序内调用系统发短信

static NSString *AddFriendCellID = @"AddFriendCell";

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *addressBookArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self getAddressBookData];
    [self initTableView];
}

- (void)getAddressBookData{
    
    [YZAddressBookHelper requestAddressBookByAlphabetClassifySortArrayWithSuccess:^(NSArray *addressBookArray) {
        
        if (addressBookArray.count >0) {
            [_addressBookArray removeAllObjects];
            _addressBookArray = [NSMutableArray arrayWithArray:addressBookArray];
            [_tableView reloadData];
        }
        
    } fail:^{
        //
    }];
}

- (void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"InviteFriendCell" bundle:nil] forCellReuseIdentifier:AddFriendCellID];
    
    self.tableView.rowHeight = 60;
    self.tableView.sectionHeaderHeight = 20;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _addressBookArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *addressBook = _addressBookArray[section];
    NSArray *arr = addressBook[@"value"];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:AddFriendCellID forIndexPath:indexPath];
    NSDictionary *addressBook = _addressBookArray[indexPath.section];
    NSArray *arr = addressBook[@"value"];
    NSDictionary *dict2 = arr[indexPath.row];
    
    cell.nameLabel.text = dict2[@"name"];
    cell.nicknameLabel.text = dict2[@"phone"];
    cell.telphone = dict2[@"phone"];
    
    NSString *uid  = @"";
    NSString *title = [NSString stringWithFormat:@"你也在用[压寨]聊天吧！用动作聊天真的超有意思的，快上来加我好友。如果你还没安装，点下面的地址安装：http://api.yazhai.com/share/chat/%@",uid];
    [self showMessageView:@[[dict2 objectForKey:@"phone"]] title:@"短信邀请" body:title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Identifier"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:@"Identifier"];
    }
    NSDictionary *dict = _addressBookArray[section];
    header.textLabel.text = dict[@"key"];
    header.backgroundColor = [UIColor lightGrayColor];
    
    return header;
}


#pragma mark - 应用内发短信

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //测试
    
    switch (result) {
        case MessageComposeResultSent:{
            //信息传送成功
            //state	短信发送状态(默认发送成功0,失败-1,取消1)
        }
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            //state	短信发送状态(默认发送成功0,失败-1,取消1)
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            //state	短信发送状态(默认发送成功0,失败-1,取消1)
            break;
        default:
            break;
    }
}

-(void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body
{
    if( [MFMessageComposeViewController canSendText] ){
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = phones;
        controller.navigationBar.tintColor = [UIColor blackColor];//
        controller.body = body;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"该设备不支持短信功能"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
