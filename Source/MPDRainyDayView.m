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


@implementation MPDRainDayView

@synthesize frame;

+ (BOOL)performGammaFade
{
    return YES;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if ((self = [super initWithFrame:frame isPreview:isPreview])) {
        [self setFrame:frame];
        _backgroundImageView = nil;
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
        NSImageRep *sourceRep = [sourceImage bestRepresentationForRect:[self frame] context:nil hints:nil];
        NSImage *backgroundImage = [NSImage imageWithSize:[self frame].size flipped:NO drawingHandler:^BOOL(NSRect frame_) {
            return [sourceRep drawInRect:frame_];
        }];
        _backgroundImageView = [[NSImageView alloc] initWithFrame:[self frame]];
        [_backgroundImageView setImage:backgroundImage];
    }

    return _backgroundImageView;
}

- (void)blurBackground
{
}

#pragma mark Screen Saver

- (void)startAnimation
{
    NSAssert([self backgroundImageView] != nil, @"backgroundImageView is nil");
    [self blurBackground];
    [self addSubview:[self backgroundImageView]];
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
    [[self backgroundImageView] removeFromSuperview];
    [_backgroundImageView release];
    _backgroundImageView = nil;
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
