//
//  RulerCalculator.h
//  OpenCVDetectCircleDemo
//
//  Created by Story5 on 3/27/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JavaRulerCalculator : NSObject

@property (nonatomic,assign) int width; //控件宽度
@property (nonatomic,assign) int height; //控件高度
@property (nonatomic,assign) CGFloat rulerWidth; // 尺子宽度
@property (nonatomic,assign) CGFloat rulerScaleWidth; //刻度宽度

// 画标尺
@property (nonatomic,strong) NSMutableArray *rulerLinePoints;
@property (nonatomic,strong) NSMutableArray *rulerPoints;
@property (nonatomic,strong) NSMutableArray *rulerBottomScalePoints;
@property (nonatomic,strong) NSMutableArray *rulerTop1ScalePoints;
@property (nonatomic,strong) NSMutableArray *rulerTop2ScalePoints;
@property (nonatomic,strong) NSMutableArray *operatorPoints;

- (void)calculate:(CGPoint)btn1 btn2:(CGPoint)btn2;

@end
