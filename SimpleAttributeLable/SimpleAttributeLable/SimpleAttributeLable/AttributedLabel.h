//
//  AttributedLabel.h
//  AttributedLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RichTextProtocol.h"

#import "ContainerHandle.h"
#import "LinkTextHandle.h"

#import "NSMutableAttributedString+CoreText.h"

@class AttributedLabel;
@protocol AttributedLabelDelegate <NSObject>

@optional
- (void)AttributedLabel:(AttributedLabel *)label clickedOnLink:(id)linkData;

- (void)clickOnView:(UIView *)view;

- (void)clickOnImage:(UIImage *)image;

@end

@interface AttributedLabel : UIView

@property (nonatomic, weak) id<AttributedLabelDelegate> delegate;

@property (nonatomic, copy) NSString *text;                     //普通文本
@property (nonatomic, copy) NSAttributedString *attributedText; //属性文本

@property (nonatomic, strong) UIFont *font;             //字体
@property (nonatomic, strong) UIColor *textColor;       //文字颜色

@property (nonatomic, assign) BOOL underLineForLink;    //链接是否带下划线
@property (nonatomic, strong) UIColor *linkColor;       //链接色
@property (nonatomic, strong) UIColor *highlightColor;  //链接点击时背景高亮色

@property (nonatomic, strong) UIColor *shadowColor;     //阴影颜色
@property (nonatomic, assign) CGSize shadowOffset;      //阴影offset
@property (nonatomic, assign) CGFloat shadowBlur;       //阴影半径

@property (nonatomic, assign) BOOL autoDetectLinks;     //自动检测

@property (nonatomic, assign) NSInteger numberOfLines;  //行数

@property (nonatomic, assign) CTTextAlignment textAlignment;    //文字排版样式
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;    //LineBreakMode
@property (nonatomic, assign) CGFloat lineSpacing;              //行间距
@property (nonatomic, assign) CGFloat paragraphSpacing;         //段间距

@property (nonatomic, strong, readonly) NSArray *viewArray;

//添加文本
- (void)appendText:(NSString *)text;

- (void)appendAttributedText:(NSAttributedString *)attributedText;

//图片
- (void)appendImage:(UIImage *)image size:(CGSize)size;

- (void)appendImage:(UIImage *)image size:(CGSize)size margin:(UIEdgeInsets)margin;

- (void)appendImage:(UIImage*)image size:(CGSize)size margin:(UIEdgeInsets)margin alignment:(ImageVerticalAlignment)alignment;

//UI控件
- (void)appendView:(UIView *)view;

- (void)appendView:(UIView *)view margin:(UIEdgeInsets)margin;

- (void)appendView:(UIView *)view margin:(UIEdgeInsets)margin alignment:(ImageVerticalAlignment)alignment;

//添加自定义链接
- (void)addCustomLink:(id)linkData forRange:(NSRange)range;

- (void)addCustomLink:(id)linkData forRange:(NSRange)range linkColor:(UIColor *)color;

- (CGFloat)getHeightWithWidth:(CGFloat)width;

//设置全局的自定义Link检测Block(详见AttributedLabelURL)
+ (void)setCustomDetectMethod:(zCustomDetectLinkBlock)block;

@end
