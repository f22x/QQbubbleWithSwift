//
//  ViewController.swift
//  QQbubbleWithSwift
//
//  Created by xinglei on 15/7/1.
//  Copyright (c) 2015年 ZPlay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var bubbleView : BubbleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bubbleView = BubbleView(frame: view.bounds, point: CGPointMake((view.bounds.size.width-35)/2, 100), superView: view)
        //        粘性
        bubbleView.viscosity = 30
        //        宽度
        bubbleView.bubbleWidth = 35
        bubbleView.bubbleColor = UIColor(red: 0, green: 0.722, blue: 1, alpha: 1)
        bubbleView.setUp()
        bubbleView.addGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

