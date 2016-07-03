# WHC_ReaderKit

#### 联系QQ: 712641411
#### 开发作者: 吴海超
#### 轻量级小说阅读架构(简单，高效)

#### 最强大自动布局开源库：https://github.com/netyouli/WHC_AutoLayoutKit

### 集成示例
```objective-c
let bookVC = WHC_ReadBookVC(nibName: "WHC_ReadBookVC", bundle: nil)
bookVC.chapterArr = chapterTitles as NSArray
bookVC.bookId = "1"
bookVC.bookName = "2061太空漫游"
bookVC.filePath = NSBundle.mainBundle().pathForResource("2061太空漫游", ofType: "txt")
let bookNV = UINavigationController(rootViewController: bookVC)
self.presentViewController(bookNV, animated: true, completion: nil)
```
### 使用效果
![](https://github.com/netyouli/WHC_ReaderKit/blob/master/WHC_ReaderKit/show.gif)



