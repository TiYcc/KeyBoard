//
//  SLGrowingTextView.h
//
//  Created by Kent on 29-06-2014
//

@import UIKit;


extern const NSInteger SLMinNumOfLines;
extern const NSInteger SLMaxNumOfLines;
extern const CGFloat SLFrameChangeDuration;


@class SLGrowingTextView;


@protocol SLGrowingTextViewDelegate <NSObject>

@optional
- (BOOL)growingTextViewShouldBeginEditing:(SLGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(SLGrowingTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(SLGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(SLGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(SLGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(SLGrowingTextView *)growingTextView;

- (void)growingTextView:(SLGrowingTextView *)growingTextView shouldChangeHeight:(CGFloat)height;

- (void)growingTextViewDidChangeSelection:(SLGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(SLGrowingTextView *)growingTextView;
@end


/**
 * \class
 * \brief Frame自适应的textView。当用户输入时，textView会根据font和其他一些因素计算最佳的高度，
 * 通过shouldChangeHeight通知代理对象，代理对象可以修改textView的frame，由于不知道
 * 上下文，textView并不会自己修改自己的frame。代理对象可以用SLFrameChangeDuration用动画
 * 的形式修改frame。
 * 第一次创建textView的时候，用sizeThatFits计算最佳高度，并设置textView的frame。
 * 此外，textView用户可以设置最小和最大行数，行数会影响textView的最大和最小高度。
 */
#import "YTTextView.h"
@interface SLGrowingTextView : UIView <UITextViewDelegate>
	
@property (nonatomic, weak) id<SLGrowingTextViewDelegate> delegate;

/**
 * default nil, it will be created when accessed
 */
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong, readonly) YTTextView *internalTextView;

// 设置最大和最小行数
@property (nonatomic, assign) int maxNumberOfLines; // default 1
@property (nonatomic, assign) int minNumberOfLines; // default 5

@property (nonatomic, copy) NSString *placeholder; // default nil

/**
 * 内部textView的insets
 */
@property (nonatomic, assign) UIEdgeInsets contentInset;

// UITextView属性
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;    // default is UITextAlignmentLeft
@property (nonatomic, assign) NSRange selectedRange;            // only ranges of length 0 are supported
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, assign) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic, assign) UIReturnKeyType returnKeyType;
@property (nonatomic, assign) UIKeyboardAppearance keyboardAppearance;
@property (nonatomic, assign) BOOL enablesReturnKeyAutomatically;

- (BOOL)canBecomeFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)canResignFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;

@end
