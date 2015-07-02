//
//  BubbleView.swift
//  QQbubbleWithSwift
//
//  Created by xinglei on 15/7/1.
//  Copyright (c) 2015年 ZPlay. All rights reserved.
//

import UIKit

class BubbleView: UIView {
    
    //    父视图
    var containerView = UIView()
    //    需要隐藏气泡时候可以使用这个属性：self.frontView.hidden = YES;
    var frontView = UIView()
    //    最终球
    var endBubbleView = UIView()
    //
    var backView = UIView()
    //    气泡上显示数字的label
    var bubbleLabel = UILabel()
    //    气泡颜色
    var bubbleColor : UIColor
    //    贝塞尔曲线
    var cutePath = UIBezierPath()
    //    突然的行为（变换）
//    var snap = UISnapBehavior()
    //    填充颜色
    var fillColorForCute = UIColor()
    //    指示器
    var animator = UIDynamicAnimator()
    //    形状属性
    var shapeLayer = CAShapeLayer()
    //    气泡的直径
    var bubbleWidth : CGFloat = 0
    //    气泡粘性系数，越大可以拉得越长
    var viscosity : CGFloat = 0
    
    var r1 : CGFloat = 0 //backView
    var r2 : CGFloat = 0 // frontView
    var x1 : CGFloat = 0
    var y1 : CGFloat = 0
    var x2 : CGFloat = 0
    var y2 : CGFloat = 0
    //    两个球中心点的距离
    var centerDistance : CGFloat = 0
    var cosDigree : CGFloat = 0
    var sinDigree : CGFloat = 0
    // 点坐标
    var pointA = CGPoint() //B
    var pointB = CGPoint() //B
    var pointD = CGPoint() //D
    var pointC = CGPoint() //C
    var pointO = CGPoint() //O
    var pointP = CGPoint() //P
    //  下方球一开始球的位置
    var oldBackViewFrame = CGRect()
    //  上方球一开始位置
    var initialPoint = CGPoint()
    //   下方球的center
    var oldBackViewCenter = CGPoint()
    
    init(frame:CGRect, point: CGPoint, superView:UIView){
        //       在调用super.init时 必须全员初始化
        bubbleColor = UIColor.blackColor()
        super.init(frame: frame)
        self.frame = CGRectMake(point.x, point.y, self.bubbleWidth, self.bubbleWidth)
        initialPoint = point
        self.containerView = superView
        self.containerView.addSubview(self)
        self.setUp()
        self.addGesture()
    }
    //    组装
    func setUp(){
        //  球的形状
        shapeLayer = CAShapeLayer(layer: layer)
        //  本身颜色为透明
        backgroundColor = UIColor.clearColor()
        //  上方球位置
        frontView = UIView(frame: CGRectMake(initialPoint.x,initialPoint.y, bubbleWidth,bubbleWidth))
        //   上方球半径
        r2 = frontView.bounds.size.width/2
        //    上方球变为真正的圆球™
        frontView.layer.cornerRadius = r2
        //    设定上方球颜色
        frontView.backgroundColor = bubbleColor
        //    设定下方球与上方球重合
        backView = UIView(frame: frontView.frame)
        r1 = backView.bounds.size.width/2
        backView.layer.cornerRadius = r1
        backView.backgroundColor = bubbleColor
        //    上方球上添加一个label
        bubbleLabel = UILabel(frame: CGRectMake(0, 0, frontView.bounds.size.width, frontView.bounds.size.height))
        bubbleLabel.textColor = UIColor.whiteColor()
        bubbleLabel.textAlignment = NSTextAlignment.Center
        frontView.insertSubview(bubbleLabel, atIndex: 0)
        
        containerView.addSubview(backView)
        containerView.addSubview(frontView)
        
        x1 = backView.center.x //下方球中心点x坐标
        y1 = backView.center.y
        x2 = self.frontView.center.x
        y2 = self.frontView.center.y
        
        pointA = CGPointMake(x1-r1,y1);   // A
        pointB = CGPointMake(x1+r1, y1);  // B
        pointD = CGPointMake(x2-r2, y2);  // D
        pointC = CGPointMake(x2+r2, y2);  // C
        pointO = CGPointMake(x1-r1,y1);   // O
        pointP = CGPointMake(x2+r2, y2);  // P
        //        下方球一开始位置
        oldBackViewFrame = backView.frame;
        oldBackViewCenter = backView.center;
        
        //为了看到frontView的气泡晃动效果，需要展示隐藏backView
        backView.hidden = true
    }
    //    添加手势
    func addGesture(){
        var pan = UIPanGestureRecognizer(target: self, action: "dragMe:")
        frontView.addGestureRecognizer(pan)
    }
    //    拖动触发方法
    func dragMe(ges:UIPanGestureRecognizer){
        //        拖拽位置
        var dragPoint = CGPoint()
        //         拖拽位置是cotainer视图上的位置
        dragPoint = ges.locationInView(containerView)
        //        拖拽开始时
        if(ges.state == UIGestureRecognizerState.Began){
            //            下方隐藏
            backView.hidden = false
            fillColorForCute = bubbleColor
            //            移除frontView（上方小球上的动画）
            self.removeAniamtionLikeGameCenterBubble()
        }else if(ges.state == UIGestureRecognizerState.Changed){
            //            上方小球随着拖拽改变位置
            frontView.center = dragPoint
            //            如果backView的半径小于6
            if(6>=r1){
                fillColorForCute = UIColor.clearColor()
                backView.hidden = true
                shapeLayer.removeFromSuperlayer()
            }
            //            拖拽结束时
        }else if(ges.state == UIGestureRecognizerState.Ended || ges.state == UIGestureRecognizerState.Cancelled || ges.state == UIGestureRecognizerState.Failed){
            backView.hidden = true
            fillColorForCute = UIColor.clearColor()
            shapeLayer.removeFromSuperlayer()
//            duration
//            表示动画执行时间。
//            delay
//            动画延迟时间。
//            usingSpringWithDamping
//            表示弹性属性。
//            initialSpringVelocity
//            初速度。
//            options
//            可选项，一些可选的动画效果，包括重复等。
//            animations
//            表示执行的动画内容，包括透明度的渐变，移动，缩放。
//            completion
//            表示执行完动画后执行的内容。
            UIView.animateWithDuration(0.5, delay: 0.0,usingSpringWithDamping: 0.4,initialSpringVelocity: 0.0,options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                //                赋予上方小球动画
                self.frontView.center = self.oldBackViewCenter
            }, completion: { (Bool) -> Void in
                //                像气泡一样消失
                self.AddAniamtionLikeGameCenterBubble()
            })
        }
        //        定时器
        self.displayLinkAction()
    }
    
    //----类似GameCenter的气泡晃动动画------
    func AddAniamtionLikeGameCenterBubble(){
        //        创建一个CAKeyframeAnimation
        var pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.repeatCount = 10000
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        var curvedPath : CGMutablePathRef
        curvedPath = CGPathCreateMutable()
        var circleContainer = CGRectInset(frontView.frame, frontView.bounds.size.width/2-3, frontView.bounds.size.width/2-3)
        CGPathAddEllipseInRect(curvedPath, nil, circleContainer)
        
        pathAnimation.path = curvedPath
        frontView.layer.addAnimation(pathAnimation, forKey: "myCircleAnimation")
        
        var scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.duration = 1
        scaleX.values = [1.0,1.1,1.0]
        scaleX.keyTimes = [0.0,0.5,1.0]
        scaleX.repeatCount = 10000
        scaleX.autoreverses = true
        scaleX.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        frontView.layer.addAnimation(scaleX, forKey: "scaleXAnimation")
        
        var scaleY = CAKeyframeAnimation(keyPath:"transform.scale.y");
        scaleY.duration = 1.5;
        scaleY.values = [1.0, 1.1, 1.0];
        scaleY.keyTimes = [0.0, 0.5, 1.0];
        scaleY.repeatCount = 10000;
        scaleY.autoreverses = true;
        scaleX.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        frontView.layer.addAnimation(scaleY, forKey:"scaleYAnimation")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //每隔一帧刷新屏幕的定时器
    func displayLinkAction(){
        
        x1 = backView.center.x //下方小球中心点x坐标
        y1 = backView.center.y
        x2 = frontView.center.x //上方大球中心店x坐标
        y2 = frontView.center.y
        
        // d
        centerDistance = sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
        
        // sin¢ cos¢
        if(0==centerDistance){
            cosDigree = 1
            sinDigree = 0
        }else{
            cosDigree = (y2-y1)/centerDistance
            sinDigree = (x2-x1)/centerDistance
        }
        //        让底下的球半径随着距离的变化变化
        r1 = oldBackViewFrame.size.width / 2 - centerDistance/self.viscosity;

        pointA = CGPointMake(x1-r1*cosDigree, y1+r1*sinDigree)  // A
        pointB = CGPointMake(x1+r1*cosDigree, y1-r1*sinDigree)  // B
        pointD = CGPointMake(x2-r2*cosDigree, y2+r2*sinDigree)  // D
        pointC = CGPointMake(x2+r2*cosDigree, y2-r2*sinDigree)  // C
        pointO = CGPointMake(pointA.x + (centerDistance / 2)*sinDigree, pointA.y + (centerDistance / 2)*cosDigree)
        pointP = CGPointMake(pointB.x + (centerDistance / 2)*sinDigree, pointB.y + (centerDistance / 2)*cosDigree)
        self.drawRect()
    }
    
    func drawRect(){
        
        backView.center = oldBackViewCenter
        backView.bounds = CGRectMake(0, 0, r1*2, r1*2)
        backView.layer.cornerRadius = r1
        
        cutePath = UIBezierPath()
        cutePath.moveToPoint(pointA)
        
//        模仿一个曲线
        cutePath .addQuadCurveToPoint(pointD, controlPoint: pointO)
//        在曲线的末端D添加一个线段c
        cutePath .addLineToPoint(pointC)
//        由c向B点画线
        cutePath .addQuadCurveToPoint(pointB, controlPoint: pointP)
//        最后回到A
        cutePath .moveToPoint(pointA)

        if(backView.hidden==false){
            shapeLayer.path = cutePath.CGPath
            shapeLayer.fillColor = fillColorForCute.CGColor
            containerView.layer.insertSublayer(shapeLayer, below: frontView.layer)
        }
    }
    
    func square(a:CGFloat) ->CGFloat
    {
        return a * a
    }
    
    func removeAniamtionLikeGameCenterBubble(){
        frontView.layer.removeAllAnimations()
    }
}
