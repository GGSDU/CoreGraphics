//
//  RulerView.h
//  OpenCVDetectCircleDemo
//
//  Created by Story5 on 3/27/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RulerView : UIView

// 传入的圆像素半径
@property (nonatomic,assign) NSUInteger coinPixelRadius;
// 1元硬币固定半径1.25cm
@property (nonatomic,assign,readonly) CGFloat coinRadius;

// 最后计算的长度,单位为cm
@property (nonatomic,assign,getter=measureLength) CGFloat measureLength;

@end
