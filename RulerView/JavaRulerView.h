//
//  RulerView.h
//  OpenCVDetectCircleDemo
//
//  Created by Story5 on 3/27/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchPoint : NSObject

@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;
@property (nonatomic,assign) CGPoint inArea;
@property (nonatomic,assign) CGPoint deltaPoint;
@property (nonatomic,assign) int pointerId;

@end

@interface JavaRulerView : UIView

@end
