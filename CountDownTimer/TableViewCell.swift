//
//  TableViewCell.swift
//  CountDownTimer
//
//  Created by apple on 16/1/3.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    var timer: CADisplayLink?
    var remainTime: Double = 0.0
    
    
    /// 重写setter方法，开启定时器
    var model: Model?{
        didSet{
            
            // 这里需要对外界传入时间增加一秒钟，原因：下面countDown方法中对remainTime取商忽略了小数
            remainTime = model!.remainTime! + 1
            
            countDown() // 在定时器开启之前先显示最初的时间

            if remainTime > 1.0 && timer == nil{
                timer = CADisplayLink(target: self, selector: "countDown")
                timer?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            }
        }
    }
  
    @IBOutlet weak var countDownLabel: UILabel!
    
    /// 定时器调用方法
    func countDown(){

        let hour   = NSInteger(remainTime / 3600)
        let minute = NSInteger((remainTime - Double(3600 * hour)) / 60)
        let second = NSInteger(remainTime - Double(3600 * hour + 60 * minute))
        
        if remainTime <= 1{
            timer?.invalidate()
            timer = nil
            countDownLabel.text = "定时器结束"
            return
        }
        
        countDownLabel.text = String(format: "%02zd:%02zd:%02zd", hour,minute,second)
        
        remainTime -= 1 / 60.0
    }
}
