//
//  RulerCalculator.m
//  OpenCVDetectCircleDemo
//
//  Created by Story5 on 3/27/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import "RulerCalculator.h"

@interface RulerCalculator ()

@property (nonatomic,assign) BOOL verticalStatus;

@end


@implementation RulerCalculator

#pragma mark - 计算所有直线方程
- (void)calculateLineParam{
    // 排除尺子垂直于y轴情况
    if (self.verticalStatus) return;
    
    // AB 直线方程 : y = kAB * x + bAB
    _kAB = (self.endPoint.y - self.startPoint.y) / (self.endPoint.x - self.startPoint.x);
    _bAB = (self.startPoint.x * self.endPoint.y - self.endPoint.x * self.startPoint.y) / (self.startPoint.x - self.endPoint.x);
    // CD 直线方程 : y = kCD_EF * x + bCD
    // EF 直线方程 : y = kCD_EF * x + bEF
    _kCD_EF = -1 / _kAB; //直线垂直,斜率乘积为 -1
    _bCD = self.startPoint.y - (_kCD_EF * self.startPoint.x);
    _bEF = self.endPoint.y - (_kCD_EF * self.endPoint.x);
    // CE 直线方程 : y = kAB * x + bCE
    // DF 直线方程 : y = kAB * x + bDF
    CGFloat b_Dec_fabsf = self.rulerWidth / 2 * sqrtf(_kAB * _kAB + 1);
    _bCE_DF1 = _bAB - b_Dec_fabsf;
    _bCE_DF2 = _bAB + b_Dec_fabsf;
}

// MARK: 获取直线与屏幕边缘的交点
- (NSArray *)getInterPoints
{
    if (self.verticalStatus) {
        return @[[NSValue valueWithCGPoint:CGPointMake(0, self.startPoint.y)],
                 [NSValue valueWithCGPoint:CGPointMake(self.rect.size.width, self.startPoint.y)],
                 [NSValue valueWithCGPoint:CGPointMake(0, self.endPoint.y)],
                 [NSValue valueWithCGPoint:CGPointMake(self.rect.size.width, self.endPoint.y)]
                 ];
    }

    [self calculateLineParam];
    
    /// 直接获取 x = 0, y = 0, x = width , y = height 四个点,然后判断相应的 0 =< x <= width, 0 =< y <= height
    NSMutableArray *interPoints = [[NSMutableArray alloc] initWithCapacity:4];
    
    CGPoint x10 = CGPointMake(0, _bCD);
    CGPoint y10 = CGPointMake(-_bCD / _kCD_EF, 0);
    CGPoint x1Max = CGPointMake(self.rect.size.width, _kCD_EF * self.rect.size.width + _bCD);
    CGPoint y1Max = CGPointMake((self.rect.size.height - _bCD) / _kCD_EF, self.rect.size.height);

    
    CGPoint x20 = CGPointMake(0,_bEF);
    CGPoint y20 = CGPointMake(-_bEF / _kCD_EF,0);
    CGPoint x2Max = CGPointMake(self.rect.size.width,_kCD_EF * self.rect.size.width + _bEF);
    CGPoint y2Max = CGPointMake((self.rect.size.height - _bEF) / _kCD_EF,self.rect.size.height);
    
    NSArray *eightPoints = [[NSArray alloc] initWithObjects:
                            [NSValue valueWithCGPoint:x10],
                            [NSValue valueWithCGPoint:y10],
                            [NSValue valueWithCGPoint:x1Max],
                            [NSValue valueWithCGPoint:y1Max],
                            [NSValue valueWithCGPoint:x20],
                            [NSValue valueWithCGPoint:y20],
                            [NSValue valueWithCGPoint:x2Max],
                            [NSValue valueWithCGPoint:y2Max], nil];
    for (NSValue *pointValue in eightPoints) {
        CGPoint point = pointValue.CGPointValue;
        if (point.x >= 0 && point.x <= self.rect.size.width && point.y >= 0 && point.y <= self.rect.size.height) {
            [interPoints addObject:[NSValue valueWithCGPoint:point]];
        }
    }
    return interPoints;
}

// MARK: 获取尺子边框4个点坐标
- (NSArray *)getRectPoints
{
    if (self.verticalStatus) {
        return @[[NSValue valueWithCGPoint:CGPointMake(self.startPoint.x - self.rulerWidth / 2, self.startPoint.y)],
                 [NSValue valueWithCGPoint:CGPointMake(self.startPoint.x + self.rulerWidth / 2, self.startPoint.y)],
                 [NSValue valueWithCGPoint:CGPointMake(self.endPoint.x + self.rulerWidth / 2, self.endPoint.y)],
                 [NSValue valueWithCGPoint:CGPointMake(self.endPoint.x - self.rulerWidth / 2, self.endPoint.y)]];
    }
    
    [self calculateLineParam];
    
    // x = (b2 - b1) / (k1 - k2)
    NSMutableArray *rectPoints = [[NSMutableArray alloc] initWithCapacity:4];
    
    float k1 = _kCD_EF;
    float k2 = _kAB;
    float b1Array[4] = {_bCD,_bCD,_bEF,_bEF};
    float b2Array[4] = {_bCE_DF1,_bCE_DF2,_bCE_DF2,_bCE_DF1};
    for (int i = 0 ; i < 4; i++) {
        float b1 = b1Array[i];
        float b2 = b2Array[i];
        float x = (b2 - b1) / (k1 - k2);
        float y = k1 * x + b1;
        CGPoint rPoint = CGPointMake(x,y);
        [rectPoints addObject:[NSValue valueWithCGPoint:rPoint]];
    }
    //  保证旋转时,尺子的画线顺序不变
    if ((_kAB > 0 && self.startPoint.y < self.endPoint.y) || (_kAB < 0 && self.startPoint.y > self.endPoint.y)){
        [rectPoints exchangeObjectAtIndex:0 withObjectAtIndex:1];
        [rectPoints exchangeObjectAtIndex:2 withObjectAtIndex:3];
    }
    return rectPoints;
}

- (BOOL)verticalStatus
{
    if (self.startPoint.x == self.endPoint.x) {
        return true;
    }
    return  false;
}

@end
