//
//  YTKeyBoardView.m
//  YTChatDemo
//
//  Created by TI on 15/8/31.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "SLGrowingTextView.h"
#import "YTKeyBoardView.h"
#import "UIView+YTLayer.h"
#import "UIImage+YTGif.h"
#import "YTDeviceTest.h"
#import "YTEmojiView.h"
#import "YTEmoji.h"

@interface YTSwitcherView : UIView

@end

@implementation YTSwitcherView
#define  DURTAION  0.25f
- (void)addSubview:(UIView *)view{
    // 动画添加子view 并且改控件只包含一个子view
    CGRect rect = self.frame;
    CGRect frame = view.frame;
    rect.size.height = CGRectGetHeight(frame);
    self.frame = rect;
    for (UIView * v in self.subviews) {// 移除前一个view
        [v removeFromSuperview];
    }
    [super addSubview:view];// 添加一个view
    frame.origin.y = CGRectGetHeight(self.frame);
    view.frame = frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:DURTAION animations:^{// 动画显示
        view.frame = frame;
    }];
}

@end

@interface YTKeyBoardView()<SLGrowingTextViewDelegate,YTEmojiViewDelegate,YTMoreViewDelegate>{
    /* topView 一些设置全局参数 */
    CGFloat top_end_h; // textView 隐藏前的高度
    
    /* textView 一些设置全局参数 */
    //CGFloat text_one_hight; // 一行文字高度
    NSUInteger text_location; // 将要插入表情时 记录最后光标位置
    BOOL text_beInsert; // 记录光标位置后 是否允许插入表情
    
    /* keyBoard 一些设置全局参数 */
    BOOL kb_resign; //系统键盘已响应 响应为YES:且每次响应其值仅用一次
    BOOL kb_visiable;
    
    /* audio(音频) 一些设置全局参数 */
    BOOL audio_beTap; //音频状态按钮是否已被点击
}

@property (nonatomic, strong) UIButton *audio; //录音图标
@property (nonatomic, strong) UIButton *emoji; //表情图标
@property (nonatomic, strong) UIButton *more;  //更多图标“+”
@property (nonatomic, strong) NSArray *icons;  //图标集合

@property (nonatomic, assign) id<YTKeyBoardDelegate> delegate; //代理
@property (nonatomic, strong) SLGrowingTextView *textView; //输入框
@property (nonatomic, strong) UIButton *audioBt; //音频录制开关
@property (nonatomic, strong) UIView *bottomView; //底部各种切换控件

@property (nonatomic, strong) YTEmojiView *emojiView; //表情控制器
@property (nonatomic, strong) UIView *audioView; //录音控制器
@property (nonatomic, strong) YTMoreView *moreView;

@end

@implementation YTKeyBoardView

#define   KB_WIDTH    ([UIScreen mainScreen].bounds.size.width)
/* 小图标(录音,表情,更多)位置参数 */
#define   ICON_LR     12.0f //左右边距
#define   ICON_TOP    8.0f  //顶端边距
#define   ICON_WH     28.0f //宽高
/* textView 高度默认补充 为了显示更好看 */
#define   TOP_H       44.0f
#define   TEXT_FIT    10.0f

#pragma mark - init 初始化
- (instancetype)initDelegate:(id)delegate superView:(UIView *)superView{
    if (self = [super init]) {
        [self initUI];
        [self addNotifations];
        [self addToSuperView:superView];
        self.delegate = delegate;
    }
    return self;
}

- (void)initUI{
    [self addTopAndBottom];
    [self addIcons];
    [self addTextView];
    //[self addAudionButton];
    [self addContentView];
}

- (void)addTopAndBottom{
    UIView * top = [[UIView alloc]initWithFrame:CGRectMake( -1, 0,KB_WIDTH+2, TOP_H)];
    top.backgroundColor = [UIColor whiteColor];
    [top borderWithColor:[UIColor grayColor] borderWidth:0.5f];
    [self addSubview:top];
    self.topView = top;
    
    YTSwitcherView * bottom = [[YTSwitcherView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(top.frame), KB_WIDTH, EMOJI_VIEW_HEIGHT)];
    bottom.backgroundColor = [UIColor clearColor];
    [self addSubview:bottom];
    self.bottomView = bottom;
}

- (void)addIcons{
    UIButton *audio = [[UIButton alloc]initWithFrame:CGRectMake(ICON_LR, ICON_TOP, ICON_WH, ICON_WH)];
    audio.tag = 1;
    UIButton *emoji = [[UIButton alloc]initWithFrame:CGRectMake(KB_WIDTH-(ICON_LR+ICON_WH)*2.0f, ICON_TOP, ICON_WH, ICON_WH)];
    emoji.tag = 2;
    UIButton *more = [[UIButton alloc]initWithFrame:CGRectMake(KB_WIDTH-ICON_LR-ICON_WH, ICON_TOP, ICON_WH, ICON_WH)];
    more.tag = 3;
    
    [audio setImage:[UIImage imageNamed:@"btn_say"] forState:UIControlStateNormal];
    [emoji setImage:[UIImage imageNamed:@"btn_face"] forState:UIControlStateNormal];
    [more setImage:[UIImage imageNamed:@"btn_more"] forState:UIControlStateNormal];
    
    self.icons = @[emoji,more];// audio
    for (UIButton * bt in self.icons) {
        [bt setImage:[UIImage imageNamed:@"btn_key"] forState:UIControlStateSelected];
        [bt addTarget:self action:@selector(iconsAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:bt];
    }
    //self.audio = audio;
    self.emoji = emoji;
    self.more = more;
}

- (void)addTextView{
    SLGrowingTextView * text = [[SLGrowingTextView alloc]init];
    text.delegate = self;
    text.returnKeyType = UIReturnKeySend;
    text.enablesReturnKeyAutomatically = YES;
    text.font = [UIFont systemFontOfSize:16.0f];
    text.minNumberOfLines = 1;
    text.maxNumberOfLines = 5;
    text.backgroundColor = [UIColor whiteColor];
    [text cornerRadius:5.0f borderColor:[UIColor grayColor] borderWidth:0.5f];
    CGFloat hight = [text sizeThatFits:CGSizeMake(KB_WIDTH-ICON_WH*2.0f-ICON_LR*4.0f, CGFLOAT_MAX)].height;
    text.frame = CGRectMake(CGRectGetMaxX(self.audio.frame)+ICON_LR, ICON_TOP, KB_WIDTH-ICON_WH*2.0f-ICON_LR*4.0f, hight);
    CGFloat insetsTB = (TOP_H - ICON_TOP*2 - hight)*0.5;
    text.contentInset = UIEdgeInsetsMake(insetsTB, 2, insetsTB, 2);
    [text sizeToFit];
    [self.topView addSubview:text];
    self.textView = text;
}

- (void)addAudionButton{
    UIButton *audioBt = [[UIButton alloc]initWithFrame:self.textView.frame];
    audioBt.hidden = YES;
    audioBt.backgroundColor = [UIColor whiteColor];
    [audioBt setTitle:@"按住说话" forState:UIControlStateNormal];
    [audioBt setTitle:@"松开结束" forState:UIControlStateSelected];
    [audioBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [audioBt cornerRadius:5.0f borderColor:[UIColor grayColor] borderWidth:0.5f];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(audionRecord:)];
    [audioBt addGestureRecognizer:longPress];
    [self.topView addSubview:audioBt];
    self.audioBt = audioBt;
}

- (void)addContentView{
    //表情
    self.emojiView = [[YTEmojiView alloc]initWithDelegate:self];
    //音频
    self.audioView = [[UIView alloc]init];
    //更多
    self.moreView = [[YTMoreView alloc]initWithFrame:self.emojiView.bounds];
    self.moreView.delegate = self;
}

- (void)addNotifations{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardHiden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)addToSuperView:(UIView *)superView{
    CGFloat H = CGRectGetHeight(superView.bounds);
    CGFloat topH = self.topView.bounds.size.height;
    CGRect frame = CGRectMake(0,H-topH,KB_WIDTH, H);
    self.frame = frame;
    [superView addSubview:self];
}

#pragma mark - Key Board icons action
- (void)iconsAction:(UIButton*)sender{
    [self audionDispose:NO];
    if (sender.selected) {
        [self.textView becomeFirstResponder];
        return;
    }else{
        kb_resign = YES;
        [self.textView resignFirstResponder];
        
        for (UIButton * b in self.icons) {
            if ([b isEqual:sender]) {
                sender.selected = !sender.selected;
            }else{
                b.selected = NO;
            }
        }
        UIView * visiableView = nil;
        switch (sender.tag) {
            case 1://录音
            {
                visiableView = self.audioView;
                [self audionDispose:YES];
                break;
            }
            case 2://表情
            {
                visiableView = self.emojiView;
                text_location = self.textView.selectedRange.location;
                text_beInsert = YES;
                break;
            }
            case 3://其他+
            {
                visiableView = self.moreView;
                break;
            }
            default:
                visiableView = [[UIView alloc]init];
                break;
        }
        [self.bottomView addSubview:visiableView];
        CGRect fram = self.frame;
        fram.origin.y =[UIScreen mainScreen].bounds.size.height- (CGRectGetHeight(visiableView.frame) + self.topView.bounds.size.height);
        [self duration:DURTAION EndF:fram Options:UIViewAnimationOptionCurveLinear];
    }
}

- (void)audionDispose:(BOOL)tap{
    if (tap) {
        audio_beTap = YES;
        self.textView.hidden = YES;
        self.audioBt.hidden = NO;
        CGRect frame = self.textView.frame;
        frame.size.height = 27.0f;
        self.audioBt.frame = frame;
        frame = self.topView.frame;
        top_end_h = frame.size.height;
        frame.size.height = TOP_H;
        self.topView.frame = frame;
        frame = self.frame;
        frame.origin.y += (top_end_h - TOP_H);
        [self duration:0 EndF:frame Options:UIViewAnimationOptionCurveLinear];
    }else{
        if (audio_beTap==NO) return;
        audio_beTap = NO;
        self.textView.hidden = NO;
        self.audioBt.hidden = YES;
        CGRect frame = self.topView.frame;
        frame.size.height = top_end_h;
        self.topView.frame = frame;
        frame = self.frame;
        frame.origin.y -= (top_end_h - TOP_H);
        [self duration:0 EndF:frame Options:UIViewAnimationOptionCurveLinear];
    }
    
}

#pragma mark - 系统键盘通知事件
- (void)keyBoardHiden:(NSNotification*)noti{
    if (kb_resign==NO) {
        CGRect endF = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
        CGFloat duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
         UIViewAnimationOptions options = [[noti.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        CGRect fram = self.frame;
        fram.origin.y = (endF.origin.y - _topView.frame.size.height);
        [self duration:duration EndF:fram Options:options];
    }else{
        kb_resign = NO;
    }
}

- (void)keyBoardShow:(NSNotification*)noti{
    CGRect endF = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    if (kb_resign==NO) {
        for (UIButton * b in self.icons) {
            b.selected = NO;
        }
        [self.bottomView addSubview:[UIView new]];
        
        NSTimeInterval duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        UIViewAnimationOptions options = [[noti.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        CGRect fram = self.frame;
        fram.origin.y = (endF.origin.y - _topView.frame.size.height);
        [self duration:duration EndF:fram Options:options];
    }else{
        kb_resign = NO;
    }
}

#pragma mark - chat Emoji View Delegate
- (void)emojiViewEmoji:(YTEmoji *)emoji{
    if (!emoji.emojiCode||(emoji.emojiCode.length == 0)) {
        UIImage *image = [UIImage gifImageNamed:emoji.emojiImage];
        [self sendResous:image];
    }else{
        NSMutableAttributedString *attributeString = nil;
        NSAttributedString *attribu = nil;
        if (text_beInsert) {
            NSRange range = NSMakeRange(0, text_location);
            attributeString = [[NSMutableAttributedString alloc]initWithAttributedString:[self.textView.internalTextView.attributedText attributedSubstringFromRange:range]];
            range = NSMakeRange(text_location, self.textView.internalTextView.attributedText.length-text_location);
            attribu = [[self.textView.internalTextView.attributedText attributedSubstringFromRange:range] mutableCopy];
            text_beInsert = NO;
        }else{
            attributeString = [[NSMutableAttributedString alloc]initWithAttributedString:self.textView.internalTextView.attributedText];
        }
        
        BOOL insert = [YTTextView insertAttri:attributeString imageName:emoji.emojiImage font:self.textView.font];
        if (attribu) {
            [attributeString appendAttributedString:attribu];
        }
        if (insert) {
            self.textView.internalTextView.attributedText = attributeString;
        }
    }
}

- (void)emojiViewDelete{
    NSRange range = self.textView.selectedRange;
    NSInteger location = (NSInteger)range.location;
    if (location == 0) {
        return;
    }
    range.location = location-1;
    range.length = 1;
    
    NSMutableAttributedString *attStr = [self.textView.internalTextView.attributedText mutableCopy];
    [attStr deleteCharactersInRange:range];
    self.textView.internalTextView.attributedText = attStr;
    self.textView.selectedRange = range;
}

- (void)emojiViewSend{
    [self sendMessage];
}

#pragma mark - text View Delegate
- (BOOL)growingTextView:(SLGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(![growingTextView hasText] && [text isEqualToString:@""]) {
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    return YES;
}

- (void)growingTextView:(SLGrowingTextView *)growingTextView shouldChangeHeight:(CGFloat)height{
    CGRect frame = self.textView.frame;
    frame.size.height = height;
    [UIView animateWithDuration:DURTAION animations:^{
        self.textView.frame = frame;
        [self topLayoutSubViewWithH:(frame.size.height+ICON_TOP*2)];
    }];
}

-(void)audionRecord:(UILongPressGestureRecognizer*)longPress{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            if ([YTDeviceTest userAuthorizationAudioStatus]) {
                self.audioBt.selected = YES;
                [self.audioBt setBackgroundColor:[UIColor lightGrayColor]];
                for (UIButton * b in self.icons) {
                    b.enabled = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.audioBt.selected = NO;
            [self.audioBt setBackgroundColor:[UIColor whiteColor]];
            for (UIButton * b in self.icons) {
                b.enabled = YES;
            }
            break;
        }
        default:
            break;
    }
    [self audioRuning:longPress];
}

#pragma mark - other logic
- (void)topLayoutSubViewWithH:(CGFloat)hight{
    CGRect frame = self.topView.frame;
    CGFloat diff = hight - frame.size.height;
    frame.size.height = hight;
    self.topView.frame = frame;
    
    frame = self.bottomView.frame;
    frame.origin.y = CGRectGetHeight(self.topView.bounds);
    self.bottomView.frame = frame;
    
    frame = self.frame;
    frame.origin.y -= diff;
    
    [self duration:DURTAION EndF:frame Options:UIViewAnimationOptionCurveLinear];
}

- (void)duration:(CGFloat)duration EndF:(CGRect)endF Options:(UIViewAnimationOptions)options{
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
        kb_resign = NO;
        self.frame = endF;
    } completion:^(BOOL finished) {
        
    }];
    [self changeDuration:duration];
}

- (void)sendMessage{
    if (![self.textView hasText]&&(self.textView.text.length==0)) {
        return;
    }
    NSString *plainText = self.textView.internalTextView.clearText;
    //空格处理
    plainText = [plainText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (plainText.length > 0) {
        [self sendResous:plainText];
        self.textView.text = @"";
    }
}

#pragma mark - self public api action
- (void)tapAction{
    if (![self.textView isFirstResponder]) {
        UIButton * b = [[UIButton alloc]init];
        b.selected = NO;
        [self iconsAction:b];
    }else{
        [self.textView resignFirstResponder];
    }
}

#pragma mark - self delegate action
- (void)changeDuration:(CGFloat)duration{
    if ([self.delegate respondsToSelector:@selector(keyBoardView:ChangeDuration:)]) {
        [self.delegate keyBoardView:self ChangeDuration:duration];
    }
}

- (void)sendResous:(id)resous{
    if ([self.delegate respondsToSelector:@selector(keyBoardView:sendResous:)]) {
        [self.delegate keyBoardView:self sendResous:resous];
    }
}

- (void)audioRuning:(UILongPressGestureRecognizer*)longPress{
    if ([self.delegate respondsToSelector:@selector(keyBoardView:audioRuning:)]) {
        [self.delegate keyBoardView:self audioRuning:longPress];
    }
}

- (void)moreViewType:(YTMoreViewTypeAction)type{
    if ([self.delegate respondsToSelector:@selector(keyBoardView:otherType:)]) {
        [self.delegate keyBoardView:self otherType:type];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
