//
//  StartVC.m
//  ChatDemo
//
//  Created by TI on 15/6/5.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "StartVC.h"
#import "Defines.h"
#import "LYKeyBoardView.h"
#import "LYTextView.h"

#import "NSManagedObject+Category.h"
#import "Message.h"

@interface StartVC ()<LYKeyBoardViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    BOOL typeChange;
}
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) LYKeyBoardView * keyBoard;
@property (nonatomic, strong) NSMutableArray * infoArray;
@end

@implementation StartVC

-(NSMutableArray *)infoArray{
    if (!_infoArray) {
        _infoArray = [[Message filter:nil orderby:@[@"objID"] offset:0 limit:0] mutableCopy];
    }
    return _infoArray;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.infoArray.count == 0) return;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.infoArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    typeChange = ((Message*)self.infoArray.lastObject).type.boolValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keyBoard = [[LYKeyBoardView alloc]
                     initDelegate:self
                     superView:self.view];
    [self initUI];
}

-(void)initUI{
    [self addTableView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(tapAction)];
    [self.tableView addGestureRecognizer:tap];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clearDataSource)];
}

-(void)addTableView{
    self.tableView = [[UITableView alloc]
                      initWithFrame:[self tableViewFrame]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view insertSubview:self.tableView belowSubview:self.keyBoard];
}

#pragma mark - key board delegate
-(void)keyBoardView:(LYKeyBoardView *)keyBoard ChangeDuration:(CGFloat)durtaion{
    if (self.infoArray.count == 0) return;
    [UIView animateWithDuration:durtaion animations:^{
        self.tableView.frame = [self tableViewFrame];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.infoArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }];
}

-(void)keyBoardView:(LYKeyBoardView *)keyBoard audioRuning:(UILongPressGestureRecognizer *)longPress{
    LOG(@"录音 -> 在此处理");
    if (longPress.state == UIGestureRecognizerStateEnded) {
        [self keyBoardView:keyBoard sendMessage:@"录音"];
    }
}

-(void)keyBoardView:(LYKeyBoardView *)keyBoard imgPicType:(UIImagePickerControllerSourceType)sourceType{
    LOG(@"相机 相册 -> 在此处理");
    NSString * m;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        m = @"相机";
    }else{
        m = @"相册";
    }
    [self keyBoardView:keyBoard sendMessage:m];
}

-(void)keyBoardView:(LYKeyBoardView *)keyBoard sendMessage:(NSString *)message{
    if (!message || message.length==0) return;
    
    Message * m = [Message createNew];
    m.content = message;
    m.type = (typeChange = !typeChange)?@(MessageTypeMe):@(MessageTypeOther);
    if (self.infoArray.count > 0) {
        m.objID = @(((Message*)[self.infoArray lastObject]).objID.intValue);
    }else{
        m.objID = @(0);
    }
    
    [Message save:^(NSError *error) {
        [self endSend:m];
    }];
}

#pragma mark - tableView delegate & dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoArray.count;
}

static NSString * cellID = @"cellID";
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    Message * m = (Message*)self.infoArray[indexPath.row];
    NSString * string = [NSString stringWithFormat:@"%@: %@",m.type.intValue == MessageTypeMe?@"大师兄":@"小师妹" , m.content];
    cell.textLabel.attributedText = [LYTextView getAttributedText:string font:[UIFont systemFontOfSize:15.0f] color:m.type.intValue == MessageTypeMe?[UIColor redColor]:[UIColor blackColor]  jamScale:1.0 bottom:3];
    return cell;
}

#pragma mark - self action
-(void)tapAction{
    [self.keyBoard tapAction];
}

-(CGRect)tableViewFrame{
    CGRect frame = self.view.bounds;
    frame.size.height = self.keyBoard.frame.origin.y;
    return frame;
}

-(void)endSend:(Message*)message{
    [self.infoArray addObject:message];
    [self.tableView beginUpdates];
    NSIndexPath * path = [NSIndexPath indexPathForRow:(self.infoArray.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)clearDataSource{
    
    if (self.infoArray.count == 0) return;
    
    for (Message * m in self.infoArray) {
        [Message delobject:m];
    }
    
    [Message save:^(NSError *error) {
        [self.infoArray removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

@end
