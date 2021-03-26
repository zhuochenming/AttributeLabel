//
//  RichTextProtocol.h
//  AttributeLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#ifndef AttributeLabel_AttributeLabelDefines_h
#define AttributeLabel_AttributeLabelDefines_h

//图片在文字中垂直方向的对齐方式
typedef NS_ENUM (NSUInteger, kImageVerticalAlignment) {
    kImageVerticalAlignmentCenter,
    kImageVerticalAlignmentTop,
    kImageVerticalAlignmentBottom
};

//图片在控件中水平方向的对齐方式
typedef NS_ENUM(NSUInteger, kImageHorizontalAlignment) {
    kImageHorizontalAlignmentCenter,
    kImageHorizontalAlignmentLeft,
    kImageHorizontalAlignmentRight
};

typedef NSArray *(^zCustomDetectLinkBlock)(NSString *text);

//如果文本长度小于这个值,直接在UI线程做Link检测,否则都dispatch到共享线程
static CGFloat kM80MinAsyncDetectLinkLength = 50.0;

#define M80IOS7 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)

#endif
