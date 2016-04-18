//
//  WHC_ReadView.swift
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

class WHC_LookBookView: UIView {

    private var pageContent: NSAttributedString!;
    private var ctFrame: CTFrameRef!;
    private var timer: NSTimer!;
    private var currentTime: NSString!;
    private let kBatteryWidth: CGFloat = 30;
    private let kBatteryStartX: CGFloat = 45;
    private let kBatteryPading: CGFloat = 2;
    private let kBatteryHeight: CGFloat = 14;
    private let kTimeFontSize: CGFloat = 14;
    private var pageInfo: NSString!;
    private var pageInfoWidth: CGFloat = 0;
    private var currentPage = 0;
    private var totalPage = 0;
    private var chapterName: NSString!;
    private var fontColor: UIColor!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.handleUpdateTime();
        UIDevice.currentDevice().batteryMonitoringEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func drawRect(rect: CGRect) {
        if ctFrame != nil {
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let transform = CGAffineTransformMake(1,0,0,-1,0,self.height());
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextConcatCTM(context, transform);
            CTFrameDraw(ctFrame, context!);
            
            CGContextRestoreGState(context);
            CGContextSaveGState(context);
            /// 画章节标题
            chapterName?.drawAtPoint(CGPointMake(0, WHC_LookBookVC.kPading / 2),
                withAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(kTimeFontSize) ,
                    NSForegroundColorAttributeName: UIColor.grayColor()]);
            
            /// 画当前系统时间
            currentTime?.drawAtPoint(CGPointMake(0, self.height() - WHC_LookBookVC.kPading),
                                     withAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(kTimeFontSize) ,
                                        NSForegroundColorAttributeName: UIColor.grayColor()]);
            
            /// 画当前系统电池
            CGContextSetLineWidth(context, 1);
            CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor);
            CGContextSetLineJoin(context, .Round);
            CGContextAddRect(context, CGRectMake(kBatteryStartX,
                                                 self.height() - WHC_LookBookVC.kPading,
                                                 kBatteryWidth,
                                                 kBatteryHeight));
            CGContextDrawPath(context, .Stroke);
            
            /// 画小说内容
            CGContextRestoreGState(context);
            CGContextSaveGState(context);
            CGContextSetFillColorWithColor(context, UIColor(white: 0.0, alpha: 0.3).CGColor);
            let batteryWidth = abs(CGFloat(UIDevice.currentDevice().batteryLevel) * (kBatteryWidth - (2 * kBatteryPading)));
            CGContextAddRect(context, CGRectMake(kBatteryStartX + kBatteryPading,
                                                 self.height() - WHC_LookBookVC.kPading + kBatteryPading,
                                                 CGFloat(batteryWidth),
                                                 kBatteryHeight - 2 * kBatteryPading));
            CGContextDrawPath(context, .Fill);
            
            CGContextRestoreGState(context);
            CGContextSetFillColorWithColor(context, UIColor(white: 0.0, alpha: 0.3).CGColor);
            CGContextMoveToPoint(context, kBatteryStartX + kBatteryWidth,
                                          self.height() - WHC_LookBookVC.kPading + kBatteryHeight / 2);
            CGContextAddArc(context, kBatteryStartX + kBatteryWidth,
                                     self.height() - WHC_LookBookVC.kPading + kBatteryHeight / 2,
                                     3.5,
                                     CGFloat(M_PI_2),
                                     CGFloat(M_PI + M_PI_2),
                                     1);
            CGContextDrawPath(context, .Fill);
    
            /// 画当前阅读页数
            pageInfo.drawAtPoint(CGPointMake(self.width() - pageInfoWidth - WHC_LookBookVC.kPading / 2,
                                 self.height() - WHC_LookBookVC.kPading),
                                 withAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(kTimeFontSize),
                                 NSForegroundColorAttributeName: UIColor.grayColor()]);
            
            UIGraphicsEndImageContext();
        }
    }
    
    func renderBookContent(content: NSAttributedString! , pageNumber: Int , totalPage: Int , chapterName: String!) {
        currentPage = pageNumber;
        self.totalPage = totalPage;
        pageContent = content;
        pageInfo = NSString(string: "\(currentPage) / \(totalPage)");
        self.chapterName = NSString(string: chapterName);
        pageInfoWidth = CGRectGetWidth(pageInfo.boundingRectWithSize(CGSizeMake(CGFloat.infinity, WHC_LookBookVC.kPading), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(kTimeFontSize)], context: nil));
        
        let frameSetter = CTFramesetterCreateWithAttributedString(pageContent);
        let path = CGPathCreateWithRect(CGRectMake(0, WHC_LookBookVC.kPading * 2, self.width(), self.height() - 4 * WHC_LookBookVC.kPading), nil);
        if self.ctFrame != nil {
            ctFrame = nil;
        }
        ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil);
        self.startUpdateTime();
        self.setNeedsDisplay();
    }
    
    func handleUpdateTime() {
        let currentDate = NSDate();
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "HH:mm";
        currentTime = NSString(string: dateFormatter.stringFromDate(currentDate));
        self.setNeedsDisplay();
    }
    
    func startUpdateTime() {
        self.stopUpdateTime();
        timer = NSTimer(timeInterval: 60, target: self, selector: Selector("handleUpdateTime"), userInfo: nil, repeats: true);
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes);
    }
    
    func stopUpdateTime() {
        timer?.invalidate();
        timer?.fire();
        timer = nil;
    }
}
