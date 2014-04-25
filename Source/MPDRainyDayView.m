/*
 * Copyright (C) 2014 Michael Dippery <michael@monkey-robot.com>
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
#import <WebKit/WebKit.h>


@implementation MPDRainDayView

+ (BOOL)performGammaFade
{
    return YES;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if ((self = [super initWithFrame:frame isPreview:isPreview])) {
        _webView = [[WebView alloc] initWithFrame:frame];
    }
    return self;
}

- (void)dealloc
{
    [_webView release];
    [super dealloc];
}

- (NSURLRequest *)request
{
    NSURL *url = [NSURL URLWithString:@"http://maroslaw.github.io/rainyday.js/demo1.html"];
    return [NSURLRequest requestWithURL:url];
}

- (void)startAnimation
{
    [self addSubview:_webView];
    [[_webView mainFrame] loadRequest:[self request]];
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
    [_webView removeFromSuperview];
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
