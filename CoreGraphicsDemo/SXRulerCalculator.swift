//
//  SXRulerCalculator.swift
//  CoreGraphicsDemo
//
//  Created by Story5 on 3/15/17.
//  Copyright © 2017 Story5. All rights reserved.
//

import Foundation
import UIKit

class SXRulerCalculator: NSObject {
    
    var startPoint : CGPoint = CGPoint.zero
    var endPoint : CGPoint = CGPoint.zero
    var baseWidth : CGFloat = 0
    
    
    func pointArray(startPoint:CGPoint,endPoint:CGPoint,baseWidth:CGFloat,screenRect:CGRect) -> [CGPoint] {
        
        if startPoint.x == endPoint.x {
            return []
        }
        // 排除直线垂直x坐标轴情况
        // AB 直线方程 : y = kAB * x + bAB
        let kAB = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x)
        let bAB = (startPoint.x * endPoint.y - endPoint.x * startPoint.y) / (startPoint.x - endPoint.x)
        
        let kCD_EF = -1 / kAB //直线垂直,斜率乘积为 -1
        // CD 直线方程 : y = kCD_EF * x + bCD
        let bCD = startPoint.y - (kCD_EF * startPoint.x)
        // EF 直线方程 : y = kCD_EF * x + bEF
        let bEF = endPoint.y - (kCD_EF * endPoint.x)
        
        /// 获取直线与屏幕边缘的交点
        /// 这里的思路是
        /// 直接获取 x = 0, y = 0, x = width , y = height 四个点,然后判断相应的 0 < x < width, 0 < y < height
        var intersectionPoints : Array<CGPoint> = [CGPoint]()
        
        let x10 = CGPoint(x:0,y:bCD)
        let y10 = CGPoint(x:-bCD / kCD_EF,y:0)
        let x1Max = CGPoint(x:screenRect.width,y:kCD_EF * screenRect.width + bCD)
        let y1Max = CGPoint(x:(screenRect.height - bCD) / kCD_EF,y:screenRect.height)
        
        let x20 = CGPoint(x:0,y:bEF)
        let y20 = CGPoint(x:-bEF / kCD_EF,y:0)
        let x2Max = CGPoint(x:screenRect.width,y:kCD_EF * screenRect.width + bEF)
        let y2Max = CGPoint(x:(screenRect.height - bEF) / kCD_EF,y:screenRect.height)
        
        let eightPoints = [x10,y10,x1Max,y1Max,x20,y20,x2Max,y2Max]
        for point : CGPoint in eightPoints {
            if point.x >= 0 && point.x <= screenRect.width && point.y >= 0 && point.y <= screenRect.height {
                intersectionPoints.append(point)
            }
        }
        
        
        
        return intersectionPoints
    }
    
    
}
