//
//  WHC_BottomMenuView.swift
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

enum WHCBottomMenuColorMode: Int {
    case Gray
    case Yellow
    case Green
    case Black
}

protocol WHC_BottomMenuViewDelegate {
    func WHCBottomMenuAdjustFontSize(increment: CGFloat);
    func WHCBottomMenuAdjustbrighten(increment: CGFloat);
    func WHCBottomMenuAdjustColorMode(mode: WHCBottomMenuColorMode);
    func WHCBottomMenuAdjustPageMode(mode: UIPageViewControllerTransitionStyle);
}

class WHC_BottomMenuView: UIView {

    private var backView: UIView!;
    var bottomMenuDelegate: WHC_BottomMenuViewDelegate!;
    
    @IBOutlet var brightenBar: UISlider!;
    @IBOutlet var addFontButton: UIButton!;
    @IBOutlet var decFontButton: UIButton!;
    @IBOutlet var fontBackView: UIView!;
    @IBOutlet var colorModeView: UIView!;
    @IBOutlet var segmentCtrl: UISegmentedControl!;
    @IBOutlet var sunImageView: UIImageView!;
    
    private   var colorModeArr = [WHC_LookBookRecord.colorR(217, g: 217, b: 217),
                                  WHC_LookBookRecord.colorR(241, g: 235, b: 207),
                                  WHC_LookBookRecord.colorR(183, g: 225, b: 198),
                                  WHC_LookBookRecord.colorR(35, g: 35, b: 35)];
    
    private   var colorModeButtons = [UIButton]();
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        self.layoutUI();
    }
    
    private func layoutUI() {
        self.setWidth(CGRectGetWidth(UIScreen.mainScreen().bounds));
        self.autoHoriAdapter();
        fontBackView.layer.cornerRadius = 5;
        fontBackView.layer.borderColor = WHC_LookBookRecord.colorR(20, g: 20, b: 20).CGColor;
        fontBackView.layer.borderWidth = 1;
        
        let buttonCount = CGFloat(colorModeArr.count);
        var buttonPad: CGFloat = 20;
        var buttonSize = (colorModeView.width() - (buttonCount - 1) * buttonPad) / (buttonCount - 1);
        if buttonSize > colorModeView.height() {
            buttonSize = colorModeView.height();
        }
        let offset = (colorModeView.width() - buttonSize * buttonCount) - buttonPad * (buttonCount - 1);
        buttonPad += offset / (buttonCount - 1);
        
        for i in 0...Int(buttonCount - 1) {
            let modeButton = UIButton(type: .Custom);
            modeButton.frame = CGRectMake(CGFloat(i) * (buttonSize + buttonPad),
                                         (colorModeView.height() - buttonSize) / 2,
                                         buttonSize,
                                         buttonSize);
            modeButton.layer.cornerRadius = buttonSize / 2;
            modeButton.layer.borderColor = UIColor.clearColor().CGColor;
            modeButton.layer.borderWidth = 2;
            modeButton.backgroundColor = colorModeArr[i];
            modeButton.tag = i;
            modeButton.addTarget(self, action: Selector("clickColorMode:"), forControlEvents: .TouchUpInside);
            if i == 0 {
                modeButton.layer.borderColor = UIColor.greenColor().CGColor;
            }
            colorModeView.addSubview(modeButton);
            colorModeButtons.append(modeButton);
        }
        segmentCtrl?.setHeight(50);
        segmentCtrl?.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(20)], forState: .Normal);
    }
    
    @IBAction func clickAddFont(sender: UIButton) {
        bottomMenuDelegate?.WHCBottomMenuAdjustFontSize(1);
    }
    
    @IBAction func clickDecFont(sender: UIButton) {
        bottomMenuDelegate?.WHCBottomMenuAdjustFontSize(-1);
    }
    
    @IBAction func changeBrightenBar(sender: UISlider) {
        let value = CGFloat(sender.value);
        let angle = value * CGFloat(M_PI) * 2;
        let rotate = CGAffineTransformMakeRotation(angle);
        sunImageView.transform = rotate;
        bottomMenuDelegate?.WHCBottomMenuAdjustbrighten(value);
    }
    
    @IBAction func changeSegment(sender: UISegmentedControl) {
        var pageMode = UIPageViewControllerTransitionStyle.PageCurl;
        if sender.selectedSegmentIndex == 1 {
            pageMode = UIPageViewControllerTransitionStyle.Scroll;
        }
        bottomMenuDelegate?.WHCBottomMenuAdjustPageMode(pageMode);
    }
    
    func clickColorMode(sender: UIButton) {
        for button in colorModeButtons {
            button.layer.borderColor = UIColor.clearColor().CGColor;
        }
        sender.layer.borderColor = UIColor.greenColor().CGColor;
        var colorMode: WHCBottomMenuColorMode!;
        switch sender.tag {
        case 0:
            colorMode = .Gray;
        case 1:
            colorMode = .Yellow;
        case 2:
            colorMode = .Green;
        case 3:
            colorMode = .Black;
        default:
            break;
        }
        bottomMenuDelegate?.WHCBottomMenuAdjustColorMode(colorMode);
    }
    
    func setInitValue(readRecord: WHC_LookBookRecord) {
        brightenBar.value = Float(readRecord.brightness);
        var tag = 0;
        switch readRecord.colorMode {
            case .Gray:
                tag = 0;
            case .Yellow:
                tag = 1;
            case .Green:
                tag = 2
            case .Black:
                tag = 3;
        }
        for button in colorModeButtons {
            button.layer.borderColor = UIColor.clearColor().CGColor;
        }
        colorModeButtons[tag].layer.borderColor = UIColor.greenColor().CGColor;
        if readRecord.pageMode == .Scroll {
            segmentCtrl?.selectedSegmentIndex = 1;
        }else {
            segmentCtrl?.selectedSegmentIndex = 0;
        }
    }
    
    class func showBottomMenuView(delegate: WHC_BottomMenuViewDelegate) -> WHC_BottomMenuView! {
        let bottomMenuView = (NSBundle.mainBundle().loadNibNamed("WHC_BottomMenuView", owner: nil, options: nil)[0]) as! WHC_BottomMenuView;
        bottomMenuView.bottomMenuDelegate = delegate;
        bottomMenuView.setXy(CGPointMake(CGRectGetWidth(UIScreen.mainScreen().bounds) - bottomMenuView.width(), CGRectGetHeight(UIScreen.mainScreen().bounds)));
        UIApplication.sharedApplication().delegate?.window??.addSubview(bottomMenuView);
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            bottomMenuView.setY(CGRectGetHeight(UIScreen.mainScreen().bounds) - bottomMenuView.height() + 20);
            }) { (finished) -> Void in
        }
        return bottomMenuView;
    }

}
