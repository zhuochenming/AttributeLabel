//
//  CTView.h
//  CTView
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTViewProtocol.h"

#import "ContainerHandle.h"
#import "LinkTextHandle.h"

#import "NSMutableAttributedString+CoreText.h"

@class CTView;

@protocol CTViewDelegate <NSObject>

@optional

- (void)view:(CTView *)view tapLink:(id)linkData;

- (void)tapView:(UIView *)view;

- (void)tapImage:(UIImage *)image;

@end

@interface CTView : UIView

@property (nonatomic, weak) id<CTViewDelegate> delegate;
//普通文本
@property (nonatomic, copy) NSString *text;
//属性文本
@property (nonatomic, copy) NSAttributedString *attributedText;
//字体
@property (nonatomic, strong) UIFont *font;
//文字颜色
@property (nonatomic, strong) UIColor *textColor;

//链接是否带下划线
@property (nonatomic, assign) BOOL underLineForLink;
//链接色
@property (nonatomic, strong) UIColor *linkColor;
//链接点击时背景高亮色
@property (nonatomic, strong) UIColor *highlightColor;

//阴影颜色
@property (nonatomic, strong) UIColor *shadowColor;
//阴影offset
@property (nonatomic, assign) CGSize shadowOffset;
//阴影半径
@property (nonatomic, assign) CGFloat shadowBlur;

//自动检测
@property (nonatomic, assign) BOOL autoDetectLinks;

//设置View的高度
@property (nonatomic, assign) CGFloat viewHeight;

//行数
@property (nonatomic, assign) NSInteger numberOfLines;

//文字排版样式
@property (nonatomic, assign) CTTextAlignment textAlignment;
//LineBreakMode
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;
//行间距
@property (nonatomic, assign) CGFloat lineSpacing;
//段间距
@property (nonatomic, assign) CGFloat paragraphSpacing;

@property (nonatomic, strong, readonly) NSArray *viewArray;

//设置全局的自定义Link检测Block(详见CTViewURL)
+ (void)setCustomDetectMethod:(zCustomDetectLinkBlock)block;

//添加文本
- (void)appendText:(NSString *)text;
- (void)appendAttributedText:(NSAttributedString *)attributedText;

//图片
- (void)appendImage:(UIImage *)image size:(CGSize)size;
- (void)appendImage:(UIImage *)image size:(CGSize)size edge:(UIEdgeInsets)edge;
- (void)appendImage:(UIImage*)image size:(CGSize)size edge:(UIEdgeInsets)edge alignment:(kImageVerticalAlignment)alignment;

//UI控件
- (void)appendView:(UIView *)view;
- (void)appendView:(UIView *)view edge:(UIEdgeInsets)edge;
- (void)appendView:(UIView *)view edge:(UIEdgeInsets)edge alignment:(kImageVerticalAlignment)alignment;

//添加自定义链接
- (void)addCustomLink:(id)linkData range:(NSRange)range;
- (void)addCustomLink:(id)linkData range:(NSRange)range linkColor:(UIColor *)color;

//获取富文本的高度
- (CGFloat)getHeightWithWidth:(CGFloat)width;

@end
