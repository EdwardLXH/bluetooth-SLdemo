//
//  UIView+view.h
//
//
//  Created by edward on 15/12/18.
//  Copyright © 2015年 Edward.Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (view)


/** x  */
@property CGFloat x;

/** y*/
@property CGFloat y;

/** width  */
@property CGFloat width;

/** height  */
@property CGFloat height;


/**
 *  图片放大缩小
 *
 *  @param superView 父视图
 *  @param image  需要放大的图片
 */
- (void) tapAction:(UIView*)superView AndImage:(UIImage *)image;


@end
