//
//  UITableViewCell+Help.h
//
//
//  Created by edward on 16/7/31.
//  Copyright © 2016年 . All rights reserved.
//

#import "UITableViewCell+Help.h"
#import <objc/runtime.h>

@implementation UITableViewCell (Help)

+ (UINib *)nib{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)configCellWithData:(id)data{}

- (void)setDelegateController:(id)delegateController
{
    objc_setAssociatedObject(self, @selector(delegateController), delegateController, OBJC_ASSOCIATION_ASSIGN);
}

- (id)delegateController
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
