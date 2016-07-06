//
//  RichTextProtocol.h
//  AttributedLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#ifndef AttributedLabel_AttributedLabelDefines_h
#define AttributedLabel_AttributedLabelDefines_h

//图片在文字中垂直方向的对齐方式
typedef NS_ENUM (NSUInteger, ImageVerticalAlignment) {
    ImageVerticalAlignmentCenter,
    ImageVerticalAlignmentTop,
    ImageVerticalAlignmentBottom
};

//图片在控件中水平方向的对齐方式
typedef NS_ENUM(NSUInteger, ImageHorizontalAlignment) {
    ImageHorizontalAlignmentCenter,
    ImageHorizontalAlignmentLeft,
    ImageHorizontalAlignmentRight
};

typedef NSArray *(^zCustomDetectLinkBlock)(NSString *text);

//如果文本长度小于这个值,直接在UI线程做Link检测,否则都dispatch到共享线程
#define M80MinAsyncDetectLinkLength 50

#define M80IOS7 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)

#endif
