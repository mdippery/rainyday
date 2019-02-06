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
#import "NSImage+RainyDayAdditions.h"


@implementation MPDRainDayView

@synthesize frame;

+ (BOOL)performGammaFade
{
    return YES;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if ((self = [super initWithFrame:frame isPreview:isPreview])) {
        [self setBackgroundImageView:nil];
    }
    return self;
}

- (void)dealloc
{
    [_backgroundImageView release];
    [super dealloc];
}

- (NSImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        NSLog(@"Loading background image");
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *url = [bundle URLForImageResource:@"DefaultBackground"];
        NSImage *sourceImage = [[[NSImage alloc] initWithContentsOfURL:url] autorelease];
        NSImage *backgroundImage = [sourceImage stretchToFrame:[self frame]];
        NSLog(@"Stretched frame: %@", NSStringFromRect([self frame]));
        NSImage *blurredImage = [backgroundImage gaussianBlurOfRadius:[self blurRadius]];
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

- (CGFloat)blurRadius
{
    return 10.0;
}

#pragma mark Screen Saver

- (void)startAnimation
{
    [self addSubview:[self backgroundImageView]];
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
    [[self backgroundImageView] removeFromSuperview];
    [self setBackgroundImageView:nil];
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
