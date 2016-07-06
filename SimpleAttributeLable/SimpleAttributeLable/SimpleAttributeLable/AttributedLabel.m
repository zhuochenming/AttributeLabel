//
//  AttributedLabel.m
//  AttributedLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "AttributedLabel.h"

static NSString * const kEllipsesCharacter = @"\u2026";

static dispatch_queue_t m80_attributed_label_parse_queue;

static dispatch_queue_t get_m80_attributed_label_parse_queue() {
    if (m80_attributed_label_parse_queue == NULL) {
        m80_attributed_label_parse_queue = dispatch_queue_create("com.m80.parse_queue", 0);
    }
    return m80_attributed_label_parse_queue;
}

@interface AttributedLabel ()

//容器数组
@property (nonatomic, strong) NSMutableArray *containerArray;

//链接数组
@property (nonatomic, strong) NSMutableArray *linkTextArray;

@property (nonatomic, assign) CTFrameRef frameRef;

@property (nonatomic, assign) CGFloat fontAscent;

@property (nonatomic, assign) CGFloat fontDescent;

@property (nonatomic, assign) CGFloat fontHeight;

@property (nonatomic, strong) NSMutableAttributedString *attributedString;

@property (nonatomic, strong) LinkTextHandle *touchedLink;

@property (nonatomic, assign) BOOL linkDetected;

@property (nonatomic, assign) BOOL ignoreRedraw;

@property (nonatomic, strong) NSMutableDictionary *imageRectDic;

@property (nonatomic, assign) NSInteger containerTag;

@end

@implementation AttributedLabel

#pragma mark - 初始化
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configurationProperty];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configurationProperty];
    }
    return self;
}

- (void)configurationProperty {
    _attributedString = [[NSMutableAttributedString alloc] init];
    _containerArray = [[NSMutableArray alloc] init];
    _linkTextArray = [[NSMutableArray alloc] init];
    _imageRectDic = [NSMutableDictionary dictionary];
    _frameRef = nil;
    _containerTag = 1000;
    _linkColor = [UIColor blueColor];
    _font = [UIFont systemFontOfSize:15];
    _textColor = [UIColor blackColor];
    _highlightColor = [UIColor colorWithRed:0xd7 / 255.0 green:0xf2 / 255.0 blue:0xff / 255.0 alpha:1];
    _lineBreakMode = kCTLineBreakByWordWrapping;
    _underLineForLink = YES;
    _autoDetectLinks = YES;
    _lineSpacing = 0.0;
    _paragraphSpacing = 0.0;
    
    if (self.backgroundColor == nil) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attributedLabelTap:)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
    [self resetFont];
}

#pragma mark - getter方法
- (NSString *)text {
    return [_attributedString string];
}

- (NSAttributedString *)attributedText {
    return [_attributedString copy];
}

- (NSArray *)viewArray {
    NSMutableArray *mArray = [NSMutableArray array];
    for (ContainerHandle *container in _containerArray) {
        if ([container.containerType isKindOfClass:[UIView class]]) {
            [mArray addObject:(UIView *)container.containerType];
        }
    }
    return mArray;
}

#pragma mark - setter方法
- (void)setText:(NSString *)text {
    NSAttributedString *attributedText = [self attributedString:text];
    [self setAttributedText:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    [self cleanAll];
}

- (void)setFont:(UIFont *)font {
    if (font && _font != font) {
        _font = font;
        //保证正常绘制，如果传入nil就直接不处理
        [_attributedString kCTFont:_font];
        [self resetFont];
        for (ContainerHandle *container in _containerArray) {
            container.fontAscent = _fontAscent;
            container.fontDescent = _fontDescent;
        }
        [self resetTextFrame];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor && _textColor != textColor) {
        _textColor = textColor;
        [_attributedString kCTTextColor:textColor];
        [self resetTextFrame];
    }
}

- (void)setLinkColor:(UIColor *)linkColor {
    if (_linkColor != linkColor) {
        _linkColor = linkColor;
        [self resetTextFrame];
    }
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    if (highlightColor && _highlightColor != highlightColor) {
        _highlightColor = highlightColor;
        [self resetTextFrame];
    }
}

- (void)setFrame:(CGRect)frame {
    CGRect oldRect = self.bounds;
    [super setFrame:frame];
    if (!CGRectEqualToRect(self.bounds, oldRect)) {
        [self resetTextFrame];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGRect oldRect = self.bounds;
    [super setBounds:bounds];
    if (!CGRectEqualToRect(self.bounds, oldRect)) {
        [self resetTextFrame];
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (_shadowColor != shadowColor) {
        _shadowColor = shadowColor;
        [self resetTextFrame];
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    if (!CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
        _shadowOffset = shadowOffset;
        [self resetTextFrame];
    }
}

- (void)setShadowBlur:(CGFloat)shadowBlur {
    if (shadowBlur != shadowBlur) {
        shadowBlur = shadowBlur;
        [self resetTextFrame];
    }
}

#pragma mark - 辅助方法
- (NSAttributedString *)attributedString:(NSString *)text {
    if ([text length]) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:text];
        [string kCTFont:self.font];
        [string kCTTextColor:self.textColor];
        return string;
    } else {
        return [[NSAttributedString alloc] init];
    }
}

- (NSInteger)numberOfDisplayedLines {
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    return _numberOfLines > 0 ? MIN(CFArrayGetCount(lines), _numberOfLines) : CFArrayGetCount(lines);
}

- (NSAttributedString *)attributedStringForDraw {
    if (_attributedString) {
        //添加排版格式
        NSMutableAttributedString *drawString = [_attributedString mutableCopy];
        
        //如果LineBreakMode为TranncateTail,那么默认排版模式改成kCTLineBreakByCharWrapping,使得尽可能地显示所有文字
        CTLineBreakMode lineBreakMode = self.lineBreakMode;
        if (self.lineBreakMode == kCTLineBreakByTruncatingTail) {
            lineBreakMode = _numberOfLines == 1 ? kCTLineBreakByCharWrapping : kCTLineBreakByWordWrapping;
        }
        CGFloat fontLineHeight = self.font.lineHeight;  //使用全局fontHeight作为最小lineHeight
        
        CTParagraphStyleSetting settings[] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(_textAlignment), &_textAlignment},
            {kCTParagraphStyleSpecifierLineBreakMode, sizeof(lineBreakMode), &lineBreakMode},
            {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(_lineSpacing), &_lineSpacing},
            {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(_lineSpacing), &_lineSpacing},
            {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(_paragraphSpacing), &_paragraphSpacing},
            {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(fontLineHeight), &fontLineHeight},
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings,sizeof(settings) / sizeof(settings[0]));
        [drawString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)paragraphStyle range:NSMakeRange(0, [drawString length])];
        CFRelease(paragraphStyle);
        
        for (LinkTextHandle *url in _linkTextArray) {
            if (url.range.location + url.range.length > [_attributedString length]) {
                continue;
            }
            UIColor *drawLinkColor = url.color ? : self.linkColor;
            [drawString kCTTextColor:drawLinkColor range:url.range];
            [drawString kCTUnderlineStyle:_underLineForLink ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone modifier:kCTUnderlinePatternSolid range:url.range];
        }
        return drawString;
    } else {
        return nil;
    }
}

- (LinkTextHandle *)urlForPoint:(CGPoint)point {
    static const CGFloat kVMargin = 5;
    if (!CGRectContainsPoint(CGRectInset(self.bounds, 0, -kVMargin), point) || _frameRef == nil) {
        return nil;
    }
    
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    if (!lines) {
        return nil;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0,0), origins);
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    CGFloat verticalOffset = 0;
    
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        rect = CGRectInset(rect, 0, -kVMargin);
        rect = CGRectOffset(rect, 0, verticalOffset);
        
        if (CGRectContainsPoint(rect, point)) {
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
            LinkTextHandle *url = [self linkAtIndex:idx];
            if (url) {
                return url;
            }
        }
    }
    return nil;
}

- (id)linkDataForPoint:(CGPoint)point {
    LinkTextHandle *url = [self urlForPoint:point];
    return url ? url.linkData : nil;
}

- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint) point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

- (LinkTextHandle *)linkAtIndex:(CFIndex)index {
    for (LinkTextHandle *url in _linkTextArray) {
        if (NSLocationInRange(index, url.range)) {
            return url;
        }
    }
    return nil;
}

- (CGRect)rectForRange:(NSRange)range inLine:(CTLineRef)line lineOrigin:(CGPoint)lineOrigin {
    CGRect rectForRange = CGRectZero;
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    
    for (CFIndex k = 0; k < runCount; k++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, k);
        
        CFRange stringRunRange = CTRunGetStringRange(run);
        NSRange lineRunRange = NSMakeRange(stringRunRange.location, stringRunRange.length);
        NSRange intersectedRunRange = NSIntersectionRange(lineRunRange, range);
        
        if (intersectedRunRange.length == 0) {
            continue;
        }
        
        CGFloat ascent = 0.0f;
        CGFloat descent = 0.0f;
        CGFloat leading = 0.0f;
        
        CGFloat width = (CGFloat)CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //&leading);
        CGFloat height = ascent + descent;
        
        CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
        
        CGRect linkRect = CGRectMake(lineOrigin.x + xOffset - leading, lineOrigin.y - descent, width + leading, height);
        
        linkRect.origin.y = roundf(linkRect.origin.y);
        linkRect.origin.x = roundf(linkRect.origin.x);
        linkRect.size.width = roundf(linkRect.size.width);
        linkRect.size.height = roundf(linkRect.size.height);
        
        rectForRange = CGRectIsEmpty(rectForRange) ? linkRect : CGRectUnion(rectForRange, linkRect);
    }
    
    return rectForRange;
}

- (void)appendContainer:(ContainerHandle *)container {
    container.fontAscent = _fontAscent;
    container.fontDescent = _fontDescent;
    container.tag = _containerTag;
    _containerTag++;
    [_containerArray addObject:container];
    [self appendAttributedText:[container getReplacedAttributedString]];
}

#pragma mark - 添加文本
- (void)appendText:(NSString *)text {
    NSAttributedString *attributedText = [self attributedString:text];
    [self appendAttributedText:attributedText];
}

- (void)appendAttributedText:(NSAttributedString *)attributedText {
    [_attributedString appendAttributedString:attributedText];
    [self resetTextFrame];
}

#pragma mark - 添加图片
- (void)appendImage:(UIImage *)image size:(CGSize)size {
    [self appendImage:image size:size margin:UIEdgeInsetsZero];
}

- (void)appendImage:(UIImage *)image size:(CGSize)size margin:(UIEdgeInsets)margin {
    [self appendImage:image size:size margin:margin alignment:ImageVerticalAlignmentBottom];
}

- (void)appendImage:(UIImage *)image size:(CGSize)size margin:(UIEdgeInsets)margin alignment:(ImageVerticalAlignment)alignment {
    ContainerHandle *container = [ContainerHandle container:image size:size margin:margin alignment:alignment];
    [self appendContainer:container];
}

#pragma mark - 添加UI控件
- (void)appendView:(UIView *)view {
    [self appendView:view margin:UIEdgeInsetsZero];
}

- (void)appendView:(UIView *)view margin:(UIEdgeInsets)margin {
    [self appendView:view margin:margin alignment:ImageVerticalAlignmentBottom];
}

- (void)appendView:(UIView *)view margin:(UIEdgeInsets)margin alignment:(ImageVerticalAlignment)alignment {
    ContainerHandle *container = [ContainerHandle container:view size:CGSizeZero margin:margin alignment:alignment];
    [self appendContainer:container];
}

#pragma mark - 添加链接
- (void)addCustomLink:(id)linkData forRange:(NSRange)range {
    [self addCustomLink:linkData forRange:range linkColor:self.linkColor];
}

- (void)addCustomLink:(id)linkData forRange:(NSRange)range linkColor:(UIColor *)color {
    LinkTextHandle *linkText = [LinkTextHandle urlWithLinkData:linkData range:range color:color];
    [_linkTextArray addObject:linkText];
    [self resetTextFrame];
}

#pragma mark - 计算高度
- (CGFloat)getHeightWithWidth:(CGFloat)width {
    NSAttributedString *drawString = [self attributedStringForDraw];
    if (drawString == nil) {
        return 0;
    }
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRange range = CFRangeMake(0, 0);
    if (_numberOfLines > 0 && framesetter) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, width, 0));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (lines != nil && CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN(_numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, CGSizeMake(width, 0), &fitCFRange);
    if (framesetter) {
        CFRelease(framesetter);
    }
    
    if (M80IOS7) {
        if (newSize.height < _fontHeight * 2) {
            return ceilf(newSize.height) + 4.0;
        } else {
            return ceilf(newSize.height) + 4.0;
        }
    } else {
        return ceilf(newSize.height) + 2.0;
    }
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX)];
}

#pragma mark - 绘制方法
- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == nil) {
        return;
    }
    CGContextSaveGState(ctx);
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    CGContextConcatCTM(ctx, transform);
    
    [self recomputeLinksIfNeeded];
    
    NSAttributedString *drawString = [self attributedStringForDraw];
    if (drawString) {
        [self prepareTextFrame:drawString rect:rect];
        [self drawHighlightWithRect:rect];
        [self drawContainer];
        [self drawShadow:ctx];
        [self drawText:drawString rect:rect context:ctx];
    }
    CGContextRestoreGState(ctx);
}

- (void)prepareTextFrame:(NSAttributedString *)string rect:(CGRect)rect {
    if (_frameRef == nil) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, nil,rect);
        _frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CGPathRelease(path);
        CFRelease(framesetter);
    }
}

- (void)drawHighlightWithRect:(CGRect)rect {
    if (self.touchedLink && self.highlightColor) {
        [self.highlightColor setFill];
        NSRange linkRange = self.touchedLink.range;
        
        CFArrayRef lines = CTFrameGetLines(_frameRef);
        CFIndex count = CFArrayGetCount(lines);
        CGPoint lineOrigins[count];
        CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), lineOrigins);
        NSInteger numberOfLines = [self numberOfDisplayedLines];
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        for (CFIndex i = 0; i < numberOfLines; i++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            
            CFRange stringRange = CTLineGetStringRange(line);
            NSRange lineRange = NSMakeRange(stringRange.location, stringRange.length);
            NSRange intersectedRange = NSIntersectionRange(lineRange, linkRange);
            if (intersectedRange.length == 0) {
                continue;
            }
            
            CGRect highlightRect = [self rectForRange:linkRange inLine:line lineOrigin:lineOrigins[i]];
            highlightRect = CGRectOffset(highlightRect, 0, -rect.origin.y);
            if (!CGRectIsEmpty(highlightRect)) {
                CGFloat pi = (CGFloat)M_PI;
                
                CGFloat radius = 1.0f;
                CGContextMoveToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + radius);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + highlightRect.size.height - radius);
                CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + highlightRect.size.height - radius, radius, pi, pi / 2.0f, 1.0f);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width - radius, highlightRect.origin.y + highlightRect.size.height);
                CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius, highlightRect.origin.y + highlightRect.size.height - radius, radius, pi / 2, 0.0f, 1.0f);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y + radius);
                CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius, highlightRect.origin.y + radius, radius, 0.0f, -pi / 2.0f, 1.0f);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x + radius, highlightRect.origin.y);
                CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + radius, radius, -pi / 2, pi, 1);
                CGContextFillPath(ctx);
            }
        }
    }
}

- (void)drawShadow:(CGContextRef)ctx {
    if (self.shadowColor) {
        CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
    }
}

- (void)drawText:(NSAttributedString *)attributedString rect:(CGRect)rect context:(CGContextRef)context {
    if (_frameRef) {
        if (_numberOfLines > 0) {
            CFArrayRef lines = CTFrameGetLines(_frameRef);
            NSInteger numberOfLines = [self numberOfDisplayedLines];
            
            CGPoint lineOrigins[numberOfLines];
            CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, numberOfLines), lineOrigins);
            
            for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
                CGPoint lineOrigin = lineOrigins[lineIndex];
                CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
                CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
                
                BOOL shouldDrawLine = YES;
                if (lineIndex == numberOfLines - 1 &&
                    _lineBreakMode == kCTLineBreakByTruncatingTail) {
                    //找到最后一行并检查是否需要 truncatingTail
                    CFRange lastLineRange = CTLineGetStringRange(line);
                    if (lastLineRange.location + lastLineRange.length < attributedString.length) {
                        CTLineTruncationType truncationType = kCTLineTruncationEnd;
                        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
                        
                        NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition
                                                                             effectiveRange:NULL];
                        NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:kEllipsesCharacter attributes:tokenAttributes];
                        CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                        
                        NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                        
                        if (lastLineRange.length > 0) {
                            //移除掉最后一个对象...（其实这个地方有点问题,也有可能需要移除最后 2 个对象，因为 attachment 宽度的关系）
                            [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                        }
                        [truncationString appendAttributedString:tokenString];
                        
                        CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
                        CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                        if (!truncatedLine) {
                            truncatedLine = CFRetain(truncationToken);
                        }
                        CFRelease(truncationLine);
                        CFRelease(truncationToken);
                        
                        CTLineDraw(truncatedLine, context);
                        CFRelease(truncatedLine);
                        shouldDrawLine = NO;
                    }
                }
                if(shouldDrawLine) {
                    CTLineDraw(line, context);
                }
            }
        } else {
            CTFrameDraw(_frameRef, context);
        }
    }
}

- (void)drawContainer {
    if ([_containerArray count] == 0) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == nil) {
        return;
    }
    
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), lineOrigins);
    NSInteger numberOfLines = [self numberOfDisplayedLines];
    for (CFIndex i = 0; i < numberOfLines; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat lineAscent;
        CGFloat lineDescent;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
        CGFloat lineHeight = lineAscent + lineDescent;
        CGFloat lineBottomY = lineOrigin.y - lineDescent;
        
        //遍历以找到对应的 attachment 进行绘制
        for (CFIndex k = 0; k < runCount; k++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, k);
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (nil == delegate) {
                continue;
            }
            ContainerHandle *container = (ContainerHandle *)CTRunDelegateGetRefCon(delegate);
            
            CGFloat ascent = 0.0f;
            CGFloat descent = 0.0f;
            CGFloat width = (CGFloat)CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            
            CGFloat imageBoxHeight = [container containerSize].height;
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
            
            CGFloat imageBoxOriginY = 0.0f;
            switch (container.vAlignment) {
                case ImageVerticalAlignmentTop:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight);
                    break;
                case ImageVerticalAlignmentCenter:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight) / 2.0;
                    break;
                case ImageVerticalAlignmentBottom:
                    imageBoxOriginY = lineBottomY;
                    break;
            }
            
            CGRect rect = CGRectMake(lineOrigin.x + xOffset, imageBoxOriginY, width, imageBoxHeight);
            UIEdgeInsets flippedMargins = container.margin;
            CGFloat top = flippedMargins.top;
            flippedMargins.top = flippedMargins.bottom;
            flippedMargins.bottom = top;
            
            CGRect attatchmentRect = UIEdgeInsetsInsetRect(rect, flippedMargins);
            
            if (i == numberOfLines - 1 && k >= runCount - 2 && _lineBreakMode == kCTLineBreakByTruncatingTail) {
                //最后行最后的2个CTRun需要做额外判断
                CGFloat attachmentWidth = CGRectGetWidth(attatchmentRect);
                const CGFloat kMinEllipsesWidth = attachmentWidth;
                if (CGRectGetWidth(self.bounds) - CGRectGetMinX(attatchmentRect) - attachmentWidth <  kMinEllipsesWidth) {
                    continue;
                }
            }
            
            id content = container.containerType;
            CGRect containerRect = attatchmentRect;
            
            CGFloat viewWidth = CGRectGetWidth(self.frame);
            CGFloat containerWidth = CGRectGetWidth(attatchmentRect);
            
            if ([content isKindOfClass:[UIImage class]]) {
                switch (container.hAlignment) {
                    case ImageHorizontalAlignmentCenter:
                        containerRect.origin.x = (viewWidth - containerWidth) / 2.0;
                        break;
                    case ImageHorizontalAlignmentLeft:
                        
                        break;
                    case ImageHorizontalAlignmentRight:
                        containerRect.origin.x = viewWidth - containerWidth;
                        break;
                    default:
                        containerRect.origin.x = (viewWidth - containerWidth) / 2.0;
                        break;
                }
                
                UIImage *contentImage = (UIImage *)content;
                CGContextDrawImage(ctx, containerRect, contentImage.CGImage);
                
                CGRect fixRect = containerRect;
                fixRect.origin.y = CGRectGetHeight(self.frame) - CGRectGetMaxY(containerRect);
                [self.imageRectDic setObject:@(container.tag) forKey:NSStringFromCGRect(fixRect)];
                
            } else if ([content isKindOfClass:[UIView class]]) {
                UIView *view = (UIView *)content;
                if (view.superview == nil) {
                    [self addSubview:view];
                }
                CGRect viewFrame = CGRectMake(attatchmentRect.origin.x, self.bounds.size.height - attatchmentRect.origin.y - attatchmentRect.size.height, attatchmentRect.size.width, attatchmentRect.size.height);
                [view setFrame:viewFrame];
                [self.imageRectDic setObject:@(container.tag) forKey:NSStringFromCGRect(viewFrame)];
            } else {
                NSLog(@"Attachment Content Not Supported %@",content);
            }
        }
    }
}

#pragma mark - 点击事件处理
- (BOOL)onLabelClick:(CGPoint)point {
    id linkData = [self linkDataForPoint:point];
    if (linkData) {
        if (_delegate && [_delegate respondsToSelector:@selector(AttributedLabel:clickedOnLink:)]) {
            [_delegate AttributedLabel:self clickedOnLink:linkData];
        } else {
            NSURL *url = nil;
            if ([linkData isKindOfClass:[NSString class]]) {
                url = [NSURL URLWithString:linkData];
            } else if ([linkData isKindOfClass:[NSURL class]]) {
                url = linkData;
            }
            if (url) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark - 链接处理
- (void)recomputeLinksIfNeeded {
    const NSInteger kMinHttpLinkLength = 5;
    if (!_autoDetectLinks || _linkDetected) {
        return;
    }
    NSString *text = [[_attributedString string] copy];
    NSUInteger length = [text length];
    if (length <= kMinHttpLinkLength) {
        return;
    }
    BOOL sync = length <= M80MinAsyncDetectLinkLength;
    [self computeLink:text sync:sync];
}

- (void)computeLink:(NSString *)text sync:(BOOL)sync {
    __weak typeof(self) weakSelf = self;
    typedef void (^LinkBlock) (NSArray *);
    LinkBlock block = ^(NSArray *links) {
        weakSelf.linkDetected = YES;
        if ([links count]) {
            for (LinkTextHandle *link in links) {
                [weakSelf addAutoDetectedLink:link];
            }
            [weakSelf resetTextFrame];
        }
    };
    
    if (sync) {
        _ignoreRedraw = YES;
        NSArray *links = [LinkTextHandle detectLinks:text];
        block(links);
        _ignoreRedraw = NO;
    } else {
        dispatch_sync(get_m80_attributed_label_parse_queue(), ^{
            NSArray *links = [LinkTextHandle detectLinks:text];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *plainText = [[weakSelf attributedString] string];
                if ([plainText isEqualToString:text]) {
                    block(links);
                }
            });
        });
    }
}

- (void)addAutoDetectedLink:(LinkTextHandle *)link {
    NSRange range = link.range;
    for (LinkTextHandle *url in _linkTextArray) {
        if (NSIntersectionRange(range, url.range).length != 0) {
            return;
        }
    }
    [self addCustomLink:link.linkData forRange:link.range];
}

#pragma mark - 点击事件相应
- (void)attributedLabelTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    LinkTextHandle *linkText = [self urlForPoint:point];
    if (linkText == nil) {
        for (NSString *rectString in _imageRectDic.allKeys) {
            CGRect rect = CGRectFromString(rectString);
            BOOL contains = CGRectContainsPoint(rect, point);
            if (contains) {
                
                BOOL isResonseImageTap = NO;
                
                if ([self.delegate respondsToSelector:@selector(clickOnImage:)]) {
                    for (ContainerHandle *container in _containerArray) {
                        if (container.tag == [_imageRectDic[rectString] integerValue] && [container.containerType isKindOfClass:[UIImage class]]) {
                            [self.delegate clickOnImage:(UIImage *)container.containerType];
                            isResonseImageTap = YES;
                            break;
                        }
                    }
                }
                if (!isResonseImageTap) {
                    if ([self.delegate respondsToSelector:@selector(clickOnView:)]) {
                        for (ContainerHandle *container in _containerArray) {
                            if (container.tag == [_imageRectDic[rectString] integerValue] && [container.containerType isKindOfClass:[UIView class]]) {
                                [self.delegate clickOnView:container.containerType];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchedLink == nil) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        self.touchedLink = [self urlForPoint:point];
    }
    
    if (self.touchedLink) {
        [self setNeedsDisplay];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    LinkTextHandle *touchedLink = [self urlForPoint:point];
    if (self.touchedLink != touchedLink) {
        self.touchedLink = touchedLink;
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.touchedLink) {
        self.touchedLink = nil;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if(![self onLabelClick:point]) {
        [super touchesEnded:touches withEvent:event];
    }
    if (self.touchedLink) {
        self.touchedLink = nil;
        [self setNeedsDisplay];
    }
}

#pragma mark - 设置自定义的连接检测block
+ (void)setCustomDetectMethod:(zCustomDetectLinkBlock)block {
    [LinkTextHandle setCustomDetectMethod:block];
}

#pragma mark - 重置和销毁
- (void)cleanAll {
    _ignoreRedraw = NO;
    _linkDetected = NO;
    [_containerArray removeAllObjects];
    [_linkTextArray removeAllObjects];
    self.touchedLink = nil;
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self resetTextFrame];
}

- (void)resetTextFrame {
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
    if ([NSThread isMainThread] && !_ignoreRedraw) {
        [self setNeedsDisplay];
    }
}

- (void)resetFont {
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    if (fontRef) {
        _fontAscent = CTFontGetAscent(fontRef);
        _fontDescent = CTFontGetDescent(fontRef);
        _fontHeight = CTFontGetSize(fontRef);
        CFRelease(fontRef);
    }
}

- (void)dealloc {
    if (_frameRef) {
        CFRelease(_frameRef);
    }
}

@end
