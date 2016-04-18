//
//  UIView+WHC_Loading.h
//  UIView+WHC_Loading
//
//  Created by 吴海超 on 15/3/25.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

/*************************************************************
 *                                                           *
 *  qq:712641411                                             *
 *  开发作者: 吴海超(WHC)                                      *
 *  iOS技术交流群:302157745                                    *
 *  gitHub:https://github.com/netyouli/WHC_ReaderKit    *
 *                                                           *
 *************************************************************/

#import <UIKit/UIKit.h>

@interface UIView (WHC_Loading)

- (void)startLoading;
- (void)stopLoading;
- (void)startLoadingWithTxt:(NSString*)customTitle;
- (void)stopLoadingWithTxt;
- (void)startLoadingWithTxtUser:(NSString*)customTitle;
- (void)stopLoadingWithTxtUser;
- (void)startLoadingWithUser;
- (void)stopLoadingWithUser;
@end
