//
//  RulerView.swift
//  CoreGraphicsDemo
//
//  Created by Story5 on 3/13/17.
//  Copyright © 2017 Story5. All rights reserved.
//

import Foundation
import UIKit

class SXRulerView: UIView {
    
    var startPoint : CGPoint = CGPoint(x:100,y:50)
    var endPoint : CGPoint = CGPoint(x:150,y:450)
    let baseWidth : CGFloat = 20
    
    override func draw(_ rect: CGRect) {
        drawRuler(rect: rect)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        let touchPoint = touch.location(in: self)
        
        print(touchPoint)
        startPoint = touchPoint;
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        let touchPoint = touch.location(in: self)
        
        print(touchPoint)
        startPoint = touchPoint;
        setNeedsDisplay()
    }
    
    func drawRuler(rect:CGRect) -> Void {
        
        let context : CGContext = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(red: 1.0, green: 0, blue: 0, alpha: 1)
//        ctx.setLineDash(phase: 0, lengths: [10,5])
        drawDash(context: context, startPoint: startPoint, endPoint: endPoint, baseWidth: baseWidth, screenRect: rect)
        // 画尺子头
        drawTriangle(context: context, startPoint: startPoint, width: baseWidth, flip: false)
        drawRulerFrame(context: context, startPoint: startPoint, endPoint: endPoint, bodyWidth: baseWidth, screenRect: rect)
        // 画标尺
        drawRulerBody(context: context, startPoint: startPoint, endPoint: endPoint, bodyWidth: baseWidth,screenRect: rect)
        // 画尺子尾
        drawTriangle(context: context, startPoint: endPoint, width: baseWidth, flip: true)
    }
    
    // MARK: 画标尺
    func drawRulerBody(context:CGContext,startPoint:CGPoint,endPoint:CGPoint,bodyWidth:CGFloat,screenRect:CGRect) -> Void {
        
        let pointTuple = pointArray(startPoint: startPoint, endPoint: endPoint, baseWidth: baseWidth, screenRect: screenRect)
        
        // 直线AB
        // |x - x0| = d / √(k * k + 1)
//        if pointTuple.lineParam.count == 4 {
            let kAB = pointTuple.lineParam[0]
            let bAB = pointTuple.lineParam[1]
            let bCE = pointTuple.lineParam[2]
            let bDF = pointTuple.lineParam[3]
//        }
        // 画刻度
        let RulerBodyHeight = sqrtf(powf(Float(endPoint.x - startPoint.x),2) + powf(Float(endPoint.y - startPoint.y),2))
        let scale = 5
        var offset : Int = 0
        
        while Float(offset) <  RulerBodyHeight{
            let mod = (offset / scale) % 5

            
            let increase = CGFloat(offset) / CGFloat(sqrtf(Float(kAB * kAB + 1)))
            let x0 = startPoint.x + increase
            let y0 = kAB * x0 + bAB
            
            let x1 = pointTuple.rectPoints[1].x + increase
            let y1 = kAB * x0 + bCE
            
            let x2 = pointTuple.rectPoints[0].x + increase
            let y2 = kAB * x0 + bDF
            
            let point1 = CGPoint(x:x1,y:y1)
            let point2 = CGPoint(x:x2,y:y2)
            
            if mod == 0 {
                // 画大刻度线(封闭,全宽)
                context.move(to: point1)
                context.addLine(to: point2)
            } else {
                // 画小刻度线(半宽)
                context.move(to: CGPoint(x:x0,y:y0))
                context.addLine(to: point2)
            }
            
            offset += scale
        }
        
        
    }
    
    // MARK: 画三角形
    func drawTriangle(context:CGContext,startPoint:CGPoint,width:CGFloat,flip:Bool) -> Void {

        let xOffset = width / 2
        var yOffset = CGFloat(sqrtf(3.0)) * xOffset
        if flip {
            yOffset = -yOffset
        }
        let trianglePoint2 = CGPoint(x:startPoint.x - xOffset,y:startPoint.y - yOffset)
        let trianglePoint3 = CGPoint(x:startPoint.x + xOffset,y:startPoint.y - yOffset)
        // save state
        context.saveGState()
        // draw triangle
        context.move(to: startPoint)
        context.addLine(to: trianglePoint2)
        context.addLine(to: trianglePoint3)
        context.closePath()
        // config stroke color
        context.setStrokeColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        
        context.strokePath()
        // restore state
        context.restoreGState()
    }
    
    // MARK: 画标尺
    func drawRulerFrame(context:CGContext,startPoint:CGPoint,endPoint:CGPoint,bodyWidth:CGFloat,screenRect:CGRect) -> Void {
        
        let pointTuple = pointArray(startPoint: startPoint, endPoint: endPoint, baseWidth: baseWidth, screenRect: screenRect)
        
        // 画外边框(最后要计算的尺度)
        // save state
        context.saveGState()
        if pointTuple.rectPoints.count == 4 {
            print(pointTuple.rectPoints)
            
            context.move(to: pointTuple.rectPoints[0])
            context.addLine(to: pointTuple.rectPoints[1])
            context.addLine(to: pointTuple.rectPoints[2])
            context.addLine(to: pointTuple.rectPoints[3])
            context.closePath()
        }
        context.strokePath()
        // restore state
        context.restoreGState()
    }
    
    // MARK: 画平行虚线
    func drawDash(context:CGContext,startPoint:CGPoint,endPoint:CGPoint,baseWidth:CGFloat,screenRect:CGRect) -> Void {
        
        let pointTuple = pointArray(startPoint: startPoint, endPoint: endPoint, baseWidth: baseWidth, screenRect: screenRect)
        let linePoints = pointTuple.interPoints
        if linePoints.count < 4 {
            return
        }
        let linePoint0 = linePoints[0]
        let linePoint1 = linePoints[1]
        let linePoint2 = linePoints[2]
        let linePoint3 = linePoints[3]
        
        // save state
        context.saveGState()
        // draw line
        context.move(to: linePoint0)
        context.addLine(to: linePoint1)
        
        context.move(to: linePoint2)
        context.addLine(to: linePoint3)
        // config line style
        context.setLineDash(phase: 0, lengths: [10,10])
        
        context.strokePath()
        // restore state
        context.restoreGState()
    }
    
    /// 返回尺子所需要的12个点
    ///
    /// - Parameters:
    ///   - startPoint: A
    ///   - endPoint: B
    ///   - baseWidth: 尺子宽度
    /// - Returns: [c,d,e,f,g,h,i,j,k,l,m,n]
    func pointArray(startPoint:CGPoint,endPoint:CGPoint,baseWidth:CGFloat,screenRect:CGRect) -> (rectPoints : [CGPoint],interPoints : [CGPoint],lineParam : [CGFloat]) {
        
        // 排除直线垂直x坐标轴情况
        if startPoint.x == endPoint.x {
            return ([],[],[])
        }
        
        // AB 直线方程 : y = kAB * x + bAB
        let kAB = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x)
        let bAB = (startPoint.x * endPoint.y - endPoint.x * startPoint.y) / (startPoint.x - endPoint.x)
        // CD 直线方程 : y = kCD_EF * x + bCD
        // EF 直线方程 : y = kCD_EF * x + bEF
        let kCD_EF = -1 / kAB //直线垂直,斜率乘积为 -1
        let bCD = startPoint.y - (kCD_EF * startPoint.x)
        let bEF = endPoint.y - (kCD_EF * endPoint.x)
        // CE 直线方程 : y = kAB * x + bCE
        // DF 直线方程 : y = kAB * x + bDF
        let b_Dec_fabsf = baseWidth / 2 * CGFloat(sqrtf(Float(kAB * kAB + 1)))
        let bCE_DF1 = bAB - b_Dec_fabsf
        let bCE_DF2 = bAB + b_Dec_fabsf
    
        /// 获取直线与屏幕边缘的交点
        /// 这里的思路是
        /// 直接获取 x = 0, y = 0, x = width , y = height 四个点,然后判断相应的 0 < x < width, 0 < y < height
        var interPoints : Array<CGPoint> = [CGPoint]()
        
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
                interPoints.append(point)
            }
        }
        
        // 垂直直线交点坐标
        // x = (b2 - b1) / (k1 - k2)
        var rectPoints : Array<CGPoint> = [CGPoint]()
        //
        let factors = [(kCD_EF,bCD,kAB,bCE_DF1),(kCD_EF,bCD,kAB,bCE_DF2),(kCD_EF,bEF,kAB,bCE_DF2),(kCD_EF,bEF,kAB,bCE_DF1)]
        for (k1,b1,k2,b2) in factors {
            let x = (b2 - b1) / (k1 - k2)
            let y = k1 * x + b1
            let rPoint = CGPoint(x:x,y:y)
            rectPoints.append(rPoint)
        }
        if kAB > 0 {//保证画框顺序是顺时针
            swap(&rectPoints[0], &rectPoints[1])
            swap(&rectPoints[2], &rectPoints[3])
        }
        
        
        
        return (rectPoints,interPoints,[kAB,bAB,bCE_DF1,bCE_DF2])
    }
}
