//
//  UIView.swift
//  CoreGraphicsDemo
//
//  Created by Story5 on 3/10/17.
//  Copyright © 2017 Story5. All rights reserved.
//

import Foundation
import UIKit

class SXCoreView: UIView {
    
    
    override func draw(_ rect: CGRect) {

        
        clipRect()
    }
    
    func clipRect() -> Void {
        let ctx : CGContext = UIGraphicsGetCurrentContext()!
        ctx.addRect(CGRect(x:10,y:10,width:50,height:50))
        ctx.addEllipse(in: CGRect(x:100,y:100,width:100,height:100))
        
        ctx.move(to: CGPoint(x:100,y:100))
        ctx.addLine(to: CGPoint(x:200,y:250))
        
        ctx.strokePath()
    }
    
    func drawHeart(rect:CGRect) -> Void {
        let ctx : CGContext = UIGraphicsGetCurrentContext()!
        
        let half : CGFloat = rect.width / 2
        let radius : CGFloat = 50.0
        let centerY : CGFloat = 100.0
        
        let center1X : CGFloat = half - radius
        let center1 : CGPoint = CGPoint(x:center1X,y:centerY)
        
        let center2X : CGFloat = half + radius
        let center2 : CGPoint = CGPoint(x:center2X,y:centerY)
        
        ctx.saveGState()
        
        ctx.setLineWidth(10)
        UIColor.red.setStroke()
        
        ctx.addArc(center: center1, radius: radius, startAngle: CGFloat(M_PI), endAngle: 0, clockwise: false)
        
        ctx.addArc(center: center2, radius: radius, startAngle: CGFloat(M_PI), endAngle: 0, clockwise: false)
        ctx.strokePath()
        
        ctx.restoreGState()
        
        let endPoint :  CGPoint = CGPoint(x:half,y:200)
        let controlXOffset : CGFloat = 90
        let controlY : CGFloat = 150
        
        let startPoint1 : CGPoint = CGPoint(x:center1X - radius,y:centerY)
        let controlPoint1 : CGPoint = CGPoint(x:half - controlXOffset,y:controlY)
        ctx.move(to: startPoint1)
        ctx.addQuadCurve(to: endPoint, control: controlPoint1)
        
        
        let startPoint2 : CGPoint = CGPoint(x:center2X + radius,y:centerY)
        let controlPoint2 : CGPoint = CGPoint(x:half + controlXOffset,y:controlY)
        ctx.move(to: startPoint2)
        ctx.addQuadCurve(to: endPoint, control: controlPoint2)
        
        
        
        ctx.strokePath()
        
    }
    
    func drawArc() -> Void {
        let ctx : CGContext = UIGraphicsGetCurrentContext()!
        
        ctx.addArc(center: CGPoint(x:100,y:100), radius: 50, startAngle: 0, endAngle: 180, clockwise: true)
        
        ctx.strokePath()
    }
    
    func drawCircle() -> Void {
        let ctx :CGContext = UIGraphicsGetCurrentContext()!
        
        ctx.addEllipse(in: CGRect(x:10,y:10,width:100,height:100))
        
        ctx.strokePath()
    }
    
    func draw4Border() -> Void {
        let ctx : CGContext = UIGraphicsGetCurrentContext()!
        
        ctx.addRect(CGRect(x:50,y:50,width:100,height:60))
        
        ctx.fillPath()
        
    }
    
    func drawline() -> Void {
        let ctx : CGContext = UIGraphicsGetCurrentContext()!
        
//        let path : CGMutablePath = CGMutablePath()
//        path.move(to: CGPoint(x:20,y:50))
//        path.addLine(to: CGPoint(x:20,y:100))
//        ctx.addPath(path)
//        
//        ctx.strokePath()
        ctx.move(to: CGPoint(x:10,y:10))
        ctx.addLine(to: CGPoint(x:100,y:10))
            
            
        ctx.strokePath()
    }
}
