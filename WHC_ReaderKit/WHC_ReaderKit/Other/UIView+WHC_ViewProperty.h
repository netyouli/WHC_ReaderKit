//
//  UIView+WHC_ViewProperty.h
//  WHC_ ContainerView
//
//  Created by 吴海超 on 15/5/15.
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

@interface UIView (WHC_ViewProperty)

- (CGFloat)y;

- (CGFloat)centerY;

- (CGFloat)centerX;

- (CGFloat)maxY;

- (CGFloat)x;

- (CGFloat)maxX;

- (CGPoint)xy;

- (CGFloat)width;

- (CGFloat)height;

- (CGSize)size;

- (void)setMaxY:(CGFloat)maxY;

- (void)setMaxX:(CGFloat)maxX;

- (void)setY:(CGFloat)Y;

- (void)setX:(CGFloat)X;

- (void)setCenterX:(CGFloat)centerX;

- (void)setCenterY:(CGFloat)centerY;

- (void)setXy:(CGPoint)point;

- (void)setSize:(CGSize)size;

- (void)setWidth:(CGFloat)width;

- (void)setHeight:(CGFloat)height;

@end
