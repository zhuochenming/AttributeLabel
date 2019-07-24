//
//  UnderlineTextField.m
//  AttributedLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "UnderlineTextField.h"

@interface UnderlineTextField ()

@property (nonatomic, weak) UIImageView *stateImageView; // 对错

@end

static const CGFloat stateImageViewWidth = 15;
static const CGFloat stateImageViewHeight = 18;

@implementation UnderlineTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *stateImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - stateImageViewWidth, CGRectGetHeight(self.frame) - stateImageViewHeight, stateImageViewWidth, stateImageViewHeight)];
        stateImageView.contentMode = UIViewContentModeBottom;
        [self addSubview:stateImageView];
        _stateImageView = stateImageView;
    }
    return self;
}

// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //[super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 207 / 255.0, 207 / 255.0, 207 / 255.0, 1);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
}

- (void)setTextFieldState:(kUnderlineTextFieldState)textFieldState {
    _textFieldState = textFieldState;
    switch (textFieldState) {
        case kUnderlineTextFieldStateNormal:
            self.userInteractionEnabled = YES;
            _stateImageView.image = nil;
            break;
        case kUnderlineTextFieldStateCorrect:
            self.userInteractionEnabled = NO;
            _stateImageView.image = [UIImage imageNamed:@"icon_zt_dui"];
            break;
        case kUnderlineTextFieldStateError:
            self.userInteractionEnabled = NO;
            _stateImageView.image = [UIImage imageNamed:@"icon_zt_cuo"];
            break;
            
        default:
            break;
    }
}

@end
