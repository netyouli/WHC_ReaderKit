//
//  WHC_DirectoryVC.swift
//  DingLibrary
//
//  Created by 吴海超 on 15/12/24.
//  Copyright © 2015年 Rudy. All rights reserved.
//

import UIKit

@objc protocol DirectoryViewDelegate {
    optional func directoryViewSelected(chapter: String);
}

class WHC_DirectoryVC: UIViewController {
    @IBOutlet var tableView: UITableView!;
    var isScan = true;
    weak var directoryViewDelegate: DirectoryViewDelegate!;
    private let kCellName = "DirectoryCell";
    var chapterArr: NSArray!;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    convenience init(nibName: String){
        self.init(nibName: nibName,bundle: NSBundle.mainBundle());
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "目录";
        self.installNavigationBarLeftItem(title: "返回");
        self.tableView.backgroundColor = self.view.backgroundColor;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func installNavigationBarLeftItem(title title: String){
        self.installNavigationBarItem(title: title, imageName: nil, isLeft: true);
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
    
    func clickLeftItem(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    //MARK: - 列表视图代理
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if chapterArr == nil {
            return 0;
        }
        return chapterArr.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 50;
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0.5;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0.5;
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let view = UIView();
        view.backgroundColor = UIColor.clearColor();
        return view;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView();
        view.backgroundColor = UIColor.clearColor();
        return view;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellName);
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: kCellName);
            cell!.backgroundColor = self.view.backgroundColor;
        }
        let chapter = self.chapterArr[indexPath.row] as! String;
        cell?.textLabel?.text = chapter;
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: false);
        if !isScan {
            directoryViewDelegate?.directoryViewSelected?(self.chapterArr[indexPath.row] as! String);
        }
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    


}
