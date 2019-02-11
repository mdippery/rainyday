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
        NSImage *blurredImage = [[self backgroundImage] gaussianBlurOfRadius:[self blurRadius]];
        NSImageView *blurredView = [[NSImageView alloc] initWithFrame:[self frame]];
        [blurredView setImage:blurredImage];
        [self setBackgroundImageView:blurredView];

        NSImage *flippedImage = [[self backgroundImage] flipVertically];
        NSImageView *flippedView = [[NSImageView alloc] initWithFrame:[self frame]];
        [flippedView setImage:flippedImage];
        [self setReflectionView:flippedView];

        NSView *glassView = [[NSView alloc] initWithFrame:[self frame]];
        [self setGlassView:glassView];
    }
    return self;
}

- (void)dealloc
{
    [self setBackgroundImageView:nil];
    [self setReflectionView:nil];
    [self setGlassView:nil];
    [super dealloc];
}


# pragma mark Properties

- (CGFloat)blurRadius
{
    return 10.0;
}

- (NSURL *)backgroundImageURL
{
    return [[self bundle] URLForImageResource:@"DefaultBackground"];
}

- (NSImage *)backgroundImage
{
    return [[NSImage imageWithContentsOfURL:[self backgroundImageURL]] stretchToFrame:[self frame]];
}


#pragma mark Screen Saver

- (void)startAnimation
{
    [self addSubview:[self backgroundImageView]];
    [self addSubview:[self reflectionView]];

    [[self reflectionView] setWantsLayer:YES];
    [[self reflectionView] addSubview:[self glassView]];
    [[[self reflectionView] layer] setMask:[[self glassView] layer]];

    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];

    [[self glassView] removeFromSuperview];
    [[self backgroundImageView] removeFromSuperview];
    [[self reflectionView] removeFromSuperview];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow *)configureSheet
{
    return nil;
}

@end
