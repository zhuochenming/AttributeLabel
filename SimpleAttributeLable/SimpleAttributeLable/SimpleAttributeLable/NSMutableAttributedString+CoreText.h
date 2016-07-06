//
//  NSMutableAttributedString+CreText.h
//  AttributedLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface NSMutableAttributedString (CoreText)

- (void)kCTTextColor:(UIColor *)color;
- (void)kCTTextColor:(UIColor *)color range:(NSRange)range;

- (void)kCTFont:(UIFont *)font;
- (void)kCTFont:(UIFont *)font range:(NSRange)range;

- (void)kCTUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier;
- (void)kCTUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range;

@end
