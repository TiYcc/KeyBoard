//
//  LYKeyBoardView.m
//  6park
//
//  Created by TI on 15/5/5.
//  Copyright (c) 2015年 6park. All rights reserved.
//

#import "LYKeyBoardView.h"
#import "UIView+Extensions.h"
#import "ChatEmojiView.h"
#import "KeyBoardAnimationV.h"
#import "ChatOtherIconsView.h"
#import "UIColor+Extension.h"
#import "EmoTaxtAttachment.h"
#import "EmojiObj.h"

#define   i_lf    12.0f
#define   i_top   8.0f
#define   i_w_h   28.0f
#define   Fit_Num 10.0f

#define   W_D     ([UIScreen mainScreen].bounds.size.width)
@interface LYKeyBoardView()<UITextViewDelegate,ChatEmojiViewDelegate,ChatOtherIconsViewDelegate>
{
    NSArray * icons;
    CGFloat hight_text_one;
    CGFloat end_text_hight;
    
    ChatEmojiView * _emojiView;
    UIView * _audioView;
    ChatOtherIconsView * _otherView;
    
    BOOL  keyBoardTap;
    //音频处理
    CGFloat start_TopH;
    CGFloat end_TopH;
    UIButton * audioBt;
    BOOL audioStatus;
}

@property (nonatomic,strong)UIButton * audio;
@property (nonatomic,strong)UIButton * emoji;
@property (nonatomic,strong)UIButton * other;

@property (nonatomic,strong)KeyBoardAnimationV * bottomView;
@end

@implementation LYKeyBoardView

#pragma mark - init 初始化
-(instancetype)initDelegate:(id)delegate superView:(UIView *)superView{
    if (self = [super init]) {
        [self initUI];
        [self addNotifations];
        [self addToSuperView:superView];
        self.delegate = delegate;
    }
    return self;
}

-(void)initUI{
    [self addTopAndBot];
    [self addIcons];
    [self addTextView];
    [self addAudionButton];
    [self initIconsContentView];
}

-(void)addTopAndBot{
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(-1, 0, W_D + 2, 44)];
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.layer.borderWidth = 0.7f;
    self.topView.layer.borderColor = [UIColor Grey].CGColor;
    start_TopH = _topView.frame.size.height;
    [self addSubview:self.topView];
    
    self.bottomView = [[KeyBoardAnimationV alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.topView.frame), W_D, ChatEmojiView_Hight)];
    self.bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bottomView];
}

-(void)addIcons{
    self.audio = [[UIButton alloc]initWithFrame:CGRectMake(i_lf, i_top, i_w_h, i_w_h)];
    self.audio.tag = 1;
    self.emoji = [[UIButton alloc]initWithFrame:CGRectMake(W_D-(i_lf+i_w_h)*2, i_top, i_w_h, i_w_h)];
    self.emoji.tag = 2;
    self.other = [[UIButton alloc]initWithFrame:CGRectMake(W_D-i_lf-i_w_h, i_top, i_w_h, i_w_h)];
    self.other.tag = 3;
    
    [self.audio setImage:[UIImage imageNamed:@"btn_say"] forState:UIControlStateNormal];
    [self.emoji setImage:[UIImage imageNamed:@"btn_face"] forState:UIControlStateNormal];
    [self.other setImage:[UIImage imageNamed:@"btn_chatmore"] forState:UIControlStateNormal];
    
    icons = @[self.audio,self.emoji,self.other];
    for (UIButton * b in icons) {
        [b setImage:[UIImage imageNamed:@"btn_key"] forState:UIControlStateSelected];
        [b addTarget:self action:@selector(iconsAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:b];
    }
    
}

-(void)addTextView{
    self.inputText = [[LYTextView alloc]init];
    [_inputText cornerRadius:5.0f];
    _inputText.font = [UIFont systemFontOfSize:15.0f];
    _inputText.layer.borderColor = [UIColor Grey].CGColor;
    _inputText.layer.borderWidth = 0.7f;
    _inputText.backgroundColor = [UIColor LightSmoke];
    _inputText.delegate = self;
    _inputText.returnKeyType = UIReturnKeySend;
    _inputText.enablesReturnKeyAutomatically = YES;
    _inputText.textContainerInset = UIEdgeInsetsMake(5, 0, 5, 0);
    hight_text_one = [_inputText.layoutManager usedRectForTextContainer:_inputText.textContainer].size.height;
    _inputText.frame = CGRectMake(CGRectGetMaxX(self.audio.frame)+i_lf, i_top, W_D-i_w_h*3-i_lf*5, hight_text_one+Fit_Num);
    [self.topView addSubview:self.inputText];
}

-(void)addAudionButton{
    audioBt = [[UIButton alloc]initWithFrame:_inputText.frame];
    [audioBt setTitle:@"按住说话" forState:UIControlStateNormal];
    [audioBt setTitle:@"松开结束" forState:UIControlStateSelected];
    [audioBt setTitleColor:[UIColor Grey] forState:UIControlStateNormal];
    [audioBt cornerRadius:5.0f];
    [audioBt borderWithColor:[UIColor Grey] borderWidth:0.7];
    audioBt.backgroundColor = [UIColor whiteColor];
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(audionRecord:)];
    [audioBt addGestureRecognizer:longPress];
}

-(void)initIconsContentView{
    _emojiView = [[ChatEmojiView alloc]init];
    _emojiView.delegate = self;
    
    _audioView = [[UIView alloc]init];
    _otherView = [[ChatOtherIconsView alloc]init];
    _otherView.delegate = self;
}

-(void)addNotifations{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardHiden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)addToSuperView:(UIView *)superView{
    CGFloat s_h = CGRectGetHeight(superView.bounds);
    CGRect frame = CGRectMake(0,s_h - 44,W_D, s_h);
    self.frame = frame;
    [superView addSubview:self];
}

#pragma mark - keyBoard button action
-(void)iconsAction:(UIButton*)sender{
    [self audionDispose];
    if (sender.selected) {
        [self.inputText becomeFirstResponder];
        return;
    }else{
        keyBoardTap = YES;
        [self.inputText resignFirstResponder];
    }
    for (UIButton * b in icons) {
        if ([b isEqual:sender]) {
            sender.selected = !sender.selected;
        }else{
            b.selected = NO;
        }
    }
    UIView * visiableView;
    switch (sender.tag) {
        case 1://录音
        {
            visiableView = _audioView;
            audioStatus = YES;
            end_TopH = self.topView.bounds.size.height;
            self.inputText.hidden = YES;
            CGRect frame = self.inputText.frame;
            frame.size.height = 27.0f;
            audioBt.frame = frame;
            [self.topView addSubview:audioBt];
            frame = self.topView.frame;
            frame.size.height = start_TopH;
            self.topView.frame = frame;
            frame = self.frame;
            frame.origin.y += (end_TopH - start_TopH);
            [self duration:0 EndF:frame];
        }
            break;
        case 2://表情
            visiableView = _emojiView;
            break;
        case 3://其他+
            visiableView = _otherView;
            break;
        default:
            visiableView = [[UIView alloc]init];
            break;
    }
    [self.bottomView addSubview:visiableView];
    CGRect fram = self.frame;
    fram.origin.y =[UIScreen mainScreen].bounds.size.height- (CGRectGetHeight(visiableView.frame) + self.topView.bounds.size.height);
    [self duration:DURTAION EndF:fram];
}

-(void)audionDispose{
    if (audioStatus==NO) return;
    audioStatus = NO;
    self.inputText.hidden = NO;
    [audioBt removeFromSuperview];
    CGRect frame = self.topView.frame;
    frame.size.height = end_TopH;
    self.topView.frame = frame;
    frame = self.frame;
    frame.origin.y -= (end_TopH - start_TopH);
    [self duration:0 EndF:frame];
}

#pragma mark - 系统键盘通知事件
-(void)keyBoardHiden:(NSNotification*)noti{
    if (keyBoardTap==NO) {
        CGRect endF = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
        CGFloat duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGRect fram = self.frame;
        fram.origin.y = (endF.origin.y - _topView.frame.size.height);
        [self duration:duration EndF:fram];
    }else{
        keyBoardTap = NO;
    }
}

-(void)keyBoardShow:(NSNotification*)noti{
    CGRect endF = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    if (keyBoardTap==NO) {
        for (UIButton * b in icons) {
            b.selected = NO;
        }
        [self.bottomView addSubview:[UIView new]];
        
        NSTimeInterval duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGRect fram = self.frame;
        fram.origin.y = (endF.origin.y - _topView.frame.size.height);
        [self duration:duration EndF:fram];
    }else{
        keyBoardTap = NO;
    }
}

#pragma mark - chat Emoji View Delegate
-(void)chatEmojiViewSelectEmojiIcon:(EmojiObj *)objIcon{
    EmoTaxtAttachment *attach = [[EmoTaxtAttachment alloc] initWithData:nil ofType:nil];
    attach.Top = -3.5;
    attach.image = [UIImage imageNamed:objIcon.emojiImgName];
    NSMutableAttributedString * attributeString =[[NSMutableAttributedString alloc]initWithAttributedString:self.inputText.attributedText];;
    if (attach.image && attach.image.size.width > 1.0f) {
        attach.emoName = objIcon.emojiString;
        [attributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
        
        NSRange range;
        range.location = attributeString.length - 1;
        range.length = 1;
        
        NSParagraphStyle *paragraph = [NSParagraphStyle defaultParagraphStyle];
        
        [attributeString setAttributes:@{NSAttachmentAttributeName:attach, NSFontAttributeName:self.inputText.font, NSBaselineOffsetAttributeName:[NSNumber numberWithInt:0.0], NSParagraphStyleAttributeName:paragraph} range:range];
    }
    self.inputText.attributedText = attributeString;
    [self textViewChangeText];
}

-(void)chatEmojiViewTouchUpinsideDeleteButton{
    NSRange range = self.inputText.selectedRange;
    NSInteger location = (NSInteger)range.location;
    if (location == 0) {
        return;
    }
    range.location = location-1;
    range.length = 1;
    
    NSMutableAttributedString *attStr = [self.inputText.attributedText mutableCopy];
    [attStr deleteCharactersInRange:range];
    self.inputText.attributedText = attStr;
    self.inputText.selectedRange = range;
    [self textViewChangeText];
}

-(void)chatEmojiViewTouchUpinsideSendButton{
    [self sendMessage];
}

#pragma mark - text View Delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(![textView hasText] && [text isEqualToString:@""]) {
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    [self textViewChangeText];
}

#pragma mark - audio action
-(void)audionRecord:(UILongPressGestureRecognizer*)longPress{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            switch (status) {
                case AVAuthorizationStatusNotDetermined:
                    return;
                case AVAuthorizationStatusAuthorized:
                    break;
                case AVAuthorizationStatusDenied:
                case AVAuthorizationStatusRestricted:
                {
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"无法访问麦克风" message:@"请在iPhone的“设置-隐私-麦克风”中允许访问您的麦克风" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alertView show];
                }
                    return;
                default:break;
            }
            
            audioBt.selected = YES;
            [audioBt setBackgroundColor:[UIColor LightGrey]];
            for (UIButton * b in icons) {
                b.enabled = NO;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            audioBt.selected = NO;
            [audioBt setBackgroundColor:[UIColor whiteColor]];
            for (UIButton * b in icons) {
                b.enabled = YES;
            }
        }
            break;
        default:
            break;
    }
    
    [self audioRuning:longPress];
}

#pragma mark - other logic
-(void)topLayoutSubViewWithH:(CGFloat)hight{
    CGRect frame = self.topView.frame;
    CGFloat diff = hight - frame.size.height;
    frame.size.height = hight;
    self.topView.frame = frame;
    
    frame = self.bottomView.frame;
    frame.origin.y = CGRectGetHeight(self.topView.bounds);
    self.bottomView.frame = frame;
    
    frame = self.frame;
    frame.origin.y -= diff;
    
    [self duration:DURTAION EndF:frame];
}

-(void)duration:(CGFloat)duration EndF:(CGRect)endF{
    [UIView animateWithDuration:duration animations:^{
        keyBoardTap = NO;
        self.frame = endF;
    }];
    [self changeDuration:duration];
}

-(void)sendMessage{
    if (![self.inputText hasText]&&(self.inputText.text.length==0)) {
        return;
    }
    NSString *plainText = self.inputText.plainText;
    //空格处理
    plainText = [plainText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (plainText.length > 0) {
        [self sendMessage:plainText];
        self.inputText.text = @"";
        [self textViewChangeText];
    }
}

#pragma mark - self public api action
-(void)tapAction{
    UIButton * b = [[UIButton alloc]init];
    b.selected = NO;
    [self iconsAction:b];
}

-(void)textViewChangeText{
    CGFloat h = [self.inputText.layoutManager usedRectForTextContainer:self.inputText.textContainer].size.height;
    self.inputText.contentSize = CGSizeMake(self.inputText.contentSize.width, h+Fit_Num);
    CGFloat five_h = hight_text_one*5.0f;
    h = h>five_h?five_h:h;
    CGRect frame = self.inputText.frame;
    CGFloat diff = self.topView.frame.size.height - self.inputText.frame.size.height;
    
    if (frame.size.height == h+Fit_Num) {
        CGPoint cursorPosition = [self.inputText caretRectForPosition:self.inputText.selectedTextRange.start].origin;
        if ((h == five_h) && (cursorPosition.y > five_h)) {
            CGFloat offsitY = cursorPosition.y < (self.inputText.contentSize.height - h/5.0f)?(cursorPosition.y - h/2.5):(self.inputText.contentSize.height - (h + Fit_Num));
            [self.inputText setContentOffset:CGPointMake(0, offsitY) animated:NO];
        }
        return;
    }
    
    frame.size.height = h+Fit_Num;
    self.inputText.frame = frame;
    [self topLayoutSubViewWithH:(frame.size.height+diff)];
    [self.inputText setContentOffset:CGPointZero animated:YES];
}

#pragma mark - self delegate action
-(void)changeDuration:(CGFloat)duration{
    if ([self.delegate respondsToSelector:@selector(keyBoardView:ChangeDuration:)]) {
        [self.delegate keyBoardView:self ChangeDuration:duration];
    }
}

-(void)sendMessage:(NSString*)message{
    if ([self.delegate respondsToSelector:@selector(keyBoardView:sendMessage:)]) {
        [self.delegate keyBoardView:self sendMessage:message];
    }
}

-(void)imagePickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType{
    if ([self.delegate respondsToSelector:@selector(keyBoardView:imgPicType:)]) {
        [self.delegate keyBoardView:self imgPicType:sourceType];
    }
}

-(void)audioRuning:(UILongPressGestureRecognizer*)longPress{
    if ([self.delegate respondsToSelector:@selector(keyBoardView:audioRuning:)]) {
        [self.delegate keyBoardView:self audioRuning:longPress];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
