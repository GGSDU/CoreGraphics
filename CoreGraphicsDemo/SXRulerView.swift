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
    
    override func draw(_ rect: CGRect) {
        drawRuler(rect: rect)
    }
    
    func drawRuler(rect:CGRect) -> Void {
        
        let startPoint : CGPoint = CGPoint(x:100,y:50)
        let endPoint : CGPoint = CGPoint(x:100,y:450)
        let baseWidth : CGFloat = 20
        
        let context : CGContext = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(red: 1.0, green: 0, blue: 0, alpha: 1)
//        ctx.setLineDash(phase: 0, lengths: [10,5])
        
        // 画尺子头
        drawRulerHead(context: context, startPoint: startPoint, triangleWidth: baseWidth, rect: rect, flip: false)
        // 画标尺
        drawRulerBody(context: context, startMiddlePoint: startPoint, endMiddlePoint: endPoint, bodyWidth: baseWidth)
        
        // 画尺子尾
        drawRulerHead(context: context, startPoint: endPoint, triangleWidth: baseWidth, rect: rect, flip: true)
    }
    
    // MARK: 画标尺
    func drawRulerBody(context:CGContext,startMiddlePoint:CGPoint,endMiddlePoint:CGPoint,bodyWidth:CGFloat) -> Void {
        
        // 画外边框(最后要计算的尺度)
        let xDifference = fabsf(Float(startMiddlePoint.x - endMiddlePoint.x))
        let yDifference = fabsf(Float(startMiddlePoint.y - endMiddlePoint.y))
        let bodyHeight = CGFloat(sqrtf(powf(xDifference, 2) + powf(yDifference, 2)))
        let startPoint = CGPoint(x:startMiddlePoint.x - bodyWidth / 2,y:startMiddlePoint.y)
        
        // save state
        context.saveGState()
        
        context.move(to: startPoint)
        context.addRect(CGRect(x:startPoint.x,y:startPoint.y,width:bodyWidth,height:bodyHeight))
        
        context.strokePath()
        // restore state
        context.restoreGState()
        
        
        // 画刻度
        let scale = 5
        var yOffset : Int = 0
        while CGFloat(yOffset) < bodyHeight {
            let mod = (yOffset / scale) % 5
            
            let yPoint2 = startMiddlePoint.y + CGFloat(yOffset)
            let endPoint = CGPoint(x:startMiddlePoint.x + bodyWidth / 2,y:yPoint2)
            if mod == 0 {
                // 画大刻度线(封闭,全宽)
                let scaleMax = CGPoint(x:startPoint.x,y:yPoint2)
                context.move(to: scaleMax)
                context.addLine(to: endPoint)
                context.strokePath()
                
            } else {
                // 画小刻度线(半宽)
                let scaleMin = CGPoint(x:startMiddlePoint.x,y:yPoint2)
                context.move(to: scaleMin)
                context.addLine(to: endPoint)
            }
            
            yOffset += scale;
        }
        
        
    }
    
    // MARK: 画尺子两边
    func drawRulerHead(context:CGContext,startPoint:CGPoint,triangleWidth:CGFloat,rect:CGRect,flip:Bool) -> Void {
        drawTriangle(context: context, startPoint: startPoint, width: triangleWidth,flip: flip)
        drawDash(context: context, middlePoint: startPoint, screenRect: rect)
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
    
    // MARK: 画平行虚线
    func drawDash(context:CGContext,middlePoint:CGPoint,screenRect:CGRect) -> Void {
        
        let maxLineWidth = CGFloat(sqrtf((powf(Float(screenRect.width), 2) + powf(Float(screenRect.height), 2))))
        let linePoint1 = CGPoint(x:middlePoint.x - maxLineWidth,y:middlePoint.y)
        let linePoint2 = CGPoint(x:middlePoint.x + maxLineWidth,y:middlePoint.y)
        // save state
        context.saveGState()
        // draw line
        context.move(to: linePoint1)
        context.addLine(to: linePoint2)
        // config line style
        context.setLineDash(phase: 0, lengths: [10,10])
        
        context.strokePath()
        // restore state
        context.restoreGState()
    }
}
