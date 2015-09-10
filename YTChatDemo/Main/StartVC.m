//
//  StartVC.m
//  ChatDemo
//
//  Created by TI on 15/6/5.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "NSManagedObject+YTMoreThread.h"
#import "YTImageBrowerController.h"
#import "YTKeyBoardView.h"
#import "YTDeviceTest.h"
#import "Defines.h"
#import "StartVC.h"
#import "Message.h"
@import AssetsLibrary;

@interface StartVC ()<YTKeyBoardDelegate,UITableViewDataSource,UITableViewDelegate,YTImageBrowerControllerDelegate>
{
    BOOL typeChange;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YTKeyBoardView *keyBoard;
@property (nonatomic, strong) NSMutableArray *infoArray;

@property (nonatomic, strong) YTImageBrowerController *ImgBrower;
@end

@implementation StartVC

- (NSMutableArray *)infoArray{
    if (!_infoArray) {
        _infoArray = [[Message filter:nil orderby:@[@"objID"] offset:0 limit:0] mutableCopy];
    }
    return _infoArray;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.infoArray.count == 0) return;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.infoArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    typeChange = ((Message *)self.infoArray.lastObject).type.boolValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keyBoard = [[YTKeyBoardView alloc]
                     initDelegate:self
                     superView:self.view];
    [self initUI];
}

- (void)initUI{
    [self addTableView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(tapAction)];
    [self.tableView addGestureRecognizer:tap];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clearDataSource)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"浏览相册" style:UIBarButtonItemStyleDone target:self action:@selector(seePhoto)];
}

- (void)addTableView{
    UITableView *tableView = [[UITableView alloc]
                              initWithFrame:[self tableViewFrame]];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view insertSubview:(self.tableView = tableView) belowSubview:self.keyBoard];
}

#pragma mark - key board delegate
- (void)keyBoardView:(YTKeyBoardView *)keyBoard ChangeDuration:(CGFloat)durtaion{
    if (self.infoArray.count == 0) return;
    [UIView animateWithDuration:durtaion animations:^{
        self.tableView.frame = [self tableViewFrame];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.infoArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }];
}

- (void)keyBoardView:(YTKeyBoardView *)keyBoard audioRuning:(UILongPressGestureRecognizer *)longPress{
    LOG(@"录音 -> 在此处理");
    if (longPress.state == UIGestureRecognizerStateEnded) {
        [self keyBoardView:keyBoard sendResous:@"录音"];
    }
}

- (void)keyBoardView:(YTKeyBoardView *)keyBoard otherType:(YTMoreViewTypeAction)type{
    LOG(@"相机 相册 -> 在此处理");
    NSString * m;
    if (type == YTMoreViewTypeActionCamera) {
        m = @"相机";
    }else{
        m = @"相册";
    }
    [self keyBoardView:keyBoard sendResous:m];
}

- (void)keyBoardView:(YTKeyBoardView *)keyBoard sendResous:(id)resous{
    if (!resous) return;
    NSString *string = @"";
    if ([resous isKindOfClass:[NSString class]]) {
        string = resous;
    }else if ([resous isKindOfClass:[UIImage class]]){
        UIImage *image = resous;
        CGRect rect = CGRectZero;
        rect.size = image.size;
        UIView *view = [[UIView alloc]initWithFrame:rect];
        rect.origin.x = (self.view.bounds.size.width - rect.size.width)*0.5f;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
        imageView.image = image;
        [view addSubview:imageView];
        self.tableView.tableFooterView = view;
        string = [NSString stringWithFormat:@"image:size->%@ ⬇️ 有图片展示",NSStringFromCGSize(image.size)];
    }else{
        return;
    }
    
    Message * m = [Message createNew];
    m.content = string;
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoArray.count;
}

static NSString * cellID = @"cellID";
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    Message * m = (Message*)self.infoArray[indexPath.row];
    NSString * string = [NSString stringWithFormat:@"%@: %@",m.type.intValue == MessageTypeMe?@"大师兄":@"小师妹" , m.content];
    UIColor *color = m.type.intValue == MessageTypeMe?[UIColor redColor]:[UIColor blackColor];
    cell.textLabel.attributedText = [YTTextView getAttributedText:string Font:nil Color:color Offset:-3];
    return cell;
}

#pragma mark - self action
- (void)tapAction{
    [self.keyBoard tapAction];
}

- (CGRect)tableViewFrame{
    CGRect frame = self.view.bounds;
    if (!self.navigationController) {
        frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    frame.size.height = self.keyBoard.frame.origin.y-frame.origin.y;
    return frame;
}

- (void)endSend:(Message*)message{
    [self.infoArray addObject:message];
    [self.tableView beginUpdates];
    NSIndexPath * path = [NSIndexPath indexPathForRow:(self.infoArray.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)clearDataSource{
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

//-------------------------------------------------------------
/*
 在这里仅仅是微弱的展示ACDsee的用法，时间原因，后面打算写一个类似微信的相册发
 图片功能，不过核心功能已经完成，只是一些零碎的搭建和对ACDsee二次封装还没进行
 有兴趣的朋友也可看下这个https://github.com/TiYcc/ImageBrower.git是我
 写的，仅仅作为了解，还是值得一看的。
 */
- (void)seePhoto{
    NSMutableArray *assets = [NSMutableArray array];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [assets addObject:result];
                }
            }];
        }else{
            self.ImgBrower = [[YTImageBrowerController alloc]initWithDelegate:self Assets:assets PageIndex:MIN(3, assets.count-1)];
            return ;
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)ACDSeeControllerInitEnd:(CGSize)size{
    [self presentViewController:self.ImgBrower animated:YES completion:^{
    }];
}

- (void)ACDSeeControllerWillDismiss:(CGSize)size Img:(UIImage *)img Index:(NSInteger)index{
    self.tableView.backgroundColor = [UIColor whiteColor];
}

@end
