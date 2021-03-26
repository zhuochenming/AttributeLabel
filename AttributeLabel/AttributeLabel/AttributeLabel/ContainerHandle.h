//
//  ContainerHandle.h
//  AttributeLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributeLabelProtocol.h"

@interface ContainerHandle : NSObject

//容器类型(UIView或者UIImage)
@property (nonatomic, strong) id containerType;

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) UIEdgeInsets edge;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) kImageVerticalAlignment vAlignment;

//水平方式对齐方式 （默认居中，此时edge在水平方向的值无效）
@property (nonatomic, assign) kImageHorizontalAlignment hAlignment;

@property (nonatomic, assign) CGFloat fontAscent;

@property (nonatomic, assign) CGFloat fontDescent;

+ (ContainerHandle *)container:(id)content size:(CGSize)size edge:(UIEdgeInsets)edge alignment:(kImageVerticalAlignment)alignment;

- (CGSize)containerSize;

- (NSAttributedString *)getReplacedAttributedString;

@end
