//
//  RulerCalculator.h
//  OpenCVDetectCircleDemo
//
//  Created by Story5 on 3/27/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RulerCalculator : NSObject

@property (nonatomic,assign,readonly) float kAB;
@property (nonatomic,assign,readonly) float bAB;
@property (nonatomic,assign,readonly) float kCD_EF;
@property (nonatomic,assign,readonly) float bCD;
@property (nonatomic,assign,readonly) float bEF;
@property (nonatomic,assign,readonly) float bCE_DF1;
@property (nonatomic,assign,readonly) float bCE_DF2;

@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,assign) CGPoint endPoint;
@property (nonatomic,assign) CGFloat rulerWidth;
@property (nonatomic,assign) CGRect rect;

- (NSArray *)getInterPoints;
- (NSArray *)getRectPoints;

@end
