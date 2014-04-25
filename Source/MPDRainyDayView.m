//
//  Rainy_DayView.m
//  Rainy Day
//
//  Created by Michael Dippery on 4/25/14.
//  Copyright (c) 2014 Michael Dippery. All rights reserved.
//

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
