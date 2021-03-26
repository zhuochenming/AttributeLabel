//
//  LinkTextHandle.h
//  AttributeLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributeLabelProtocol.h"

@interface LinkTextHandle : NSObject

@property (nonatomic, strong) id linkData;

@property (nonatomic, assign) NSRange range;

@property (nonatomic, strong) UIColor *color;

+ (LinkTextHandle *)urlWithLinkData:(id)linkData range:(NSRange)range color:(UIColor *)color;

+ (NSArray *)detectLinks:(NSString *)plainText;

+ (void)setCustomDetectMethod:(zCustomDetectLinkBlock)block;

@end
