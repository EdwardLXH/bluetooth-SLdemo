//
//  UITableViewCell+Help.h
//
//
//  Created by edward on 16/7/31.
//  Copyright © 2016年 . All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SLCellSubviewPressDelegate <NSObject>

// 点击cell的子view的代理方法
- (void)didPressedCellSubview:(id)object;

@end

@interface UITableViewCell (Help)

@property (nonatomic, assign) id<SLCellSubviewPressDelegate> delegateController;

+ (UINib *)nib;

/**
 *  cell填充数据
 *
 *  @param data 数据
 */
- (void)configCellWithData:(id)data;

@end
