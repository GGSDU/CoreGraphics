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
@property (nonatomic,assign) CGFloat measureIconSize; //测量按钮尺寸

- (void)calculate:(CGPoint)btn1 btn2:(CGPoint)btn2;

// 画虚线
@property (nonatomic,strong) NSMutableArray *rulerLinePoints;
// 尺子边框
@property (nonatomic,strong) NSMutableArray *rulerPoints;
// 尺子刻度
@property (nonatomic,strong) NSMutableArray *rulerBottomScalePoints;
// 尺子小刻度
@property (nonatomic,strong) NSMutableArray *rulerTop1ScalePoints;
// 尺子大刻度
@property (nonatomic,strong) NSMutableArray *rulerTop2ScalePoints;
// 尺子头尾
@property (nonatomic,strong) NSMutableArray *operatorPoints;

@end
