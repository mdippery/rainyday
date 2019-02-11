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
        [self setBackgroundImageView:nil];
        [self setReflectionView:nil];
    }
    return self;
}

- (void)dealloc
{
    [_backgroundImageView release];
    [_reflectionView release];
    [_glassView release];
    [super dealloc];
}


# pragma mark Properties

@synthesize frame;

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

- (NSImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        NSImage *blurredImage = [[self backgroundImage] gaussianBlurOfRadius:[self blurRadius]];
        _backgroundImageView = [[NSImageView alloc] initWithFrame:[self frame]];
        [_backgroundImageView setImage:blurredImage];
    }

    return _backgroundImageView;
}

- (void)setBackgroundImageView:(NSImageView *)backgroundImageView
{
    [_backgroundImageView release];
    _backgroundImageView = [backgroundImageView retain];
}

- (NSImageView *)reflectionView
{
    if (!_reflectionView) {
        NSImage *flippedImage = [[self backgroundImage] flipVertically];
        _reflectionView = [[NSImageView alloc] initWithFrame:[self frame]];
        [_reflectionView setImage:flippedImage];
    }
    return _reflectionView;
}

- (void)setReflectionView:(NSImageView *)reflectionView
{
    [_reflectionView release];
    _reflectionView = [_reflectionView retain];
}

- (NSView *)glassView
{
    if (!_glassView) {
        _glassView = [[NSView alloc] initWithFrame:[self frame]];
        //[[_glassView layer] setOpacity:0.0];
    }
    return _glassView;
}

- (void)setGlassView:(NSView *)glassView
{
    [_glassView release];
    _glassView = [_glassView retain];
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
    [self setBackgroundImageView:nil];
    [self setReflectionView:nil];
    [self setGlassView:nil];
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
