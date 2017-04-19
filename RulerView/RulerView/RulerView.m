//
//  RulerView.m
//  OpenCVDetectCircleDemo
//
//  Created by Story5 on 3/27/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import "RulerView.h"

#import "JavaRulerCalculator.h"

#import "RulerCalculator.h"

#define OneYuan_Radius @"1.25cm"

@interface RulerView ()

@property (nonatomic,strong) RulerCalculator *ocRulerCalculator;
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,assign) CGPoint endPoint;
@property (nonatomic,assign) float rulerWidth;
@property (nonatomic,assign) BOOL startPointTouchSwitch;
@property (nonatomic,assign) BOOL endPointTouchSwitch;

#pragma mark - java
@property(nonatomic,strong) JavaRulerCalculator *rulerCalculator;

@end

@implementation RulerView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.startPoint  = CGPointMake(280,100);
        self.endPoint    = CGPointMake(280,400);
        self.rulerWidth  = 20;
        self.ocRulerCalculator = [[RulerCalculator alloc] init];
        self.ocRulerCalculator.startPoint = self.startPoint;
        self.ocRulerCalculator.endPoint = self.endPoint;
        self.ocRulerCalculator.rulerWidth = self.rulerWidth;
        self.ocRulerCalculator.rect = frame;
        
        _coinRadius = 1.25;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    self.ocRulerCalculator.startPoint = self.startPoint;
//    self.ocRulerCalculator.endPoint = self.endPoint;
//    [self drawRulerWithRect:rect];
//    
//
    // JAVA
    [self drawRuler];
    
    [self drawMeasureText];
}

#pragma mark - public
- (CGFloat)pixelLength
{
    CGFloat xDifference = self.startPoint.x - self.endPoint.x;
    CGFloat yDifference = self.startPoint.y - self.endPoint.y;
    CGFloat pixelLength = sqrtf((powf(xDifference, 2) + powf(yDifference, 2)));
    return pixelLength;
}

- (CGFloat)measureLength
{
    CGFloat pixelLength = [self pixelLength];
    _measureLength = pixelLength / (CGFloat)self.coinPixelRadius * self.coinRadius;
    return _measureLength;
}

#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    float touchWidth = 20;
    CGRect  touchStartRect = CGRectMake(self.startPoint.x - touchWidth,
                                        self.startPoint.y - touchWidth,
                                        touchWidth * 2,
                                        touchWidth * 2);
    CGRect touchEndRect = CGRectMake(self.endPoint.x - touchWidth,
                                     self.endPoint.y - touchWidth,
                                     touchWidth * 2,
                                     touchWidth * 2);
    
    if (CGRectContainsPoint(touchStartRect, touchPoint)) {
        self.startPointTouchSwitch = true;
    }
    
    if (CGRectContainsPoint(touchEndRect, touchPoint))  {
        self.endPointTouchSwitch = true;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (self.startPointTouchSwitch) {
        self.startPoint = touchPoint;
        [self setNeedsDisplay];
    } else if (self.endPointTouchSwitch) {
        
        self.endPoint = touchPoint;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.startPointTouchSwitch = false;
    self.endPointTouchSwitch = false;
}

#pragma mark - private
// MARK: 画平行虚线
- (void)drawDashWithContext:(CGContextRef)context {
    
    NSArray *linePoints = [self.ocRulerCalculator getInterPoints];
    
    if (linePoints.count < 4) {
        return;
    }
    CGPoint point0 = [linePoints[0] CGPointValue];
    CGPoint point1 = [linePoints[1] CGPointValue];
    CGPoint point2 = [linePoints[2] CGPointValue];
    CGPoint point3 = [linePoints[3] CGPointValue];
    
    // save state
    CGContextSaveGState(context);
    // draw line
    CGContextMoveToPoint(context, point0.x, point0.y);
    CGContextAddLineToPoint(context, point1.x, point1.y);
    
    CGContextMoveToPoint(context, point2.x, point2.y);
    CGContextAddLineToPoint(context, point3.x, point3.y);

    // config line style
    CGFloat lengths[] = {10,10};
    CGContextSetLineDash(context, 0, lengths,2);
    
    CGContextStrokePath(context);
    // restore state
    CGContextRestoreGState(context);
}

// MARK: 画尺子边框
- (void)drawRulerFrameWithContext:(CGContextRef)context
{
    NSArray *rectPoints = [self.ocRulerCalculator getRectPoints];
    // 画外边框(最后要计算的尺度)
    if (rectPoints.count != 4) {
        return;
    }
    CGPoint point0 = [rectPoints[0] CGPointValue];
    CGPoint point1 = [rectPoints[1] CGPointValue];
    CGPoint point2 = [rectPoints[2] CGPointValue];
    CGPoint point3 = [rectPoints[3] CGPointValue];
    CGPoint linePoints[] = {point0,point1,point2,point3};

    
    // save state
    CGContextSaveGState(context);
    // draw rect
    CGContextMoveToPoint(context, point0.x, point0.y);
    CGContextAddLines(context, linePoints, 4);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    // restore state
    CGContextRestoreGState(context);
}

// MARK: 画三角形
- (void)drawTriangleWithContext:(CGContextRef)context
                     startPoint:(CGPoint)startPoint
                          width:(CGFloat)width
                           flip:(BOOL)flip
{

    float xOffset = width / 2;
    float yOffset = sqrtf(3.0) * xOffset;
    if (flip) {
        yOffset = -yOffset;
    }
    
    CGPoint trianglePoint2 = CGPointMake(startPoint.x - xOffset,startPoint.y - yOffset);
    CGPoint trianglePoint3 = CGPointMake(startPoint.x + xOffset,startPoint.y - yOffset);
    
    // save state
    CGContextSaveGState(context);
    // draw triangle
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, trianglePoint2.x, trianglePoint2.y);
    CGContextAddLineToPoint(context, trianglePoint3.x, trianglePoint3.y);
    CGContextClosePath(context);
    // config stroke color
    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1);
    CGContextStrokePath(context);


    // restore state
    CGContextRestoreGState(context);
}

- (void)drawRulerWithRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1);
    // 画虚线
    [self drawDashWithContext:context];
    // 画尺子边框
    [self drawRulerFrameWithContext:context];
    // 画尺子标尺
    [self drawRulerBodyWithContext:context];
    // 画尺子头尾三角形
    [self drawTriangleWithContext:context startPoint:self.startPoint width:self.rulerWidth flip:false];
    [self drawTriangleWithContext:context startPoint:self.endPoint width:self.rulerWidth flip:true];
}

- (void)drawMeasureText
{
    NSString *text = [NSString stringWithFormat:@"%.2f cm",self.measureLength];
    NSDictionary *attribute = @{NSForegroundColorAttributeName:[UIColor redColor],
                                NSFontAttributeName:[UIFont systemFontOfSize:20]};
    [text drawAtPoint:CGPointMake(10, self.bounds.size.height - 50) withAttributes:attribute];
}

// MARK: 画标尺
- (void)drawRulerBodyWithContext:(CGContextRef)context
{
    NSArray *rectPoints = [self.ocRulerCalculator getRectPoints];
    // 直线AB
    // |x - x0| = d / √(k * k + 1)
    float kAB     = self.ocRulerCalculator.kAB;
    float bAB     = self.ocRulerCalculator.bAB;
    float bCE_DF1 = self.ocRulerCalculator.bCE_DF1;
    float bCE_DF2 = self.ocRulerCalculator.bCE_DF2;
    
    // 画刻度
    float RulerBodyHeight = sqrtf(powf(self.endPoint.x - self.startPoint.x,2) + powf(self.endPoint.y - self.startPoint.y,2));
    int scale = 5;
    int offset = 0;
    
    CGPoint point0 = [rectPoints[0] CGPointValue];
    CGPoint point1 = [rectPoints[1] CGPointValue];


    CGContextSaveGState(context);
    while (offset <  RulerBodyHeight) {
        
        float mod = (offset / scale) % 5;
        
        
        float increase = offset / sqrtf(kAB * kAB + 1);
        float x0 = self.startPoint.x + increase;
        float y0 = kAB * x0 + bAB;
        
        float x1 = point0.x + increase;
        float y1 = kAB * x0 + bCE_DF1;
        
        float x2 = point1.x + increase;
        float y2 = kAB * x0 + bCE_DF2;
        
        CGPoint pointS = CGPointMake(x1,y1);
        CGPoint pointE = CGPointMake(x2,y2);
        
        if (mod == 0) {
            // 画大刻度线(封闭,全宽)
            CGContextMoveToPoint(context, pointS.x, pointS.y);
            CGContextAddLineToPoint(context, pointE.x, pointE.y);
        } else {
            // 画小刻度线(半宽)
            CGContextMoveToPoint(context, x0, y0);
            CGContextAddLineToPoint(context, pointE.x, pointE.y);
        }
        
        offset += scale;
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}


- (void)setStartPoint:(CGPoint)startPoint
{
    _startPoint = startPoint;
    self.ocRulerCalculator.startPoint = startPoint;
}

- (void)setEndPoint:(CGPoint)endPoint
{
    _endPoint = endPoint;
    self.ocRulerCalculator.endPoint = endPoint;
}

#pragma mark - java
- (void)drawRuler
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 1.0, 0, 0, 1);

    if (self.rulerCalculator != nil) {
        
        [self.rulerCalculator calculate:self.startPoint btn2:self.endPoint];
        //画标尺
        NSArray *points = self.rulerCalculator.rulerLinePoints;
        if (points != nil && points.count == 4) {
            
            CGPoint point0 = [points[0] CGPointValue];
            CGPoint point1 = [points[1] CGPointValue];
            CGPoint point2 = [points[2] CGPointValue];
            CGPoint point3 = [points[3] CGPointValue];
            
            CGMutablePathRef pathRuler1 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler1, nil, point0.x, point0.y);
            CGPathAddLineToPoint(pathRuler1, nil, point1.x, point1.y);
            CGContextAddPath(ctx, pathRuler1);
            CGContextDrawPath(ctx, kCGPathStroke);
            
            CGMutablePathRef pathRuler2 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler2, nil, point2.x, point2.y);
            CGPathAddLineToPoint(pathRuler2, nil, point3.x, point3.y);
            CGContextAddPath(ctx, pathRuler2);
            CGContextDrawPath(ctx, kCGPathStroke);
        }
        
        //画尺子边框
        NSArray *rulerPoints = self.rulerCalculator.rulerPoints;
        if (rulerPoints != nil && rulerPoints.count == 4) {
            CGPoint point0 = [rulerPoints[0] CGPointValue];
            CGPoint point1 = [rulerPoints[1] CGPointValue];
            CGPoint point2 = [rulerPoints[2] CGPointValue];
            CGPoint point3 = [rulerPoints[3] CGPointValue];
            
            
            CGMutablePathRef pathRuler1 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler1, nil, point0.x, point0.y);
            CGPathAddLineToPoint(pathRuler1, nil, point2.x, point2.y);
            CGContextAddPath(ctx, pathRuler1);
            CGContextDrawPath(ctx, kCGPathStroke);
            
            CGMutablePathRef pathRuler2 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler2, nil, point1.x, point1.y);
            CGPathAddLineToPoint(pathRuler2, nil, point3.x, point3.y);
            CGContextAddPath(ctx, pathRuler2);
            CGContextDrawPath(ctx, kCGPathStroke);
            
            CGMutablePathRef pathRuler3 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler3, nil, point0.x, point0.y);
            CGPathAddLineToPoint(pathRuler3, nil, point1.x, point1.y);
            CGContextAddPath(ctx, pathRuler3);
            CGContextDrawPath(ctx, kCGPathStroke);
            
            CGMutablePathRef pathRuler4 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler4, nil, point2.x, point2.y);
            CGPathAddLineToPoint(pathRuler4, nil, point3.x, point3.y);
            CGContextAddPath(ctx, pathRuler4);
            CGContextDrawPath(ctx, kCGPathStroke);
        }

        //画尺子刻度
        NSArray *bottomScalePoints = self.rulerCalculator.rulerBottomScalePoints;
        //画尺子小刻度
        NSArray *top1ScalePoints = self.rulerCalculator.rulerTop1ScalePoints;
        if (bottomScalePoints != nil && bottomScalePoints.count > 0
            && top1ScalePoints != nil && top1ScalePoints.count > 0) {
            for (int i = 0; i < bottomScalePoints.count; i++) {
                CGPoint top1Pointi = [top1ScalePoints[i] CGPointValue];
                CGPoint bottomPointi = [bottomScalePoints[i] CGPointValue];
                
                
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathMoveToPoint(path, nil, top1Pointi.x, top1Pointi.y);
                CGPathAddLineToPoint(path, nil, bottomPointi.x, bottomPointi.y);
                CGContextAddPath(ctx, path);
                CGContextDrawPath(ctx, kCGPathStroke);
            }
        }
        
        //画尺子大刻度
        NSArray *top2ScalePoints = self.rulerCalculator.rulerTop2ScalePoints;
        if (bottomScalePoints != nil && bottomScalePoints.count > 0
            && top2ScalePoints != nil && top2ScalePoints.count > 0) {
            for (int i = 0; i < top2ScalePoints.count; i++) {
                int index = (i + 1) * 5 - 1;
                if (bottomScalePoints.count > index) {
                    CGPoint top2Pointi = [top2ScalePoints[i] CGPointValue];
                    CGPoint bottomPointi = [bottomScalePoints[(i + 1) * 5 -1] CGPointValue];
                    
                    CGMutablePathRef path = CGPathCreateMutable();
                    CGPathMoveToPoint(path, nil, top2Pointi.x, top2Pointi.y);
                    CGPathAddLineToPoint(path, nil, bottomPointi.x, bottomPointi.y);
                    CGContextAddPath(ctx, path);
                    CGContextDrawPath(ctx, kCGPathStroke);
                }
            }
        }
        
        //画操作按钮
        NSArray *operatorPoints = self.rulerCalculator.operatorPoints;
        if (operatorPoints != nil && operatorPoints.count == 4) {
            CGPoint point0 = [operatorPoints[0] CGPointValue];
            CGPoint point1 = [operatorPoints[1] CGPointValue];
            CGPoint point2 = [operatorPoints[2] CGPointValue];
            CGPoint point3 = [operatorPoints[3] CGPointValue];
            
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, self.startPoint.x, self.startPoint.y);
            CGPathAddLineToPoint(path, nil, point0.x, point0.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathStroke);
            
            CGPathMoveToPoint(path, nil, point0.x, point0.y);
            CGPathAddLineToPoint(path, nil, point1.x, point1.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathStroke);
            
            CGPathMoveToPoint(path, nil, point1.x, point1.y);
            CGPathAddLineToPoint(path, nil, self.startPoint.x, self.startPoint.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathStroke);
            
            
            CGPathMoveToPoint(path, nil, self.endPoint.x, self.endPoint.y);
            CGPathAddLineToPoint(path, nil, point2.x, point2.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathStroke);
            
            CGPathMoveToPoint(path, nil, point2.x, point2.y);
            CGPathAddLineToPoint(path, nil, point3.x, point3.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathStroke);
            
            CGPathMoveToPoint(path, nil, point3.x, point3.y);
            CGPathAddLineToPoint(path, nil, self.endPoint.x, self.endPoint.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathStroke);
        }
    }
}

- (JavaRulerCalculator *)rulerCalculator
{
    if (_rulerCalculator == nil) {
        _rulerCalculator = [[JavaRulerCalculator alloc] init];
        _rulerCalculator.width = self.bounds.size.width;
        _rulerCalculator.height = self.bounds.size.height;
        _rulerCalculator.rulerWidth = self.rulerWidth;
        _rulerCalculator.rulerScaleWidth = self.rulerWidth / 2;
        _rulerCalculator.measureIconSize = self.rulerWidth;
    }
    return _rulerCalculator;
}

@end
