//
//  UnderlineTextField.h
//  AttributeLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, kUnderlineTextFieldState) {
    kUnderlineTextFieldStateNormal,
    kUnderlineTextFieldStateCorrect,
    kUnderlineTextFieldStateError,
};

@interface UnderlineTextField : UITextField

@property (nonatomic, assign) kUnderlineTextFieldState textFieldState;

@end
