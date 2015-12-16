//
//  SLGrowingTextView.m
//
//  Created by Kent on 29-06-2014
//

#import "SLGrowingTextView.h"


const NSInteger SLMinNumOfLines = 1;
const NSInteger SLMaxNumOfLines = 5;
const CGFloat SLFrameChangeDuration = 0.1;


@interface SLGrowingTextView ()

@property (nonatomic, assign) CGFloat internalTextViewSizeDelta;

// 最大和最小高度，根据行数、contentInset计算而来
@property (nonatomic, assign) int minHeight;
@property (nonatomic, assign) int maxHeight;

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation SLGrowingTextView

@synthesize backgroundView = _backgroundView;

@synthesize minNumberOfLines = _minNumberOfLines;
@synthesize maxNumberOfLines = _maxNumberOfLines;

@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize textAlignment = _textAlignment;
@synthesize selectedRange = _selectedRange;
@synthesize editable = _editable;
@synthesize dataDetectorTypes = _dataDetectorTypes;
@synthesize returnKeyType = _returnKeyType;
@synthesize contentInset = _contentInset;


- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInitialiser];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInitialiser];
    }
    return self;
}

- (void)commonInitialiser {
    self.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = UIEdgeInsetsInsetRect(self.bounds, _contentInset);
    _internalTextView = [[YTTextView alloc] initWithFrame:frame];
    _internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _internalTextView.delegate = self;
    
    _internalTextView.font = [UIFont systemFontOfSize:15.0];
    _internalTextView.backgroundColor = [UIColor clearColor];
    
    _internalTextView.showsHorizontalScrollIndicator = NO;
    _internalTextView.showsVerticalScrollIndicator = YES;
    
    _internalTextView.scrollEnabled = YES;
    
    if ([_internalTextView respondsToSelector:@selector(textContainerInset)]) {
        _internalTextView.textContainerInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        _internalTextViewSizeDelta = 0.0;
    } else {
        // iOS7之前，textView.contentInset == UIEdgeZero，但绘制文本时，
        // 却缩进了，缩进值大概为{7.0, 0.0, 7.0, 0.0}，这样文本的上下有空白，不会紧贴边框。
        // 这里取消掉，但用sizeThatFits计算size时，系统还是考虑了这个缩进，我们用sizeThatFits计算时，
        // 要去除缩进，即_internalTextViewSizeDelta的值
        // 在不同fontSize下，这个缩进值不变
        _internalTextView.contentInset = UIEdgeInsetsMake(-7.0, 0.0, -7.0, 0.0);
        _internalTextViewSizeDelta = -7.0 * 2.0;
    }
    
    [self addSubview:_internalTextView];

    [self setMinNumberOfLines:SLMinNumOfLines];
    [self setMaxNumberOfLines:SLMaxNumOfLines];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat estimateWidth = self.bounds.size.width - _contentInset.left - _contentInset.right;
    CGFloat internalTextViewHeight = [self internalTextViewSizeThatFits:CGSizeMake(estimateWidth, CGFLOAT_MAX)].height;
    internalTextViewHeight = MAX(MIN(internalTextViewHeight, _maxHeight), _minHeight);
    
    return CGSizeMake(self.bounds.size.width,
                      _contentInset.top + _contentInset.bottom + internalTextViewHeight);
}

#pragma mark - Setters & getters

- (void)setContentInset:(UIEdgeInsets)inset {
    _contentInset = inset;
    
    _internalTextView.frame = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    
    [self performSelector:@selector(textViewDidChange:) withObject:_internalTextView];
}

- (UIEdgeInsets)contentInset {
    return _contentInset;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_backgroundView atIndex:0];
    }
    return _backgroundView;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (backgroundView != _backgroundView &&
        backgroundView != nil) {
        
        if ([backgroundView superview]) {
            [backgroundView removeFromSuperview];
        }
        
        if ([_backgroundView superview]) {
            [_backgroundView removeFromSuperview];
        }
        _backgroundView = nil;
        
        _backgroundView = backgroundView;
        _backgroundView.frame = self.bounds;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self insertSubview:backgroundView atIndex:0];
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = [placeholder copy];
    if (placeholder.length) {
        self.placeholderLabel.text = placeholder;
    } else {
        self.placeholderLabel = nil;
    }
    
    [self showOrHidePlaceholder];
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5.0, 0.0)];
        _placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _placeholderLabel.font = _internalTextView.font;
        _placeholderLabel.textColor = [UIColor lightGrayColor];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        [self insertSubview:_placeholderLabel belowSubview:_internalTextView];
    }
    return _placeholderLabel;
}

- (void)setMaxNumberOfLines:(int)n {
    if (_maxNumberOfLines != n) {
        _maxHeight = [self estimateIntervalTextViewHeightWithLines:n];
        
        _maxNumberOfLines = n;
    }
}

- (void)setMinNumberOfLines:(int)m {
    if (_minNumberOfLines != m) {
        _minHeight = [self estimateIntervalTextViewHeightWithLines:m];
        
        _minNumberOfLines = m;
    }
}

#pragma mark - Instance methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_internalTextView becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return [_internalTextView canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [_internalTextView becomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
    return [_internalTextView canResignFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_internalTextView resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return [_internalTextView isFirstResponder];
}

- (BOOL)hasText{
    return [_internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range {
    [_internalTextView scrollRangeToVisible:range];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextView properties
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setText:(NSString *)newText {
    _internalTextView.text = newText;
    
    [self performSelector:@selector(textViewDidChange:) withObject:_internalTextView];
}

- (NSString *)text {
    return _internalTextView.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setFont:(UIFont *)afont {
	_internalTextView.font = afont;
    _placeholderLabel.font = afont;
	
    _maxHeight = [self estimateIntervalTextViewHeightWithLines:_maxNumberOfLines];
    _minHeight = [self estimateIntervalTextViewHeightWithLines:_minNumberOfLines];
	
    [self performSelector:@selector(textViewDidChange:) withObject:_internalTextView];
}

- (UIFont *)font {
	return _internalTextView.font;
}	

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setTextColor:(UIColor *)color {
	_internalTextView.textColor = color;
}

-(UIColor*)textColor{
	return _internalTextView.textColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
	_internalTextView.backgroundColor = backgroundColor;
}

- (UIColor*)backgroundColor {
    return _internalTextView.backgroundColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setTextAlignment:(NSTextAlignment)aligment {
	_internalTextView.textAlignment = aligment;
}

-(NSTextAlignment)textAlignment {
	return _internalTextView.textAlignment;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setSelectedRange:(NSRange)range {
	_internalTextView.selectedRange = range;
}

- (NSRange)selectedRange {
	return _internalTextView.selectedRange;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setEditable:(BOOL)beditable {
	_internalTextView.editable = beditable;
}

- (BOOL)isEditable {
	return _internalTextView.editable;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setReturnKeyType:(UIReturnKeyType)keyType {
	_internalTextView.returnKeyType = keyType;
}

- (UIReturnKeyType)returnKeyType {
	return _internalTextView.returnKeyType;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    _internalTextView.keyboardAppearance = keyboardAppearance;
}

- (UIKeyboardAppearance)keyboardAppearance {
    return _internalTextView.keyboardAppearance;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically {
    _internalTextView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
}

- (BOOL)enablesReturnKeyAutomatically {
    return _internalTextView.enablesReturnKeyAutomatically;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector {
	_internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes {
	return _internalTextView.dataDetectorTypes;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)]) {
		return [self.delegate growingTextViewShouldBeginEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)]) {
		return [self.delegate growingTextViewShouldEndEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
		[self.delegate growingTextViewDidBeginEditing:self];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self showOrHidePlaceholder];
    
	if ([self.delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
		[self.delegate growingTextViewDidEndEditing:self];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
	
	//weird 1 pixel bug when clicking backspace when textView is empty
	if (![textView hasText] && [atext isEqualToString:@""]) {
        return NO;
    }
	
	//Added by bretdabaker: sometimes we want to handle this ourselves
    if ([self.delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate growingTextView:self shouldChangeTextInRange:range replacementText:atext];
    }
	
    if ([atext isEqualToString:@"\n"]) {
		if ([self.delegate respondsToSelector:@selector(growingTextViewShouldReturn:)]) {
			if (![self.delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self]) {
				return YES;
			} else {
				[textView resignFirstResponder];
				return NO;
			}
		}
	}
    
	return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChange:(UITextView *)textView {
    // placeholder text label
    [self showOrHidePlaceholder];
    
    CGFloat needHeight = [self internalTextViewSizeThatFits:CGSizeMake(CGRectGetWidth(_internalTextView.bounds), CGFLOAT_MAX)].height;
    CGFloat internalViewNewHeight = MIN(MAX(needHeight, _minHeight), _maxHeight);
    
    CGFloat selfNewHeight = internalViewNewHeight + _contentInset.top + _contentInset.bottom;
    CGFloat currentHeight = CGRectGetHeight(self.bounds);
    if (ceilf(currentHeight) != ceilf(selfNewHeight)) {
        
        // iOS6，iOS7，iOS8下：
        // 当前文本行数小于最大行数时，如果scrollEnabled为YES，调整self的frame，
        // 文本的显示异常，插入符不在最后一行，插入符下面还有一个空白行。
        BOOL shouldUseScrollIndicators = NO;
        if (internalViewNewHeight >= _maxHeight) {
            if(!_internalTextView.scrollEnabled){
                _internalTextView.scrollEnabled = YES;
                shouldUseScrollIndicators = YES;
            }
        } else {
            if (_internalTextView.scrollEnabled) {
                _internalTextView.scrollEnabled = NO;
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(growingTextView:shouldChangeHeight:)]) {
            [self.delegate growingTextView:self shouldChangeHeight:selfNewHeight];
        }
        
        if (internalViewNewHeight >= _maxHeight) {
            // ios7下，文本高度过高时，需要设置textContainer.size，否则不能scroll，且有些文本没有绘制。
            if ([_internalTextView respondsToSelector:@selector(textContainer)]) {
                // 需要post消息调用让插入符可见。(可能是_internalTextView.scrollEnabled为NO导致)
                [self performSelector:@selector(scrollToCaretAnimated:) withObject:@YES afterDelay:SLFrameChangeDuration];
            } else {
                // 自动滑动使插入符可见。(可能是_internalTextView.scrollEnabled为NO导致)
                // iOS7前，粘贴超过maxLine的文本时，使插入符可见
                [self scrollToCaretAnimated:YES];
            }
            
            [_internalTextView flashScrollIndicators];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(growingTextViewDidChange:)]) {
        [self.delegate growingTextViewDidChange:self];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(growingTextViewDidChangeSelection:)]) {
		[self.delegate growingTextViewDidChangeSelection:self];
	}
}

#pragma mark - Private

- (void)showOrHidePlaceholder {
    self.placeholderLabel.hidden = (_internalTextView.text.length > 0);
}

- (void)scrollToCaretAnimated:(BOOL)animated {
    CGRect rect = [_internalTextView caretRectForPosition:_internalTextView.selectedTextRange.end];
    [_internalTextView scrollRectToVisible:rect animated:YES];
}

- (CGFloat)estimateIntervalTextViewHeightWithLines:(NSInteger)lineCount {
    NSString *saveText = _internalTextView.text;
    NSString *newText = @"|W|";
    
    _internalTextView.delegate = nil;
    _internalTextView.hidden = YES;
    
    for (int i = 1; i < lineCount; ++i) {
        newText = [newText stringByAppendingString:@"\n|W|"];
    }
    
    _internalTextView.text = newText;
    
    CGFloat height = [_internalTextView sizeThatFits:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)].height;
    
    _internalTextView.text = saveText;
    _internalTextView.hidden = NO;
    _internalTextView.delegate = self;
    
    return height;
}

- (CGSize)internalTextViewSizeThatFits:(CGSize)constraintSize {
    CGSize size = [_internalTextView sizeThatFits:constraintSize];
    size.height += _internalTextViewSizeDelta;
    return size;
}

@end
