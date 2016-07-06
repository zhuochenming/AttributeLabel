//
//  LinkTextHandle.m
//  AttributedLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "LinkTextHandle.h"

static NSString * const urlExpression = @"((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[\\-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9\\.\\-]+|(?:www\\.|[\\-;:&=\\+\\$,\\w]+@)[A-Za-z0-9\\.\\-]+)((:[0-9]+)?)((?:\\/[\\+~%\\/\\.\\w\\-]*)?\\??(?:[\\-\\+=&;%@\\.\\w]*)#?(?:[\\.\\!\\/\\\\\\w]*))?)";
static zCustomDetectLinkBlock customDetectBlock = nil;

@implementation LinkTextHandle

+ (LinkTextHandle *)urlWithLinkData:(id)linkData range:(NSRange)range color:(UIColor *)color {
    LinkTextHandle *link = [[LinkTextHandle alloc] init];
    link.linkData = linkData;
    link.range = range;
    link.color = color;
    return link;
}

+ (NSArray *)detectLinks:(NSString *)plainText {
    if (customDetectBlock) {
        return customDetectBlock(plainText);
    } else {
        NSMutableArray *links = nil;
        if ([plainText length]) {
            links = [NSMutableArray array];
            NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:urlExpression options:NSRegularExpressionCaseInsensitive error:nil];
            [urlRegex enumerateMatchesInString:plainText options:0 range:NSMakeRange(0, [plainText length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
                NSRange range = result.range;
                NSString *text = [plainText substringWithRange:range];
                LinkTextHandle *link = [LinkTextHandle urlWithLinkData:text range:range color:nil];
                [links addObject:link];
            }];
        }
        return links;
    }
}

+ (void)setCustomDetectMethod:(zCustomDetectLinkBlock)block {
    customDetectBlock = [block copy];
}

@end
