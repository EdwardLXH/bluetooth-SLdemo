//
//  UIView+view.h
//
//
//  Created by edward on 15/12/18.
//  Copyright © 2015年 Edward.Lau. All rights reserved.
//

#import "UIView+frame.h"


#pragma mark 系统宏
#define SLWidth             [[UIScreen mainScreen] bounds].size.width   //获取屏幕宽度
#define SLHeight            [[UIScreen mainScreen] bounds].size.height  //获取屏幕高度


@implementation UIView (view)

-(void)setX:(CGFloat)x
{
    CGRect frame = self.frame;  //取出fram
    frame.origin.x = x;         //给 fram.origin.x 赋值
    self.frame = frame;         //然后在 赋值给 self.frame
}

-(CGFloat)x
{
    return self.frame.origin.x;
}

-(void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(CGFloat)y
{
    return self.frame.origin.y;
}

-(void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    
}

-(CGFloat)width
{
    return self.frame.size.width;
}



-(void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

-(CGFloat)height
{
    return self.frame.size.height;
}




/* -------------------------- 图片点击房放大   ------------------------------*/
//点击图片后的方法(即图片的放大全屏效果)
- (void) tapAction:(UIView*)superView AndImage:(UIImage *)image {
    //创建一个黑色背景
    //初始化一个用来当做背景的View。
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, SLWidth, SLHeight)];
    [bgView setBackgroundColor:[UIColor blackColor]];
    [superView addSubview:bgView];
    
    //创建显示图像的视图
    //初始化要显示的图片内容的imageView
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (SLHeight-SLWidth)*0.5, SLWidth, SLWidth)];
//    //要显示的图片，即要放大的图片
    [imgView setImage:image];

    [bgView addSubview:imgView];
    
    imgView.userInteractionEnabled = YES;
    //添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeView)];
    [bgView addGestureRecognizer:tapGesture];

    [self shakeToShow:imgView];//放大过程中的动画
}
-(void)closeView{
    
    for (UIView *bgView in self.subviews) {
        if (bgView == self.subviews.lastObject) {
            [bgView removeFromSuperview];
        }
    }
    
}
//放大过程中出现的缓慢动画
- (void) shakeToShow:(UIView*)aView{
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}








@end
