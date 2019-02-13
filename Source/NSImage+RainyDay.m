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
#import <ScreenSaver/ScreenSaver.h>
#import "NSImage+RainyDay.h"


@interface NSImage (RainyDay)
- (NSImage *)flipWithMatrix:(NSAffineTransformStruct)matrix;
@end


@implementation NSImage (Convenience)

+ (NSImage *)imageWithContentsOfURL:(NSURL *)url
{
    return [[[self alloc] initWithContentsOfURL:url] autorelease];
}

+ (NSImage *)imageWithSize:(NSSize)size
{
    return [[[self alloc] initWithSize:size] autorelease];
}

+ (NSImage *)transparentImageWithSize:(NSSize)size
{
    return [NSImage imageWithSize:size flipped:YES drawingHandler:^BOOL(NSRect frame) {
        [[NSColor clearColor] set];
        NSRectFill(frame);
        return YES;
    }];
}

@end


@implementation NSImage (Transform)

- (NSImage *)resizeToFrame:(NSRect)frame
{
    // See: https://gist.github.com/raphaelhanneken/cb924aa280f4b9dbb480

    NSImageRep *sourceRep = [self bestRepresentationForRect:frame context:nil hints:nil];
    NSImage *image = [NSImage imageWithSize:frame.size flipped:NO drawingHandler:^BOOL(NSRect frame_) {
        return [sourceRep drawInRect:frame_];
    }];
    return image;
}

- (NSImage *)cropToSize:(NSSize)size
{
    CGFloat maxX = [self size].width - size.width;
    CGFloat maxY = [self size].height - size.height;

    CGFloat x = SSRandomFloatBetween(0.0, maxX);
    CGFloat y = SSRandomFloatBetween(0.0, maxY);
    NSRect frame = NSMakeRect(x, y, size.width, size.height);

    NSImage *image = [NSImage imageWithSize:size];

    [image lockFocus];
    {
        [self drawInRect:NSMakeRect(0.0, 0.0, size.width, size.height)
                fromRect:frame
               operation:NSCompositingOperationCopy
                fraction:1.0];
    }
    [image unlockFocus];

    return image;
}

- (NSImage *)gaussianBlurOfRadius:(CGFloat)radius
{
    // See: https://gist.github.com/TomLiu/7635912

    NSImage *image = [NSImage imageWithSize:[self size]];

    [image lockFocus];
    {
        CIImage *sourceImage = [CIImage imageWithData:[self TIFFRepresentation]];

        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [filter setDefaults];
        [filter setValue:sourceImage forKey:kCIInputImageKey];
        [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];

        CIImage *output = [filter valueForKey:@"outputImage"];
        NSRect frame = NSMakeRect(0.0, 0.0, [self size].width, [self size].height);
        [output drawInRect:frame fromRect:frame operation:NSCompositingOperationCopy fraction:1.0];
    }
    [image unlockFocus];

    return image;
}

- (NSImage *)flipVertically
{
    NSAffineTransformStruct matrix = { 1.0, 0.0, 0.0, -1.0, 0.0, [self size].height };
    return [self flipWithMatrix:matrix];
}

- (NSImage *)flipHorizontally
{
    NSAffineTransformStruct matrix = { -1.0, 0.0, 0.0, 1.0, [self size].width, 0.0 };
    return [self flipWithMatrix:matrix];
}

@end


@implementation NSImage (RainyDay)

- (NSImage *)flipWithMatrix:(NSAffineTransformStruct)matrix
{
    // See: https://stackoverflow.com/a/36451059/28804

    NSImage *image = [[NSImage alloc] initWithSize:[self size]];
    NSRect frame = NSMakeRect(0.0, 0.0, [self size].width, [self size].height);
    NSAffineTransform *transform = [NSAffineTransform transform];

    [image lockFocus];
    {
        [transform setTransformStruct:matrix];
        [transform concat];
        [self drawAtPoint:NSZeroPoint fromRect:frame operation:NSCompositingOperationCopy fraction:1.0];
    }
    [image unlockFocus];

    return [image autorelease];
}

@end
