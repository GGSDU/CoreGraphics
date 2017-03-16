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
    
    var startPoint  : CGPoint = CGPoint.zero
    var endPoint    : CGPoint = CGPoint.zero
    var baseWidth   : CGFloat = 0.0
    var rect        : CGRect = CGRect.zero
    
    private(set) var kAB     : CGFloat = 0.0
    private(set) var bAB     : CGFloat = 0.0
    private(set) var kCD_EF  : CGFloat = 0.0
    private(set) var bCD     : CGFloat = 0.0
    private(set) var bEF     : CGFloat = 0.0
    private(set) var bCE_DF1 : CGFloat = 0.0
    private(set) var bCE_DF2 : CGFloat = 0.0
    
    
    required init(aStartPoint:CGPoint,aEndPoint:CGPoint,aBaseWidth:CGFloat,aRect:CGRect) {
        super.init()
        startPoint = aStartPoint
        endPoint = aEndPoint
        baseWidth = aBaseWidth
        rect = aRect
        
        calculateLineParam()
    }
    
    // MARK: 计算所有直线方程
    func calculateLineParam() -> Void {
        // AB 直线方程 : y = kAB * x + bAB
        kAB = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x)
        bAB = (startPoint.x * endPoint.y - endPoint.x * startPoint.y) / (startPoint.x - endPoint.x)
        // CD 直线方程 : y = kCD_EF * x + bCD
        // EF 直线方程 : y = kCD_EF * x + bEF
        kCD_EF = -1 / kAB //直线垂直,斜率乘积为 -1
        bCD = startPoint.y - (kCD_EF * startPoint.x)
        bEF = endPoint.y - (kCD_EF * endPoint.x)
        // CE 直线方程 : y = kAB * x + bCE
        // DF 直线方程 : y = kAB * x + bDF
        let b_Dec_fabsf = baseWidth / 2 * CGFloat(sqrtf(Float(kAB * kAB + 1)))
        bCE_DF1 = bAB - b_Dec_fabsf
        bCE_DF2 = bAB + b_Dec_fabsf
    }
    
    // MARK: 获取直线与屏幕边缘的交点
    func getInterPoints() -> Array<CGPoint> {
        /// 直接获取 x = 0, y = 0, x = width , y = height 四个点,然后判断相应的 0 =< x <= width, 0 =< y <= height
        var interPoints : Array<CGPoint> = [CGPoint]()
        
        let x10 = CGPoint(x:0,y:bCD)
        let y10 = CGPoint(x:-bCD / kCD_EF,y:0)
        let x1Max = CGPoint(x:rect.width,y:kCD_EF * rect.width + bCD)
        let y1Max = CGPoint(x:(rect.height - bCD) / kCD_EF,y:rect.height)
        
        let x20 = CGPoint(x:0,y:bEF)
        let y20 = CGPoint(x:-bEF / kCD_EF,y:0)
        let x2Max = CGPoint(x:rect.width,y:kCD_EF * rect.width + bEF)
        let y2Max = CGPoint(x:(rect.height - bEF) / kCD_EF,y:rect.height)
        
        let eightPoints = [x10,y10,x1Max,y1Max,x20,y20,x2Max,y2Max]
        for point : CGPoint in eightPoints {
            if point.x >= 0 && point.x <= rect.width && point.y >= 0 && point.y <= rect.height {
                interPoints.append(point)
            }
        }
        return interPoints
    }
    
    // MARK: 获取尺子边框4个点坐标
    func getRectPoints() -> Array<CGPoint> {
        // x = (b2 - b1) / (k1 - k2)
        var rectPoints : Array<CGPoint> = [CGPoint]()
        
        let factors = [(kCD_EF,bCD,kAB,bCE_DF1),
                       (kCD_EF,bCD,kAB,bCE_DF2),
                       (kCD_EF,bEF,kAB,bCE_DF2),
                       (kCD_EF,bEF,kAB,bCE_DF1)]
        for (k1,b1,k2,b2) in factors {
            let x = (b2 - b1) / (k1 - k2)
            let y = k1 * x + b1
            let rPoint = CGPoint(x:x,y:y)
            rectPoints.append(rPoint)
        }
        //  保证旋转时,尺子的画线顺序不变
        if (kAB > 0 && startPoint.y < endPoint.y) || (kAB < 0 && startPoint.y > endPoint.y){
            swap(&rectPoints[0], &rectPoints[1])
            swap(&rectPoints[2], &rectPoints[3])
        }
        
        return rectPoints
    }
}
