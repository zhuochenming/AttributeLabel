//
//  NSMutableAttributedString+CoreText.m
//  CTView
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "NSMutableAttributedString+CoreText.h"

@implementation NSMutableAttributedString (CoreText)

- (void)kCTTextColor:(UIColor *)color {
    [self kCTTextColor:color range:NSMakeRange(0, self.length)];
}
- (void)kCTTextColor:(UIColor *)color range:(NSRange)range {
    if (color) {
        [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        [self addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
    }
}

- (void)kCTFont:(UIFont *)font {
    [self kCTFont:font range:NSMakeRange(0, self.length)];
}
- (void)kCTFont:(UIFont *)font range:(NSRange)range {
    if (font) {
        [self removeAttribute:(NSString *)kCTFontAttributeName range:range];
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
        if (fontRef != nil) {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}

- (void)kCTUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier {
    [self kCTUnderlineStyle:style modifier:modifier range:NSMakeRange(0, self.length)];
}
- (void)kCTUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range {
    [self removeAttribute:(NSString *)kCTUnderlineColorAttributeName range:range];
    [self addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:(style | modifier)] range:range];
}

@end
