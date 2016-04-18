//
//  WHC_LookBookVC.swift
//  DigitalLibrary
//
//  Created by 吴海超 on 15/12/2.
//  Copyright © 2015年 吴海超. All rights reserved.
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

class WHC_LookBookVC: UIViewController {

    static let kPading:CGFloat = 20;
    
    var currentPage = 0;
    var totalPage = 0;
    var chapterName = "";
    var pageContent: NSAttributedString! {
        willSet {
            if lookBookView == nil {
                lookBookView = WHC_LookBookView(frame: CGRectMake(WHC_LookBookVC.kPading,
                                                        0,
                                                        CGRectGetWidth(UIScreen.mainScreen().bounds) - WHC_LookBookVC.kPading * 2.0,
                                                        CGRectGetHeight(UIScreen.mainScreen().bounds)));
                lookBookView.backgroundColor = self.view.backgroundColor;
                self.view.addSubview(lookBookView);
            }
            lookBookView.renderBookContent(newValue, pageNumber: currentPage , totalPage: totalPage , chapterName: chapterName);
        }
    };
    
    private var lookBookView: WHC_LookBookView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopUpdateTime() {
        lookBookView.stopUpdateTime();
    }

    func backgroundColor(color: UIColor) {
        self.view.backgroundColor = color;
        lookBookView.backgroundColor = color;
    }
    
}
