//
//  RulerView.m
//  OpenCVDetectCircleDemo
//
//  Created by Story5 on 3/27/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import "RulerView.h"
#import "RulerCalculator.h"

#define OneYuan_Radius @"1.25cm"

@interface RulerView ()

@property (nonatomic,strong) RulerCalculator *rulerCalculator;
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,assign) CGPoint endPoint;
@property (nonatomic,assign) float rulerWidth;
@property (nonatomic,assign) BOOL startPointTouchSwitch;
@property (nonatomic,assign) BOOL endPointTouchSwitch;

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
        self.rulerCalculator = [[RulerCalculator alloc] init];
        self.rulerCalculator.startPoint = self.startPoint;
        self.rulerCalculator.endPoint = self.endPoint;
        self.rulerCalculator.rulerWidth = self.rulerWidth;
        self.rulerCalculator.rect = frame;
        
        _coinRadius = 1.25;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.rulerCalculator.startPoint = self.startPoint;
    self.rulerCalculator.endPoint = self.endPoint;
    [self drawRulerWithRect:rect];
    
    
    NSString *measureText = [NSString stringWithFormat:@"%.2f cm",self.measureLength];
    [self drawMeasureText:measureText];
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
    
    NSArray *linePoints = [self.rulerCalculator getInterPoints];
    
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
    NSArray *rectPoints = [self.rulerCalculator getRectPoints];
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
//    [self drawRulerBodyWithContext:context];
    // 画尺子头尾三角形
    [self drawTriangleWithContext:context startPoint:self.startPoint width:self.rulerWidth flip:false];
    [self drawTriangleWithContext:context startPoint:self.endPoint width:self.rulerWidth flip:true];
}

- (void)drawMeasureText:(NSString *)text
{
    NSDictionary *attribute = @{NSForegroundColorAttributeName:[UIColor redColor],
                                NSFontAttributeName:[UIFont systemFontOfSize:20]};
    [text drawAtPoint:CGPointMake(10, self.bounds.size.height - 50) withAttributes:attribute];
}

// MARK: 画标尺
- (void)drawRulerBodyWithContext:(CGContextRef)context
{
    NSArray *rectPoints = [self.rulerCalculator getRectPoints];
    // 直线AB
    // |x - x0| = d / √(k * k + 1)
    float kAB     = self.rulerCalculator.kAB;
    float bAB     = self.rulerCalculator.bAB;
    float bCE_DF1 = self.rulerCalculator.bCE_DF1;
    float bCE_DF2 = self.rulerCalculator.bCE_DF2;
    
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
    self.rulerCalculator.startPoint = startPoint;
}

- (void)setEndPoint:(CGPoint)endPoint
{
    _endPoint = endPoint;
    self.rulerCalculator.endPoint = endPoint;
}

@end
