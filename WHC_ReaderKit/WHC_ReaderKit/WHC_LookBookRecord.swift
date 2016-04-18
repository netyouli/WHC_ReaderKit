//
//  WHC_LookBookRecord.swift
//  DigitalLibrary
//
//  Created by 吴海超 on 15/12/3.
//  Copyright © 2015年 吴海超. All rights reserved.
//

import UIKit

enum WHCLookBookRecordError: ErrorType {
    case UNKNOWN_FILE_NAME
}

class WHC_LookBookRecord: NSObject {
    var page = 1;
    var fontSize: CGFloat = 14;
    var colorMode = WHCBottomMenuColorMode.Gray;
    var pageMode = UIPageViewControllerTransitionStyle.PageCurl;
    var brightness: CGFloat = 1.0;
    var bookName: String!;
    var bookId: String!;
    var chapterName = "";
    var chapterArr: NSArray!;
    static let kWHCLookBookRecordPath = "\(NSHomeDirectory())/Library/Caches/WHCLookBookRecord/";;
    static let kChapterSuffix = "whc";
    override init() {
        super.init();
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.page = aDecoder.decodeIntegerForKey("page");
        self.fontSize = CGFloat(aDecoder.decodeFloatForKey("fontSize"));
        self.colorMode = WHCBottomMenuColorMode(rawValue: aDecoder.decodeIntegerForKey("colorMode"))!;
        self.pageMode = UIPageViewControllerTransitionStyle(rawValue: aDecoder.decodeIntegerForKey("pageMode"))!;
        self.brightness = CGFloat(aDecoder.decodeFloatForKey("brightness"));
        self.chapterName = aDecoder.decodeObjectForKey("chapterName") as! String;
        self.bookName = aDecoder.decodeObjectForKey("bookName") as? String;
        self.bookId = aDecoder.decodeObjectForKey("bookId") as? String;
        let tempArchive = aDecoder.decodeObjectForKey("chapterArr") as! NSData;
        self.chapterArr = NSKeyedUnarchiver.unarchiveObjectWithData(tempArchive) as! NSArray;
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(page, forKey: "page");
        aCoder.encodeInteger(colorMode.rawValue, forKey: "colorMode");
        aCoder.encodeInteger(pageMode.rawValue, forKey: "pageMode");
        aCoder.encodeFloat(Float(fontSize), forKey: "fontSize");
        aCoder.encodeFloat(Float(brightness), forKey: "brightness");
        aCoder.encodeObject(chapterName, forKey: "chapterName");
        aCoder.encodeObject(bookName, forKey: "bookName");
        aCoder.encodeObject(bookId, forKey: "bookId");
        let tempArchive = NSKeyedArchiver.archivedDataWithRootObject(chapterArr);
        aCoder.encodeObject(tempArchive, forKey: "chapterArr");
    }
    
    private func createCacheDirectory(path: String) {
        let fm = NSFileManager.defaultManager();
        let isDirectory = UnsafeMutablePointer<ObjCBool>.alloc(Int(true));
        if !fm.fileExistsAtPath(path, isDirectory: isDirectory) {
            do {
                try
                    fm.createDirectoryAtPath(path,
                        withIntermediateDirectories: true,
                        attributes: [NSFileProtectionKey:NSFileProtectionNone]);
            }catch {
                print("创建缓存目录失败");
            }
        }
        free(isDirectory);
    }
    
    func writeDiskCache() throws {
        if bookId != nil {
            self.createCacheDirectory(WHC_LookBookRecord.kWHCLookBookRecordPath);
            NSKeyedArchiver.archiveRootObject(self,
                toFile: WHC_LookBookRecord.kWHCLookBookRecordPath + bookId);
        }else {
            throw WHCLookBookRecordError.UNKNOWN_FILE_NAME;
        }
    }
    
    class func readDiskCache(bookName: String) -> WHC_LookBookRecord! {
        let bookRecord = NSKeyedUnarchiver.unarchiveObjectWithFile(WHC_LookBookRecord.kWHCLookBookRecordPath + bookName) as? WHC_LookBookRecord;
        bookRecord?.bookId = bookName;
        return bookRecord;
    }
    
    class func deleteFormDiskCache(bookName: String) {
        let bookRecord = WHC_LookBookRecord.readDiskCache(bookName);
        bookRecord?.removeFromDisk();
    }
    
    func removeFromDisk() {
        let fm = NSFileManager.defaultManager();
        let path = WHC_LookBookRecord.kWHCLookBookRecordPath + bookId;
        if fm.fileExistsAtPath(path) {
            do {
                try fm.removeItemAtPath(path);
            }catch {
                print("删除书签缓存失败");
            }
        }
    }
    
    class func colorR(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    
    
    class func fontColor(mode: WHCBottomMenuColorMode , brightness: CGFloat) -> UIColor {
        switch mode {
            case .Gray ,.Green ,.Yellow:
                return WHC_LookBookRecord.colorR(20, g: 20, b: 20);
            case .Black:
                var handleBrightness: CGFloat = 0;
                if brightness == 1 {
                    handleBrightness = 1;
                }else if brightness == 0 {
                    handleBrightness = 0.5;
                }else {
                    handleBrightness = brightness * 0.5 + 0.5;
                }
                return WHC_LookBookRecord.colorR(200 * handleBrightness, g: 200 * handleBrightness, b: 200 * handleBrightness);
        }
    }
    
    class func backgroundColor(mode: WHCBottomMenuColorMode , brightness: CGFloat) -> UIColor {
        var handleBrightness: CGFloat = 0;
        if brightness == 1 {
            handleBrightness = 1;
        }else if brightness == 0 {
            handleBrightness = 0.5;
        }else {
            handleBrightness = brightness * 0.5 + 0.5;
        }
        
        switch mode {
            case .Gray:
                return WHC_LookBookRecord.colorR(250 * handleBrightness, g: 250 * handleBrightness, b: 250 * handleBrightness);
            case .Yellow:
                return WHC_LookBookRecord.colorR(241 * handleBrightness, g: 235 * handleBrightness, b: 207 * handleBrightness);
            case .Green:
                return WHC_LookBookRecord.colorR(183 * handleBrightness, g: 225 * handleBrightness, b: 198 * handleBrightness);
            case .Black:
                return WHC_LookBookRecord.colorR(35 * handleBrightness, g: 35 * handleBrightness, b: 35 * handleBrightness);
        }
    }
}
