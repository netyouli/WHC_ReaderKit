//
//  WHC_ReadBookVC.swift
//  DigitalLibrary
//
//  Created by 吴海超 on 15/12/1.
//  Copyright © 2015年 吴海超. All rights reserved.
//

import UIKit

public class WHC_ReadBookVC: UIViewController , UIPageViewControllerDataSource , UIPageViewControllerDelegate , WHC_BottomMenuViewDelegate , DirectoryViewDelegate {

    
    
    public var bookName: String!;
    public var filePath: String!;
    public var chapterArr: NSArray!;
    public var gotoChapter: String!;
    public var bookId: String!;
    private let kMaxFontSize: CGFloat = 30;
    private let kMinFontSize: CGFloat = 14;
    private let kAnimationTime: NSTimeInterval = 0.5;
    private var defaultPageCharacterCount = 50000;
    private var isShowNavigationBar = true;
    private var currentContentOffset: UInt64 = 0;
    private var pageRangeContentArr = NSMutableArray();
    private var bookContent: NSString!;
    private var chapterRangeDict = NSMutableDictionary();
    
    private var tapGesture: UITapGestureRecognizer!;
    private var pageVC: UIPageViewController!;
    private var calculatePageEnd = false;
    private var doingPageAnimation = false;
    
    private var readRecord: WHC_LookBookRecord!;
    private var currentPageVC: WHC_LookBookVC!;
    private  var bottomMenu: WHC_BottomMenuView!;
    private  var backView: UIView!;
    private  var isAdjustingFont = false;
    @IBOutlet var bottomView: UIView!;
    @IBOutlet var fastReaderBar: UISlider!;
    @IBOutlet var buttonBackView: UIView!;
    @IBOutlet var addBookmarkButton: UIButton!;
    @IBOutlet var settingButton: UIButton!;
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.initData();
        self.layoutUI();
        // Do any additional setup after loading the view.
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initData() {
        self.view.backgroundColor = UIColor.whiteColor();
        readRecord = WHC_LookBookRecord.readDiskCache(bookId);
        if readRecord == nil {
            readRecord = WHC_LookBookRecord();
            readRecord.chapterName = chapterArr[0] as! String;
            readRecord.chapterArr = chapterArr
        }
        readRecord.bookName = bookName;
        readRecord.bookId = bookId;
        self.title = bookName;
        self.calculateDefaultPageCharacterCount();
        self.tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleShowBottomView:"));
        self.view.addGestureRecognizer(tapGesture);
        self.view.startLoading();
        dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
            do {
                let bookData = try NSData(contentsOfFile: self.filePath, options: .DataReadingMappedIfSafe);
                self.bookContent = NSString(data: bookData, encoding: NSUTF8StringEncoding)
                self.calculateBookSumPageNumber();
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.view.stopLoading();
                    for chapter in self.chapterArr {
                        let range = self.bookContent.rangeOfString(chapter as! String);
                        self.chapterRangeDict.setObject(NSValue(range: range), forKey: chapter as! String);
                    }
                    self.fastReaderBar.value = Float(self.readRecord.page) / Float(self.pageRangeContentArr.count);
                    self.createPageVC();
                    if self.gotoChapter != nil {
                        self.directoryViewSelected(self.gotoChapter);
                    }
                })
            }catch {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                    (Int64)(3 * NSEC_PER_SEC)),
                    dispatch_get_main_queue(),{ () -> Void in
                    self.showNvBar();
                    self.view.toast("加载本地图书失败")
                    self.clickLeftItem(nil);
                })
            }
        }

    }
    
    private func layoutUI() {
        self.installNavigationBarLeftItem(title: "返回");
        self.installNavigationBarRightItem(title: "目录");
        self.hideNvBar();
        self.bottomView.setWidth(CGRectGetWidth(UIScreen.mainScreen().bounds));
        self.bottomView.autoHoriAdapter();
        self.bottomView.backgroundColor = UIColor(white: 0.6, alpha: 0.8);
        buttonBackView.layer.cornerRadius = 5;
        buttonBackView.layer.borderColor = WHC_LookBookRecord.colorR(20, g: 20, b: 20).CGColor;
        buttonBackView.layer.borderWidth = 1;
    }
    
    func installNavigationBarLeftItem(title title: String){
        self.installNavigationBarItem(title: title, imageName: nil, isLeft: true);
    }
    
    func installNavigationBarRightItem(imageName imageName: String){
        self.installNavigationBarItem(title: nil, imageName: imageName, isLeft: false);
    }
    
    func installNavigationBarRightItem(title title: String) {
        self.installNavigationBarItem(title: title, imageName: nil, isLeft: false);
    }
    
    func installNavigationBarItem(var title title: String? , imageName: String? , isLeft: Bool){
        if title == nil{
            title = "";
        }
        var funcName = "clickLeftItem:";
        if !isLeft {
            funcName = "clickRightItem:";
        }
        let item = UIBarButtonItem(title: title!, style: UIBarButtonItemStyle.Plain, target: self, action: Selector(funcName));
        if imageName != nil && imageName?.characters.count > 0 {
            item.image = UIImage(named: imageName!);
        }
        if isLeft {
            self.navigationItem.hidesBackButton = true;
            self.navigationItem.leftBarButtonItem = item;
        }else{
            self.navigationItem.rightBarButtonItem = item;
        }
    }
    //MARK: - 事件响应处理
    
    @IBAction func clickAddBookmark(sender: UIButton) {
        try! readRecord.writeDiskCache();
        self.view.toast("添加书签成功");
    }
    
    @IBAction func clickSetting(sender: UIButton) {
        self.createBackView();
        bottomMenu = WHC_BottomMenuView.showBottomMenuView(self);
        bottomMenu.setInitValue(readRecord);
    }
    
    @IBAction func changeFastReaderBar(sender: UISlider) {
        var page = Int(sender.value * Float(pageRangeContentArr.count));
        if page == 0 {
            page = 1;
        }
        readRecord.page = page;
        self.updateCurrentPage();
    }
    
    func tapBackView(tapGesture: UITapGestureRecognizer!) {
        UIView.animateWithDuration(kAnimationTime, delay: 0,
                                  usingSpringWithDamping: 0.5,
                                  initialSpringVelocity: 0.5,
                                  options: UIViewAnimationOptions.CurveEaseOut,
                                  animations: { () -> Void in
            self.bottomMenu.setY(CGRectGetHeight(UIScreen.mainScreen().bounds));
            self.backView.alpha = 0.0;
            }) { (finished) -> Void in
                self.backView.removeGestureRecognizer(self.tapGesture);
                self.backView.removeFromSuperview();
                self.bottomMenu.removeFromSuperview();
                self.backView = nil;
                self.bottomMenu = nil;
        }
    }

    
    func clickLeftItem(sender: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func clickRightItem(sender: UIBarButtonItem) {
        let directoryVC = WHC_DirectoryVC(nibName: "WHC_DirectoryVC");
        directoryVC.chapterArr = chapterArr;
        directoryVC.directoryViewDelegate = self;
        directoryVC.isScan = false;
        let nv = UINavigationController(rootViewController: directoryVC);
        nv.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor;
        nv.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor;
        self.presentViewController(nv, animated: true) { () -> Void in
        }
    }
    
    //MARK:  - DirectoryViewDelegate
    func directoryViewSelected(chapter: String) {
        readRecord.chapterName = chapter;
        let range = chapterRangeDict[chapter]?.rangeValue;
        for (pageIndex , value) in pageRangeContentArr.enumerate() {
            let contentRange = value.rangeValue;
            if range?.location > contentRange.location &&
                range?.location < contentRange.location + contentRange.length {
                    readRecord.page = pageIndex + 1;
                    break;
            }
        }
        fastReaderBar.value = Float(readRecord.page) / Float(pageRangeContentArr.count);
        self.updateCurrentPage();
    }
    
    //MARK: - 私有UI处理
    
    private func updateCurrentPage() {
        self.makeChapterName(readRecord.page);
        if readRecord.page > pageRangeContentArr.count {
            readRecord.page = pageRangeContentArr.count;
        }
        self.currentPageVC.totalPage = pageRangeContentArr.count;
        self.currentPageVC.currentPage = readRecord.page;
        self.currentPageVC.chapterName = readRecord.chapterName;
        self.currentPageVC.pageContent = self.content(readRecord.page);
    }
    
    private func createPageVC() {
        self.pageVC = UIPageViewController(transitionStyle: readRecord.pageMode, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil);
        self.pageVC.view.backgroundColor = UIColor.clearColor();
        self.pageVC.delegate = self;
        self.pageVC.dataSource = self;
        self.addChildViewController(self.pageVC);
        self.view.addSubview(self.pageVC.view);
        self.currentPageVC = self.makeLookBookVC(readRecord.page);
        self.pageVC.setViewControllers([self.currentPageVC], direction: .Forward, animated: false, completion: nil);
    }
    
    private func createBottomView() {
        
    }
    
    private func createBackView() {
        tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapBackView:"));
        backView = UIView(frame: UIScreen.mainScreen().bounds);
        backView.backgroundColor = UIColor.blackColor();
        backView.alpha = 0.3;
        backView.addGestureRecognizer(tapGesture);
        UIApplication.sharedApplication().delegate?.window??.addSubview(backView);
    }
    
    func hideNavigationBar(){
        self.navigationController?.navigationBarHidden = true;
    }
    
    func showNavigationBar(){
        self.navigationController?.navigationBarHidden = false;
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return !isShowNavigationBar;
    }
    
    private func showNvBar() {
        isShowNavigationBar = true;
        self.showNavigationBar();
        UIApplication.sharedApplication().setStatusBarHidden(!isShowNavigationBar, withAnimation: .Fade);
        self.showBottomView();
    }
    
    private func hideNvBar() {
        isShowNavigationBar = false;
        self.hideNavigationBar();
        UIApplication.sharedApplication().setStatusBarHidden(!isShowNavigationBar, withAnimation: .Fade);
        self.hideBottomView();
    }
    
    private func showBottomView() {
        if bottomView != nil {
            if !self.view.subviews.contains(bottomView) {
                bottomView.setXy(CGPointMake(0, CGRectGetHeight(UIScreen.mainScreen().bounds)));
                self.view.addSubview(bottomView);
                UIView.animateWithDuration(kAnimationTime, animations: { () -> Void in
                    self.bottomView.setY(CGRectGetHeight(UIScreen.mainScreen().bounds) - self.bottomView.height())
                    }, completion: { (finished) -> Void in
                        
                })
            }
        }
    }
    
    private func hideBottomView() {
        if bottomView != nil {
            if self.view.subviews.contains(bottomView) {
                UIView.animateWithDuration(kAnimationTime, animations: { () -> Void in
                    self.bottomView.setY(CGRectGetHeight(UIScreen.mainScreen().bounds))
                    }, completion: { (finished) -> Void in
                        self.bottomView.removeFromSuperview();
                })
            }
        }
    }
    
    func handleShowBottomView(tapGesture: UITapGestureRecognizer) {
        if readRecord.pageMode == .Scroll {
            let point = tapGesture.locationInView(tapGesture.view)
            if CGRectContainsPoint(CGRectMake(0, 0, 100, CGRectGetHeight(UIScreen.mainScreen().bounds)), point) {
                // 向前翻页
                if readRecord.page > 1 {
                    readRecord.page--;
                }else {
                    self.view.toast("已经是第一页了");
                    return;
                }
            }else if CGRectContainsPoint(CGRectMake(CGRectGetWidth(UIScreen.mainScreen().bounds) - 100, 0, 100, CGRectGetHeight(UIScreen.mainScreen().bounds)), point) {
                // 向后翻页
                if readRecord.page < pageRangeContentArr.count {
                    readRecord.page++;
                }else {
                    self.view.toast("已经是最后一页了");
                    return ;
                }
            }else {
                if !doingPageAnimation {
                    if isShowNavigationBar {
                        self.hideNvBar();
                    }else {
                        self.showNvBar();
                    }
                }
            }
        }else {
            if !doingPageAnimation {
                if isShowNavigationBar {
                    self.hideNvBar();
                }else {
                    self.showNvBar();
                }
            }
        }
    }
    
    //MARK: - WHC_BottomMenuViewDelegate
    
    func WHCBottomMenuAdjustFontSize(increment: CGFloat) {
        readRecord.fontSize += increment;
        if readRecord.fontSize < kMinFontSize {
            readRecord.fontSize = kMinFontSize;
        }else if readRecord.fontSize > kMaxFontSize {
            readRecord.fontSize = kMaxFontSize;
        }
        self.resetAsyncCalculateBookSumPageNumber();
    }
    
    func WHCBottomMenuAdjustbrighten(increment: CGFloat) {
        readRecord.brightness = increment;
        self.currentPageVC.backgroundColor(WHC_LookBookRecord.backgroundColor(readRecord.colorMode, brightness: readRecord.brightness));
        if readRecord.colorMode == .Black {
            self.updateCurrentPage();
        }
    }
    
    func WHCBottomMenuAdjustColorMode(mode: WHCBottomMenuColorMode) {
        readRecord.colorMode = mode;
        let backColor = WHC_LookBookRecord.backgroundColor(readRecord.colorMode, brightness: readRecord.brightness);
        self.currentPageVC.backgroundColor(backColor);
        self.updateCurrentPage();
    }
    
    func WHCBottomMenuAdjustPageMode(mode: UIPageViewControllerTransitionStyle) {
        if readRecord.pageMode != mode {
            readRecord.pageMode = mode;
            self.hideNvBar();
            self.pageVC.removeFromParentViewController();
            self.pageVC.view.removeFromSuperview();
            self.pageVC = nil;
            self.createPageVC();
            self.view.bringSubviewToFront(bottomView);
        }
    }
    
    //MARK: - 小说解析模块
    
    private func makeChapterName(page: Int) {
        let  currentContentRange = pageRangeContentArr[page - 1].rangeValue;
        for (chapterIndex , tempChapter) in chapterArr.enumerate() {
            let chapter = tempChapter as! String;
            let nextChapter = chapterArr[(chapterIndex + 1 >= chapterArr.count ? chapterIndex : chapterIndex + 1)] as! String;
            let range = chapterRangeDict[chapter]?.rangeValue;
            let nextRange = chapterRangeDict[nextChapter]?.rangeValue;
            if (currentContentRange.location > range?.location &&
                currentContentRange.location < nextRange?.location) ||
                (chapterIndex + 1 >= chapterArr.count ||
                    currentContentRange.location == 0) {
                        readRecord.chapterName = chapter;
                        break;
            }
        }
    }
    
    private func makeLookBookVC(page: Int) -> WHC_LookBookVC! {
        self.makeChapterName(page);
        let lookVC = WHC_LookBookVC();
        lookVC.view.backgroundColor = WHC_LookBookRecord.backgroundColor(readRecord.colorMode,
                                        brightness: readRecord.brightness);
        lookVC.currentPage = page;
        lookVC.totalPage = pageRangeContentArr.count;
        lookVC.chapterName = readRecord.chapterName;
        lookVC.pageContent = self.content(page);
        return lookVC;
    }
    
    private func content(page: Int) -> NSMutableAttributedString! {
        let pageRange = (pageRangeContentArr[page - 1] as! NSValue).rangeValue;
        let pageContent = bookContent.substringWithRange(pageRange) as String;
        let attrString = NSMutableAttributedString(string: pageContent);
        attrString.setAttributes(self.contentAttribute(readRecord.fontSize), range: NSMakeRange(0, attrString.length));
        return attrString;
    }
    
    private func contentOffset(offset: UInt64) -> String! {
        let intOffset = Int(offset);
        if intOffset >= bookContent.length {
            calculatePageEnd = true;
            return "";
        }else if intOffset + defaultPageCharacterCount >= bookContent.length {
            let endPageCharacterCount = bookContent.length - intOffset;
            return bookContent.substringWithRange(NSMakeRange(intOffset , endPageCharacterCount)) as String;
        }
        return bookContent.substringWithRange(NSMakeRange(intOffset , defaultPageCharacterCount)) as String;
    }
    
    private func contentAttribute(fontSize: CGFloat) -> [String: AnyObject]! {
        let font = UIFont.systemFontOfSize(fontSize);
        let paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.lineSpacing = font.pointSize / 2;
        paragraphStyle.alignment = .Natural;
        return [NSParagraphStyleAttributeName: paragraphStyle,
                NSFontAttributeName: font ,
                NSForegroundColorAttributeName: WHC_LookBookRecord.fontColor(readRecord.colorMode, brightness: readRecord.brightness)];
    }
    
    private func calculateDefaultPageCharacterCount() {
        let defaultRowCharacterCount = Int(CGRectGetWidth(UIScreen.mainScreen().bounds) / readRecord.fontSize);
        let defaultColumnCharacterCount = Int((CGRectGetHeight(UIScreen.mainScreen().bounds) - WHC_LookBookVC.kPading * 2) / (readRecord.fontSize * 1.5));
        defaultPageCharacterCount = defaultRowCharacterCount * defaultColumnCharacterCount;
    }
    
    private func calculateBookSumPageNumber() {
        let contentAttr = self.contentAttribute(readRecord.fontSize);
        let currentOffsetContent = String(self.bookContent);
        let contentAttrString = NSMutableAttributedString(string: currentOffsetContent);
        contentAttrString.setAttributes(contentAttr, range: NSMakeRange(0, contentAttrString.length));
        let frameSetter = CTFramesetterCreateWithAttributedString(contentAttrString);
        let path = CGPathCreateWithRect(CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds) - WHC_LookBookVC.kPading * 2, CGRectGetHeight(UIScreen.mainScreen().bounds) - WHC_LookBookVC.kPading * 4), nil);
        while !calculatePageEnd {
            let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(Int(currentContentOffset), 0), path, nil);
            let range = CTFrameGetVisibleStringRange(frame);
            let pageRange = NSMakeRange(Int(currentContentOffset), range.length);
            pageRangeContentArr.addObject(NSValue(range: pageRange));
            if ((range.location + range.length) != contentAttrString.length){
                currentContentOffset += UInt64(range.length)
            }else {
                calculatePageEnd = true;
                currentContentOffset += UInt64(range.length);
            }
        }
    }
    
    private func resetAsyncCalculateBookSumPageNumber() {
        if self.isAdjustingFont {
            return;
        }
        self.isAdjustingFont = true;
        self.view.startLoading();
        self.calculatePageEnd = false;
        self.pageRangeContentArr.removeAllObjects();
        self.currentContentOffset = 0;
        dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
            self.calculateBookSumPageNumber();
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.isAdjustingFont = false;
                self.view.stopLoading();
                self.updateCurrentPage();
            })
        }
    }
    
    private func updateProgressUI(VC: UIViewController) {
        let lookBookVC = VC as! WHC_LookBookVC;
        currentPageVC = nil;
        currentPageVC = lookBookVC;
        fastReaderBar.value = Float(lookBookVC.currentPage) / Float(pageRangeContentArr.count);
        readRecord.page = lookBookVC.currentPage;
    }
    
    //MARK: - UIPageViewControllerDelegate
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let beforeLookVC: WHC_LookBookVC = viewController as! WHC_LookBookVC;
        beforeLookVC.stopUpdateTime();
        if beforeLookVC.currentPage == 1 {
            self.view.toast("已经是第一页了");
            doingPageAnimation = false;
            return nil;
        }
        doingPageAnimation = true;
        let lookVC = self.makeLookBookVC(beforeLookVC.currentPage - 1);
        return lookVC;
    }
    
    public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        self.updateProgressUI(pendingViewControllers[0]);
        doingPageAnimation = false;
        if readRecord.pageMode == .Scroll {
            
        }
    }
    
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        doingPageAnimation = false;
        if completed {
        }else {
            self.updateProgressUI(previousViewControllers[0]);
        }
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let afterLookVC: WHC_LookBookVC = viewController as! WHC_LookBookVC;
        afterLookVC.stopUpdateTime();
        if afterLookVC.currentPage >= pageRangeContentArr.count {
            self.view.toast("已经是最后一页了");
            doingPageAnimation = false;
            return nil;
        }
        doingPageAnimation = true;
        let lookVC = self.makeLookBookVC(afterLookVC.currentPage + 1);
        return lookVC;
    }
}
