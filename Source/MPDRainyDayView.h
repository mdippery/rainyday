//
//  Rainy_DayView.h
//  Rainy Day
//
//  Created by Michael Dippery on 4/25/14.
//  Copyright (c) 2014 Michael Dippery. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@class WebView;


@interface MPDRainDayView : ScreenSaverView
{
@private
    WebView *_webView;
}
@property (readonly) NSURLRequest *request;
@end
