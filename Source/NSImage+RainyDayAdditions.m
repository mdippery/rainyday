/*
 * Copyright (C) 2019 Michael Dippery <michael@monkey-robot.com>
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

#import <CoreImage/CoreImage.h>
#import "NSImage+RainyDayAdditions.h"


@implementation NSImage (Convenience)

+ (NSImage *)imageWithContentsOfURL:(NSURL *)url
{
    return [[[self alloc] initWithContentsOfURL:url] autorelease];
}

@end


@implementation NSImage (Scaling)

- (NSImage *)stretchToFrame:(NSRect)frame
{
    NSImageRep *sourceRep = [self bestRepresentationForRect:frame context:nil hints:nil];
    NSImage *backgroundImage = [NSImage imageWithSize:frame.size flipped:NO drawingHandler:^BOOL(NSRect frame_) {
        return [sourceRep drawInRect:frame_];
    }];
    return backgroundImage;
}

@end


@implementation NSImage (Blur)

- (NSImage *)gaussianBlurOfRadius:(CGFloat)radius
{
    [self lockFocus];
    
    CIImage *image = [[CIImage alloc] initWithData:[self TIFFRepresentation]];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setDefaults];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    
    CIImage *output = [filter valueForKey:@"outputImage"];
    NSRect frame = NSMakeRect(0, 0, [self size].width, [self size].height);
    [output drawInRect:frame fromRect:frame operation:NSCompositeCopy fraction:1.0];
    
    [self unlockFocus];
    return self;
}

@end
