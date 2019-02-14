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

#import "NSBezierPath+RainyDay.h"


typedef struct
{
    CGFloat rho;
    CGFloat phi;
}
MPDPolarPoint;


static MPDPolarPoint
MPDMakePolarPoint(CGFloat rho, CGFloat phi)
{
    MPDPolarPoint p = { rho, phi };
    return p;
}


static MPDPolarPoint
MPDRotatePolarPoint(MPDPolarPoint pt, CGFloat angle)
{
    return MPDMakePolarPoint(pt.rho, pt.phi + angle);
}


static NSPoint
MPDMakePointFromPolarPoint(MPDPolarPoint p)
{
    CGFloat x = p.rho * cos(p.phi);
    CGFloat y = p.rho * sin(p.phi);
    return NSMakePoint(x, y);
}


static NSPoint
MPDAdjustPoint(NSPoint pt, NSPoint origin)
{
    return NSMakePoint(pt.x + origin.x, pt.y + origin.y);
}


@implementation NSBezierPath (RainyDay)

+ (NSBezierPath *)imperfectCircleInRect:(NSRect)frame
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    const CGFloat radius = frame.size.width / 2.0;
    const NSPoint center = NSMakePoint(radius, radius);
    const NSPoint start = NSMakePoint(frame.size.width, center.y);

    [path moveToPoint:start];

    NSPoint current = start;
    MPDPolarPoint polar = MPDMakePolarPoint(0.0, 0.0);

    for (int i = 30; i <= 360; i += 30) {
        polar = MPDRotatePolarPoint(polar, i);
        current = MPDAdjustPoint(MPDMakePointFromPolarPoint(polar), center);
        [path lineToPoint:current];
    }

    [path lineToPoint:start];
    [path closePath];
    [path fill];

    return path;
}

- (CGPathRef)quartzPath
{
    // From: <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CocoaDrawingGuide/Paths/Paths.html#//apple_ref/doc/uid/TP40003290-CH206-SW2>

    NSInteger i, numElements;

    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;

    // Then draw the path elements.
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;

        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;

                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;

                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;

                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }

        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);

        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }

    return immutablePath;
}

@end
