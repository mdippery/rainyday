/*
 * Copyright (C) 2014-2019 Michael Dippery <michael@monkey-robot.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "MPDRainyDayView.h"
#import "NSBezierPath+RainyDay.h"
#import "NSImage+RainyDay.h"
#import "NSObject+RainyDay.h"


@implementation MPDRainDayView

+ (BOOL)performGammaFade
{
    return YES;
}


#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if ((self = [super initWithFrame:frame isPreview:isPreview])) {
        NSImage *reflectionImage = [[[self backgroundImage] flipVertically] flipHorizontally];
        [self setReflectionImage:reflectionImage];

        NSImage *blurredImage = [[self backgroundImage] gaussianBlurOfRadius:[self blurRadius]];

        CALayer *glassLayer = [CALayer layer];
        [glassLayer setDelegate:self];
        [glassLayer setFrame:frame];
        [glassLayer setContents:[NSImage transparentImageWithSize:frame.size]];

        CALayer *backgroundLayer = [CALayer layer];
        [backgroundLayer setFrame:frame];
        [backgroundLayer setContents:blurredImage];
        [backgroundLayer addSublayer:glassLayer];

        [self setWantsLayer:YES];
        [self setLayer:backgroundLayer];
    }
    return self;
}

- (void)dealloc
{
    [self setReflectionImage:nil];
    [super dealloc];
}


# pragma mark Properties

@synthesize reflectionImage;

- (CGFloat)blurRadius
{
    return 10.0;
}

- (CGFloat)frequency
{
    return 20.0;
}

- (int)maxRaindropSize
{
    return 25;
}

- (int)minRaindropSize
{
    return 10;
}

- (NSURL *)backgroundImageURL
{
    return [[self bundle] URLForImageResource:@"DefaultBackground"];
}

- (NSImage *)backgroundImage
{
    return [[NSImage imageWithContentsOfURL:[self backgroundImageURL]] resizeToFrame:[self frame]];
}

- (CALayer *)glassLayer
{
    return [[[self layer] sublayers] firstObject];
}

- (NSTimeInterval)animationTimeInterval
{
    return 60.0 / [self frequency];
}


#pragma mark Screen Saver

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow *)configureSheet
{
    return nil;
}

- (void)animateOneFrame
{
    [[self glassLayer] setNeedsDisplay];
}


#pragma mark Layer Delegate

- (void)displayLayer:(CALayer *)layer
{
    int d = SSRandomIntBetween([self minRaindropSize], [self maxRaindropSize]);
    NSPoint p = SSRandomPointForSizeWithinRect(NSMakeSize(d, d), NSRectFromCGRect([layer frame]));
    NSSize origSize = [[self backgroundImage] size];

    CGFloat scale = d / origSize.height;
    NSSize size = NSMakeSize(origSize.width * scale, origSize.height * scale);
    NSSize dropSize = NSMakeSize(d, d);
    NSRect scaledFrame = NSMakeRect(0.0, 0.0, size.width, size.height);
    NSRect squareFrame = NSMakeRect(p.x, p.y, dropSize.width, dropSize.height);

    NSImage *raindropImage = [[[self reflectionImage] resizeToFrame:scaledFrame] cropToSize:dropSize];

    /* TODO: Use NSBezierPath to draw an imperfect circle.
    NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:squareFrame];
    CAShapeLayer *mask = [CAShapeLayer layer];
    [mask setPath:[circle quartzPath]];
    */

    CALayer *raindrop = [CALayer layer];
    [raindrop setFrame:squareFrame];
    [raindrop setContents:raindropImage];
    [raindrop setCornerRadius:dropSize.width / 2.0];
    [raindrop setMasksToBounds:YES];

    [layer addSublayer:raindrop];
}

@end
