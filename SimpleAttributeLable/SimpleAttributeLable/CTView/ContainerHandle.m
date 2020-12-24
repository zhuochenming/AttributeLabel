//
//  ContainerHandle.m
//  CTView
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "ContainerHandle.h"
#import <CoreText/CoreText.h>

@implementation ContainerHandle

+ (ContainerHandle *)container:(id)content size:(CGSize)size edge:(UIEdgeInsets)edge alignment:(kImageVerticalAlignment)alignment {
    ContainerHandle *container = [[ContainerHandle alloc] init];
    container.containerType = content;
    container.edge = edge;
    container.size = size;
    container.vAlignment = alignment;
    return container;
}

- (CGSize)containerSize {
    CGSize contentSize = CGSizeZero;
    if ([_containerType isKindOfClass:[UIImage class]]) {
        UIImage *image = _containerType;
        contentSize = image.size;
        return CGSizeMake(self.size.width + _edge.left + _edge.right, self.size.height + _edge.top  + _edge.bottom);
    } else if ([_containerType isKindOfClass:[UIView class]]) {
        UIView *view = _containerType;
        contentSize = view.bounds.size;
        return CGSizeMake(contentSize.width + _edge.left + _edge.right, contentSize.height + _edge.top  + _edge.bottom);
    }
    return CGSizeZero;
}

#pragma mark - 获得置换后的string
- (NSAttributedString *)getReplacedAttributedString {
    unichar objectReplacementChar = 0xFFFC;
    NSString *objectReplacementString = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:objectReplacementString];
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    callbacks.dealloc = deallocCallback;
    
    CTRunDelegateRef delegateRef = CTRunDelegateCreate(&callbacks, (void *)self);
    NSDictionary *attDic = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)delegateRef,kCTRunDelegateAttributeName, nil];
    [attributedString setAttributes:attDic range:NSMakeRange(0, 1)];
    CFRelease(delegateRef);
    return attributedString;
}

CGFloat ascentCallback(void *ref) {
    ContainerHandle *container = (__bridge ContainerHandle *)ref;
    CGFloat ascent = 0;
    CGFloat height = [container containerSize].height;
    switch (container.vAlignment) {
        case kImageVerticalAlignmentTop:
            ascent = container.fontAscent;
            break;
        case kImageVerticalAlignmentCenter: {
            CGFloat fontAscent  = container.fontAscent;
            CGFloat fontDescent = container.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            ascent = height / 2 + baseLine;
        }
            break;
        case kImageVerticalAlignmentBottom:
            ascent = height - container.fontDescent;
            break;
        default:
            break;
    }
    return ascent;
}

CGFloat descentCallback(void *ref) {
    ContainerHandle *container = (__bridge ContainerHandle *)ref;
    CGFloat descent = 0;
    CGFloat height = [container containerSize].height;
    switch (container.vAlignment) {
        case kImageVerticalAlignmentTop: {
            descent = height - container.fontAscent;
            break;
        }
        case kImageVerticalAlignmentCenter: {
            CGFloat fontAscent = container.fontAscent;
            CGFloat fontDescent = container.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            descent = height / 2 - baseLine;
        }
            break;
        case kImageVerticalAlignmentBottom: {
            descent = container.fontDescent;
            break;
        }
        default:
            break;
    }
    return descent;
}

CGFloat widthCallback(void *ref) {
    ContainerHandle *container = (__bridge ContainerHandle *)ref;
    return [container containerSize].width;
}

void deallocCallback(void *ref) {
    
}

@end
