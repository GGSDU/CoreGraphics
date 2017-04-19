//
//  RulerCalculator.m
//  OpenCVDetectCircleDemo
//
//  Created by Story5 on 3/27/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import "JavaRulerCalculator.h"
#import <Foundation/Foundation.h>

@interface JavaRulerCalculator ()



@property (nonatomic,assign) CGFloat kTouchPoint;
@property (nonatomic,assign) CGFloat kRulerLine;
@property (nonatomic,assign) CGFloat bTouchPoint;
@property (nonatomic,assign) CGFloat bRulerLine1;
@property (nonatomic,assign) CGFloat bRulerLine2;
@property (nonatomic,assign) CGFloat bRuler1;
@property (nonatomic,assign) CGFloat bRuler2;
@property (nonatomic,assign) CGFloat bRuler3; // 1/2



@end


@implementation JavaRulerCalculator
- (instancetype)initWithWidth:(int)width height:(int)height rulerWidth:(float)rulerWidth rulerScaleWidth:(float)rulerScaleWidth measureIconSize:(float)measureIconSize
{
    self = [super init];
    if (self) {
        self.width = width;
        self.height = height;
        self.rulerWidth = rulerWidth;
        self.rulerScaleWidth = rulerScaleWidth;
        self.measureIconSize = measureIconSize;
    }
    return self;
}

#pragma mark -
- (void)calculateRulerLineInfo:(CGPoint)btn1 btn2:(CGPoint)btn2
{
    self.kTouchPoint = (float)(btn1.y - btn2.y) / (float) (btn1.x - btn2.x);
    self.kRulerLine = -(1 / self.kTouchPoint);
    self.bRulerLine1 = btn1.y - self.kRulerLine * btn1.x;
    self.bRulerLine2 = btn2.y - self.kRulerLine * btn2.x;
    self.bTouchPoint = btn1.y - self.kTouchPoint * btn1.x;
}

- (CGPoint)getPointByX:(float)k b:(float)b x:(float)x
{
    return CGPointMake((int) x, (int) (k * x + b));
}

- (CGPoint)getPointByY:(float)k b:(float)b y:(float)y
{
    return CGPointMake((int) ((y - b) / k), (int) y);
}

- (CGPoint)recalculateRuler:(CGPoint)pt k:(float)k b:(float)b
{
    if (pt.x == 0 && pt.y < 0) {
        pt = [self getPointByY:k b:b y:0];
    } else if (pt.x == self.width && pt.y > self.height) {
        pt = [self getPointByY:k b:b y:self.height];
    } else if (pt.x == self.width && pt.y < 0) {
        pt = [self getPointByY:k b:b y:0];
    } else if (pt.x == 0 && pt.y > self.height) {
        pt = [self getPointByY:k b:b y:self.height];
    }
    
    return pt;
}

- (NSArray *)calculateRulerLine:(CGPoint)btn1 btn2:(CGPoint)btn2 k2:(float)k2 b1:(float)b1 b2:(float)b2
{
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:0];
    if (btn1.y - btn2.y == 0) {
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(btn1.x, 0)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(btn1.x, self.height)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(btn2.x, 0)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(btn2.x, self.height)]];
    } else if (btn1.x - btn2.x == 0) {
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, btn1.y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(self.width, btn1.y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, btn2.y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(self.width, btn2.y)]];
    } else {
        
        CGPoint point10 = [self getPointByX:k2 b:b1 x:0];
        CGPoint point20 = [self getPointByX:k2 b:b1 x:self.width];
        CGPoint point30 = [self getPointByX:k2 b:b2 x:0];
        CGPoint point40 = [self getPointByX:k2 b:b2 x:self.width];
        
        CGPoint point1 = [self recalculateRuler:point10 k:k2 b:b1];
        CGPoint point2 = [self recalculateRuler:point20 k:k2 b:b1];
        CGPoint point3 = [self recalculateRuler:point30 k:k2 b:b2];
        CGPoint point4 = [self recalculateRuler:point40 k:k2 b:b2];;
        
        [points addObject:[NSValue valueWithCGPoint:point1]];
        [points addObject:[NSValue valueWithCGPoint:point2]];
        [points addObject:[NSValue valueWithCGPoint:point3]];
        [points addObject:[NSValue valueWithCGPoint:point4]];
    }
    return points;
}

- (NSArray *)calculateRulerBasePoint:(CGPoint)btn1 bt2:(CGPoint)btn2 k:(float)k b1:(float)b1 b2:(float)b2
{
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:0];
    if (btn1.y - btn2.y == 0) {
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(btn1.x, (int) (btn1.y - self.rulerWidth / 2))]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(btn1.x, (int) (btn1.y + self.rulerWidth / 2))]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(btn2.x, (int) (btn2.y - self.rulerWidth / 2))]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(btn2.x, (int) (btn2.y + self.rulerWidth / 2))]];
        
    } else if (btn1.x - btn2.x == 0) {
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake((int) (btn1.x - self.rulerWidth / 2), btn1.y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake((int) (btn1.x + self.rulerWidth / 2), btn1.y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake((int) (btn2.x - self.rulerWidth / 2), btn2.y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake((int) (btn2.x + self.rulerWidth / 2), btn2.y)]];
        
    } else {
        double angle = atanf(k) * 180 / M_PI;
        if (-1 < -1 / k && -1 / k < 1) {
            float linear_a = (float) (powf(1 / k, 2) + 1);
            float linear_b = (float) -(2 * btn1.x / k + 2 * b1 / powf(k, 2) + 2 * btn1.y);
            float linear_c = (float) (powf(btn1.x, 2) + powf(btn1.y, 2) +
                                      powf(b1 / k, 2) + 2 * b1 * btn1.x / k - powf(self.rulerWidth / 2.0, 2));
            
            int y1 = (int) ((-linear_b - sqrtf((powf(linear_b, 2) -
                                                    4 * linear_a * linear_c))) / (2 * linear_a));
            int y2 = (int) ((-linear_b + sqrtf((powf(linear_b, 2) -
                                                    4 * linear_a * linear_c))) / (2 * linear_a));
            
            CGPoint pt1 = CGPointZero;
            CGPoint pt2 = CGPointZero;
            
            if (btn1.x < btn2.x &&
                ((-90 < angle && angle < -45) || (45 < angle && angle < 90))) {
                pt1.y = y2;
                pt2.y = y1;
            } else {
                pt1.y = y1;
                pt2.y = y2;
            }
            
            pt1.x = (int) ((pt1.y - b1) / k);
            pt2.x = (int) ((pt2.y - b1) / k);
            
            linear_a = (float) (powf(1 / k, 2) + 1);
            linear_b = (float) -(2 * btn2.x / k + 2 * b2 / powf(k, 2) + 2 * btn2.y);
            linear_c = (float) (powf(btn2.x, 2) + powf(btn2.y, 2) +
                                powf(b2 / k, 2) + 2 * b2 * btn2.x / k - powf(self.rulerWidth / 2.0, 2));
            
            y1 = (int) ((-linear_b - sqrtf((powf(linear_b, 2) -
                                                4 * linear_a * linear_c))) / (2 * linear_a));
            y2 = (int) ((-linear_b + sqrtf((powf(linear_b, 2) -
                                                4 * linear_a * linear_c))) / (2 * linear_a));
            
            CGPoint pt3 = CGPointZero;
            CGPoint pt4 = CGPointZero;
            
            if (btn1.x < btn2.x &&
                ((-90 < angle && angle < -45) || (45 < angle && angle < 90))) {
                pt3.y = y2;
                pt4.y = y1;
            } else {
                pt3.y = y1;
                pt4.y = y2;
            }
            
            pt3.x = (int) ((pt3.y - b2) / k);
            pt4.x = (int) ((pt4.y - b2) / k);
            
            [points addObject:[NSValue valueWithCGPoint:pt1]];
            [points addObject:[NSValue valueWithCGPoint:pt2]];
            [points addObject:[NSValue valueWithCGPoint:pt3]];
            [points addObject:[NSValue valueWithCGPoint:pt4]];
        } else {
            float linear_a = (float) (powf(k, 2) + 1);
            float linear_b = 2 * k * b1 - 2 * btn1.x - 2 * k * btn1.y;
            float linear_c = (float) (powf(btn1.x, 2) + powf(b1, 2) - 2 * b1 * btn1.y +
                                      powf(btn1.y, 2) - powf(self.rulerWidth / 2.0, 2));
            
            int x1 = (int) ((-linear_b - sqrtf((powf(linear_b, 2) -
                                                4 * linear_a * linear_c))) / (2 * linear_a));
            int x2 = (int) ((-linear_b + sqrtf((powf(linear_b, 2) -
                                                4 * linear_a * linear_c))) / (2 * linear_a));
            CGPoint pt1 = CGPointZero;
            CGPoint pt2 = CGPointZero;
            if ((btn1.x > btn2.x && -45 < angle && angle < 0) ||
                (btn1.x < btn2.x && 0 < angle && angle < 45)) {
                pt1.x = x2;
                pt2.x = x1;
            } else {
                pt1.x = x1;
                pt2.x = x2;
            }
            pt1.y = (int) (k * pt1.x + b1);
            pt2.y = (int) (k * pt2.x + b1);
            
            linear_a = (float) (powf(k, 2) + 1);
            linear_b = 2 * k * b2 - 2 * btn2.x - 2 * k * btn2.y;
            linear_c = (float) (powf(btn2.x, 2) + powf(b2, 2) - 2 * b2 * btn2.y +
                                powf(btn2.y, 2) - powf(self.rulerWidth / 2.0, 2));
            
            x1 = (int) ((-linear_b - sqrtf((powf(linear_b, 2) -
                                            4 * linear_a * linear_c))) / (2 * linear_a));
            x2 = (int) ((-linear_b + sqrtf((powf(linear_b, 2) -
                                            4 * linear_a * linear_c))) / (2 * linear_a));
            CGPoint pt3 = CGPointZero;
            CGPoint pt4 = CGPointZero;
            if ((btn1.x > btn2.x && -45 < angle && angle < 0) ||
                (btn1.x < btn2.x && 0 < angle && angle < 45)) {
                pt3.x = x2;
                pt4.x = x1;
            } else {
                pt3.x = x1;
                pt4.x = x2;
            }
            pt3.y = (int) (k * pt3.x + b2);
            pt4.y = (int) (k * pt4.x + b2);
            
            [points addObject:[NSValue valueWithCGPoint:pt1]];
            [points addObject:[NSValue valueWithCGPoint:pt2]];
            [points addObject:[NSValue valueWithCGPoint:pt3]];
            [points addObject:[NSValue valueWithCGPoint:pt4]];
        }
    }
    return points;
}

- (void)calculateRulerInfo:(NSArray *)rulerPoints btn1:(CGPoint)btn1 k:(float)k
{
    if (rulerPoints != nil && rulerPoints.count == 4) {
        NSValue *value1 = rulerPoints[0];
        NSValue *value2 = rulerPoints[1];
        CGPoint point0 = value1.CGPointValue;
        CGPoint point1 = value2.CGPointValue;
        
        self.bRuler1 = point0.y - k * point0.x;
        self.bRuler2 = point1.y - k * point1.x;
        self.bRuler3 = btn1.y - k * btn1.x;
    } else {
        self.bRuler1 = MAXFLOAT;
        self.bRuler2 = MAXFLOAT;
        self.bRuler3 = MAXFLOAT;
    }
}

- (double)distance:(CGPoint)pt1 pt2:(CGPoint)pt2
{
    return sqrtf(powf(pt1.x - pt2.x, 2) + powf(pt1.y - pt2.y, 2));
}

- (CGPoint)calculateRulerScalePoint:(CGPoint)btn1 btn2:(CGPoint)btn2 basePt:(CGPoint)basePt k:(float)k b:(float)b distance:(float)distance reverse:(BOOL)reverse
{
    CGPoint finalPoint = CGPointZero;
    if (btn1.y - btn2.y == 0) {
        if (btn1.x > btn2.x) {
            if (reverse) {
                finalPoint.x = (int) (basePt.x + distance);
            } else {
                finalPoint.x = (int) (basePt.x - distance);
            }
        } else {
            if (reverse) {
                finalPoint.x = (int) (basePt.x - distance);
            } else {
                finalPoint.x = (int) (basePt.x + distance);
            }
        }
        finalPoint.y = basePt.y;
    } else if (btn1.x - btn2.x == 0) {
        finalPoint.x = basePt.x;
        if (btn1.y > btn2.y) {
            if (reverse) {
                finalPoint.y = (int) (basePt.y + distance);
            } else {
                finalPoint.y = (int) (basePt.y - distance);
            }
        } else {
            if (reverse) {
                finalPoint.y = (int) (basePt.y - distance);
            } else {
                finalPoint.y = (int) (basePt.y + distance);
            }
        }
    } else {
        float angle = atanf(k) * 180 / M_PI;
        if (-1 < k && k < 1) {
            float linear_a = (float) (powf(k, 2) + 1);
            float linear_b = 2 * k * b - 2 * basePt.x - 2 * k * basePt.y;
            float linear_c = (float) (powf(basePt.x, 2) + powf(b, 2) - 2 * b * basePt.y +
                                      powf(basePt.y, 2) - powf(distance, 2));
            
            int x1 = (int) ((-linear_b - sqrtf((powf(linear_b, 2) -
                                                4 * linear_a * linear_c))) / (2 * linear_a));
            int x2 = (int) ((-linear_b + sqrtf((powf(linear_b, 2) -
                                                4 * linear_a * linear_c))) / (2 * linear_a));
            if (btn1.x < btn2.x && -45 < angle && angle < 45) {
                if (reverse) {
                    finalPoint.x = x1;
                } else {
                    finalPoint.x = x2;
                }
            } else {
                if (reverse) {
                    finalPoint.x = x2;
                } else {
                    finalPoint.x = x1;
                }
            }
            finalPoint.y = (int) (k * finalPoint.x + b);
        } else {
            float linear_a = (float) (powf(1 / k, 2) + 1);
            float linear_b = (float) -(2 * basePt.x / k + 2 * b / powf(k, 2) + 2 * basePt.y);
            float linear_c = (float) (powf(basePt.x, 2) + powf(basePt.y, 2) +
                                      powf(b / k, 2) + 2 * b * basePt.x / k - powf(distance, 2));
            
            int y1 = (int) ((-linear_b - sqrtf((powf(linear_b, 2)
                                                - 4 * linear_a * linear_c))) / (2 * linear_a));
            int y2 = (int) ((-linear_b + sqrtf((powf(linear_b, 2)
                                                - 4 * linear_a * linear_c))) / (2 * linear_a));
            if ((btn1.x > btn2.x && -90 < angle && angle <= -45) ||
                (btn1.x < btn2.x && 45 <= angle && angle < 90)) {
                if (reverse) {
                    finalPoint.y = y1;
                } else {
                    finalPoint.y = y2;
                }
            } else {
                if (reverse) {
                    finalPoint.y = y2;
                } else {
                    finalPoint.y = y1;
                }
            }
            finalPoint.x = (int) ((finalPoint.y - b) / k);
        }
    }
    
    return finalPoint;
}

- (CGPoint)calculateRulerScalePoint:(CGPoint)btn1 btn2:(CGPoint)btn2 basePt:(CGPoint)basePt k:(float)k b:(float)b distance:(float)distance
{
    return [self calculateRulerScalePoint:btn1 btn2:btn2 basePt:basePt k:k b:b distance:distance reverse:false];
}

- (NSArray *)calculateBottomRulerScalePoints:(CGPoint)btn1 btn2:(CGPoint)btn2 basePt:(CGPoint)basePt k:(float)k b:(float)b
{
    double distance = [self distance:btn1 pt2:btn2];
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < ((int) distance / (int) self.rulerScaleWidth); i++) {
        CGPoint point = [self calculateRulerScalePoint:btn1 btn2:btn2 basePt:basePt k:k b:b distance:(i + 1) * self.rulerScaleWidth];
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    return points;
}

- (NSArray *)calculateTop1RulerScalePoints:(CGPoint)btn1 btn2:(CGPoint)btn2 k:(float)k b:(float)b
{
    double distance = [self distance:btn1 pt2:btn2];
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < ((int) distance / (int) self.rulerScaleWidth); i++) {
        CGPoint point = [self calculateRulerScalePoint:btn1 btn2:btn2 basePt:btn1 k:k b:b distance:(i + 1) * self.rulerScaleWidth];
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    return points;
}


- (NSArray *)calculateTop2RulerScalePoints:(CGPoint)btn1 btn2:(CGPoint)btn2 basePt:(CGPoint)basePt k:(float)k b:(float)b
{
    double distance = [self distance:btn1 pt2:btn2];
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:0];
    float blank = self.rulerScaleWidth * 5;
    for (int i = 0; i < ((int) distance / (int) blank); i++) {
        CGPoint point = [self calculateRulerScalePoint:btn1 btn2:btn2 basePt:basePt k:k b:b distance:(i + 1) * blank];
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    return points;
}

- (NSArray *)calculateRulerScalePoints:(CGPoint)btn1 btn2:(CGPoint)btn2 basePt:(CGPoint)basePt k:(float)k b:(float)b distance:(float)distance
{
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:0];
    if (btn1.y - btn2.y == 0) {
        CGPoint point1 = CGPointZero;
        point1.x = basePt.x;
        point1.y = (int) (basePt.y + distance);
        [points addObject:[NSValue valueWithCGPoint:point1]];
        CGPoint point2 = CGPointZero;
        point2.x = basePt.x;
        point2.y = (int) (basePt.y - distance);
        [points addObject:[NSValue valueWithCGPoint:point2]];
    } else if (btn1.x - btn2.x == 0) {
        CGPoint point1 = CGPointZero;
        point1.x = (int) (basePt.x + distance);
        point1.y = basePt.y;
        [points addObject:[NSValue valueWithCGPoint:point1]];
        CGPoint point2 = CGPointZero;
        point2.x = (int) (basePt.x - distance);
        point2.y = basePt.y;
        [points addObject:[NSValue valueWithCGPoint:point2]];
    } else {
        if (-1 < k && k < 1) {
            float linear_a = (float) (powf(k, 2) + 1);
            float linear_b = 2 * k * b - 2 * basePt.x - 2 * k * basePt.y;
            float linear_c = (float) (powf(basePt.x, 2) + powf(b, 2) - 2 * b * basePt.y +
                                      powf(basePt.y, 2) - powf(distance, 2));
            
            int x1 = (int) ((-linear_b - sqrtf((powf(linear_b, 2) -
                                                4 * linear_a * linear_c))) / (2 * linear_a));
            int x2 = (int) ((-linear_b + sqrtf((powf(linear_b, 2) -
                                                4 * linear_a * linear_c))) / (2 * linear_a));
            CGPoint point1 = CGPointZero;
            point1.x = x1;
            point1.y = (int) (k * point1.x + b);
            [points addObject:[NSValue valueWithCGPoint:point1]];
            
            CGPoint point2 = CGPointZero;
            point2.x = x2;
            point2.y = (int) (k * point2.x + b);
            [points addObject:[NSValue valueWithCGPoint:point2]];
            
        } else {
            float linear_a = (float) (powf(1 / k, 2) + 1);
            float linear_b = (float) -(2 * basePt.x / k + 2 * b / powf(k, 2) + 2 * basePt.y);
            float linear_c = (float) (powf(basePt.x, 2) + powf(basePt.y, 2) +
                                      powf(b / k, 2) + 2 * b * basePt.x / k - powf(distance, 2));
            
            int y1 = (int) ((-linear_b - sqrtf((powf(linear_b, 2)
                                                - 4 * linear_a * linear_c))) / (2 * linear_a));
            int y2 = (int) ((-linear_b + sqrtf((powf(linear_b, 2)
                                                - 4 * linear_a * linear_c))) / (2 * linear_a));
            CGPoint point1 = CGPointZero;
            point1.y = y1;
            point1.x = (int) ((point1.y - b) / k);
            [points addObject:[NSValue valueWithCGPoint:point1]];
            CGPoint point2 = CGPointZero;
            point2.y = y2;
            point2.x = (int) ((point2.y - b) / k);
            [points addObject:[NSValue valueWithCGPoint:point2]];
            
        }
    }
    
    return points;
}

- (NSArray *)calculateOperator:(CGPoint)btn1 btn2:(CGPoint)btn2
{
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:0];
    float k = self.kTouchPoint;
    float b = btn1.y - k * btn1.x;
    float distance = (float) sqrtf(powf(self.measureIconSize, 2) - powf(self.measureIconSize / 2, 2));
    CGPoint point1 = [self calculateRulerScalePoint:btn1 btn2:btn2 basePt:btn1 k:k b:b distance:distance reverse:true];
    float b1 = point1.y - self.kRulerLine * point1.x;
    NSArray *points1 = [self calculateRulerScalePoints:btn1 btn2:btn2 basePt:point1 k:self.kRulerLine b:b1 distance:self.measureIconSize / 2];
    if (points1 != nil) {
        [points addObjectsFromArray:points1];
    }
    
    CGPoint point2 = [self calculateRulerScalePoint:btn1 btn2:btn2 basePt:btn2 k:k b:b distance:distance];
    float b2 = point2.y - self.kRulerLine * point2.x;
    NSArray *points2 = [self calculateRulerScalePoints:btn1 btn2:btn2 basePt:point2 k:self.kRulerLine b:b2 distance:self.measureIconSize / 2];
    if (points2 != nil) {
        [points addObjectsFromArray:points2];
    }
    
    return points;
}

- (void)calculate:(CGPoint)btn1 btn2:(CGPoint)btn2
{
    [self calculateRulerLineInfo:btn1 btn2:btn2];
    self.rulerLinePoints = [[NSMutableArray alloc] initWithArray:[self calculateRulerLine:btn1 btn2:btn2 k2:self.kRulerLine b1:self.bRulerLine1 b2:self.bRulerLine2]];
    
    self.rulerPoints = [[NSMutableArray alloc] initWithArray:[self calculateRulerBasePoint:btn1 bt2:btn2 k:self.kRulerLine b1:self.bRulerLine1 b2:self.bRulerLine2]];
    [self calculateRulerInfo:self.rulerPoints btn1:btn1 k:self.kTouchPoint];
    if (self.rulerPoints != nil && self.rulerPoints.count == 4) {
        NSValue *value1 = self.rulerPoints[1];
        CGPoint point1 = value1.CGPointValue;
        self.rulerBottomScalePoints = [[NSMutableArray alloc] initWithArray:[self calculateBottomRulerScalePoints:btn1 btn2:btn2 basePt:point1 k:self.kTouchPoint b:self.bRuler2]];
        self.rulerTop1ScalePoints = [[NSMutableArray alloc] initWithArray:[self calculateTop1RulerScalePoints:btn1 btn2:btn2 k:self.kTouchPoint b:self.bRuler3]];
        NSValue *value0 = self.rulerPoints[0];
        CGPoint point0 = value0.CGPointValue;
        self.rulerTop2ScalePoints = [[NSMutableArray alloc] initWithArray:[self calculateTop2RulerScalePoints:btn1 btn2:btn2 basePt:point0 k:self.kTouchPoint b:self.bRuler1]];
    }
    self.operatorPoints = [[NSMutableArray alloc] initWithArray:[self calculateOperator:btn1 btn2:btn2]];
}

@end
