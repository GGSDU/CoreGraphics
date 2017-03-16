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
    
    var rulerCalculator : SXRulerCalculator?
    
    let baseWidth : CGFloat = 20
    var startPoint : CGPoint = CGPoint(x:200,y:100)
    var endPoint : CGPoint = CGPoint(x:150,y:500)
    var startPointTouchSwitch = false
    var endPointTouchSwitch = false
    
    override func awakeFromNib() {
        rulerCalculator = SXRulerCalculator(aStartPoint: startPoint, aEndPoint: endPoint, aBaseWidth: baseWidth, aRect: bounds)
        
    }
    
    override func draw(_ rect: CGRect) {
        
        rulerCalculator!.startPoint = startPoint
        rulerCalculator!.endPoint = endPoint
        
        drawRuler(rect: rect)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        let touchPoint = touch.location(in: self)
        
        let touchWidth : CGFloat = 20
        let touchStartRect = CGRect(x: startPoint.x - touchWidth, y: startPoint.y - touchWidth, width: touchWidth * 2, height: touchWidth * 2)
        let touchEndRect = CGRect(x: endPoint.x - touchWidth, y: endPoint.y - touchWidth, width: touchWidth * 2, height: touchWidth * 2)
        
        if touchStartRect.contains(touchPoint) {
            startPointTouchSwitch = true
        }
        if touchEndRect.contains(touchPoint) {
            endPointTouchSwitch = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        print("touches.count - ",touches.count)
        let touchPoint = touch.location(in: self)
        
        if startPointTouchSwitch {
            startPoint = touchPoint;
            setNeedsDisplay()
        } else if endPointTouchSwitch {
            endPoint = touchPoint;
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        startPointTouchSwitch = false
        endPointTouchSwitch = false
    }
    
    func drawRuler(rect:CGRect) -> Void {
        
        let context : CGContext = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        
        // 画虚线
        drawDash(context: context)
        // 画边框
        drawRulerFrame(context: context)
        
        // 画标尺
        drawRulerBody(context: context)
        // 画尺子头
        drawTriangle(context: context, startPoint: startPoint, width: baseWidth, flip: false)
        // 画尺子尾
        drawTriangle(context: context, startPoint: endPoint, width: baseWidth, flip: true)
    }
    
    // MARK: 画标尺
    func drawRulerBody(context:CGContext) -> Void {
        
        let rectPoints = rulerCalculator!.getRectPoints()
        // 直线AB
        // |x - x0| = d / √(k * k + 1)
        let kAB     = rulerCalculator!.kAB
        let bAB     = rulerCalculator!.bAB
        let bCE_DF1 = rulerCalculator!.bCE_DF1
        let bCE_DF2 = rulerCalculator!.bCE_DF2
        // 画刻度
        let RulerBodyHeight = sqrtf(powf(Float(endPoint.x - startPoint.x),2) + powf(Float(endPoint.y - startPoint.y),2))
        let scale = 5
        var offset : Int = 0
        
        context.saveGState()
        while Float(offset) <  RulerBodyHeight{
            let mod = (offset / scale) % 5
            
            
            let increase = CGFloat(offset) / CGFloat(sqrtf(Float(kAB * kAB + 1)))
            let x0 = startPoint.x + increase
            let y0 = kAB * x0 + bAB
            
            let x1 = rectPoints[0].x + increase
            let y1 = kAB * x0 + bCE_DF1
            
            let x2 = rectPoints[1].x + increase
            let y2 = kAB * x0 + bCE_DF2
            
            let point1 = CGPoint(x:x1,y:y1)
            let point2 = CGPoint(x:x2,y:y2)
            
            context.saveGState()
            
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
        context.strokePath()
        context.restoreGState()
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
    
    // MARK: 画尺子边框
    func drawRulerFrame(context:CGContext) -> Void {
        
        let rectPoints = rulerCalculator!.getRectPoints()
        // 画外边框(最后要计算的尺度)
        if rectPoints.count != 4 {
            return
        }
        
        // save state
        context.saveGState()
        // draw rect
        context.move(to: rectPoints[0])
        context.addLine(to: rectPoints[1])
        context.addLine(to: rectPoints[2])
        context.addLine(to: rectPoints[3])
        context.closePath()
        
        context.strokePath()
        // restore state
        context.restoreGState()
    }
    
    // MARK: 画平行虚线
    func drawDash(context:CGContext) -> Void {
        
        let linePoints = rulerCalculator!.getInterPoints()
        if linePoints.count < 4 {
            return
        }
        
        // save state
        context.saveGState()
        // draw line
        context.move(to: linePoints[0])
        context.addLine(to: linePoints[1])
        
        context.move(to: linePoints[2])
        context.addLine(to: linePoints[3])
        // config line style
        context.setLineDash(phase: 0, lengths: [10,10])
        
        context.strokePath()
        // restore state
        context.restoreGState()
    }
}
