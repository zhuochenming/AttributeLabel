//
//  UnderlineTextField.h
//  AttributedLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UnderlineTextFieldState) {
    UnderlineTextFieldStateNormal,
    UnderlineTextFieldStateCorrect,
    UnderlineTextFieldStateError,
};

@interface UnderlineTextField : UITextField

@property (nonatomic, assign) UnderlineTextFieldState textFieldState;

@end
