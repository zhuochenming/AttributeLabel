//
//  NSMutableAttributedString+CreText.h
//  AttributeLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface NSMutableAttributedString (CoreText)

/** 改变文本的颜色 */
- (void)kCTTextColor:(UIColor *)color;
- (void)kCTTextColor:(UIColor *)color range:(NSRange)range;

/** 改变文本的字体 */
- (void)kCTFont:(UIFont *)font;
- (void)kCTFont:(UIFont *)font range:(NSRange)range;

/** 改变文本的下划线 */
- (void)kCTUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier;
- (void)kCTUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range;

@end
