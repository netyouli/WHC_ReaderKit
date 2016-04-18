//
//  ViewController.swift
//  WHC_ReaderKit
//
//  Created by 吴海超 on 16/4/18.
//  Copyright © 2016年 吴海超. All rights reserved.
//

/*************************************************************
*                                                           *
*  qq:712641411                                             *
*  开发作者: 吴海超(WHC)                                      *
*  iOS技术交流群:302157745                                    *
*  gitHub:https://github.com/netyouli/WHC_ReaderKit    *
*                                                           *
*************************************************************/

import UIKit

class ViewController: UIViewController ,UITableViewDelegate , UITableViewDataSource {

    private var tableView: UITableView!
    private let chapterTitles = ["第一部分  第一章  封存的岁月",
                                "第一部分  第二章  初会",
                                "第一部分  第三章  再入",
                                "第一部分  第四章  大亨",
                                "第一部分  第五章  破冰",
                                "第一部分  第六章  甘尼美第之春",
                                "第一部分  第七章  变迁",
                                "第一部分  第八章  星际舰队",
                                "第一部分  第九章  宙斯峰",
                                "第一部分  第十章  愚人船",
                                "第一部分  第十一章  谎言",
                                "第一部分  第十二章  保罗舅舅",
                                "第一部分  第十三章  “没人提起自备泳装”",
                                "第一部分  第十四章  检索",
                                "第二部分  第十五章  汇合",
                                "第二部分  第十六章  着陆",
                                "第二部分  第十七章  黑雪谷",
                                "第二部分  第十八章  老忠仆",
                                "第二部分  第十九章  隧道尽头",
                                "第二部分  第二十章  召回"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "轻量级小说阅读器架构"
        self.view.backgroundColor = UIColor.whiteColor()
        tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("WHC")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "WHC")
        }
        cell?.textLabel?.text = "2061太空漫游"
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let bookVC = WHC_ReadBookVC(nibName: "WHC_ReadBookVC", bundle: nil)
        bookVC.chapterArr = chapterTitles as NSArray
        bookVC.bookId = "1"
        bookVC.bookName = "2061太空漫游"
        bookVC.filePath = NSBundle.mainBundle().pathForResource("2061太空漫游", ofType: "txt")
        let bookNV = UINavigationController(rootViewController: bookVC)
        self.presentViewController(bookNV, animated: true, completion: nil)
    }
}

