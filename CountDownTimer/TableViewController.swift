//
//  TableViewController.swift
//  CountDownTimer
//
//  Created by apple on 16/1/3.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var timer: CADisplayLink?  // 定时器
    
    /// 懒加载数组，装的是模型
    lazy var lists: [Model]? = {
        return [Model]()
    }()
    
    /// 字典，value是倒计时剩余时间
    lazy var timerDic: [String: Double]? = {
        return [String: Double]()
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100
    }
    
    // MARK: - 模拟发出网络请求
    
    @IBAction func networkRequest(sender: UIBarButtonItem) {
        lists?.removeAll()
        timerDic?.removeAll()
        
        for var i in 1...25{
            
            let model = Model()
            let count = i % 2 == 0 ? 1 : 0
            model.remainTime = Double(count) * Double(i) * 10.0
            model.symbol = "\(i)"
            
            lists?.append(model)
            
            // remainTime大于0，则添加到字典中
            if count == 1{
                timerDic![model.symbol!] = model.remainTime
            }
        }
        
        if timerDic?.count > 0{
            startBackgroundTimer()
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: - 定时器相关方法
    
    /// 在指定线程开启定时器
    func startBackgroundTimer(){
        performSelector("startTimer", onThread: startBackgroundThread(), withObject: nil, waitUntilDone: false)
    }
    
    /// 开启定时器
    func startTimer(){
        if timer != nil{
            return
        }
        
        timer = CADisplayLink(target: self, selector: "countDown")
        timer?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    /// 定时器调用方法
    func countDown(){
        if timerDic?.count == 0{
            timer?.invalidate()
            return
        }
        
        // 对字典中得每一个对象value值递减，若value小于0则删除该键值对
        for (k,v) in timerDic!{
            if v > 0{
                timerDic?.updateValue(v - 1 / 60.0, forKey: k)
                
            }else{
                timerDic?.removeValueForKey(k)
            }
        }
    }
    
    
    private let startBackgroundThreadKey = "startBackgroundThreadKey"
    
    /// 创建后台线程
    func startBackgroundThread() -> NSThread{
        var thread = objc_getAssociatedObject(self, startBackgroundThreadKey)
        
        if thread == nil{
            thread = NSThread(target: self, selector: "startBackgroundRunloop", object: nil)
            thread.start()
            objc_setAssociatedObject(self, startBackgroundThreadKey, thread, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return thread! as! NSThread
    }
    
    /// 创建后台线程对应的runloop
    func startBackgroundRunloop(){
        let runloop = NSRunLoop.currentRunLoop()
        runloop.addPort(NSPort(), forMode: NSDefaultRunLoopMode)
        runloop.run()
    }
    
}

// MARK: - 扩展 - 表格视图代理方法
extension TableViewController{
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (lists?.count)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell") as? TableViewCell
        
        cell?.backgroundColor = indexPath.row % 2 == 0 ? UIColor.orangeColor() : UIColor.grayColor()

        let model = lists![indexPath.row]
        
        // 该方法当表格滑动时会多次调用，不能从模型中直接取值（因为模型中的remainTime是固定的）
        if model.remainTime > 0{
            if let value = timerDic![model.symbol!]{
                model.remainTime = value
            }
        }
        
        cell!.model = model
        
        return cell!
    }
}
