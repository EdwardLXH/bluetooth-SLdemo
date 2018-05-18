//
//  GlobalPublicDefine.h
//
//
//  Created by Mac on 2017/5/17.
//  Copyright © 2017年 edward. All rights reserved.
//

#ifndef GlobalPublicDefine_h
#define GlobalPublicDefine_h

//========================================================================//
/**
 *  公共配置宏定义
 */
//========================================================================//

#pragma mark 多线程
#define EqueueAsyncMainStart(queue) dispatch_async(queue,^{

//#define EqueueAsyncMainEnd     });

#define EqueueSyncMainStart(queue)  dispatch_sync(queue, ^{

//#define EqueueSyncMainEnd     });


#define EqueueGlobalStart  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{


#define EqueueEnd     });




#pragma mark 强弱引用
#define kWeakSelf(type)     __weak typeof(type)weak##type = type;
#define kStrongSelf(type)   __strong typeof(type)type = weak##type;




#pragma mark 颜色配置
//颜色
#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define RGB(r, g, b)        [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]
#define ColorOfCtlBackground   RGB(245, 245, 245)          //uiviewcontroller背景色
#define ColorOfListLine     RGB(204, 204, 204)          //线条颜色
#define ColorOfTabBarLine   RGB(178, 178, 178)          //tabbar 顶部颜色

/* --------------------------------    edward    --------------------------------------*/
#define SCRandomColor    RGB(arc4random_uniform(255),arc4random_uniform(255),arc4random_uniform(255))
#define SCBaseNavBackgroundColor RGB(246,246,246)

#define iPhone6 ([UIScreen mainScreen].bounds.size.height == 667)
#define iPhone6P ([UIScreen mainScreen].bounds.size.height == 736)
#define iPhone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define iPhone4 ([UIScreen mainScreen].bounds.size.height == 480)

/** 屏幕缩放比例 */
#define SCScaleXW (SLWidth /320.0)
#define SCScaleYH (SLHeight /568.0)
#define SCScaleFor6  (1.17)
#define SCScaleFor6P  (1.3)


#define AliPayReturn                       @"alipayReturnApp"

/* --------------------------------    edward   --------------------------------------*/


//按钮颜色
#define ColorOfNormalButton    [UIColor colorWithRed:6/255.0 green:191/255.0 blue:4/255.0 alpha:1.0]
#define ColorOfHighlightButton [UIColor colorWithRed:2/255.0 green:157/255.0 blue:0/255.0 alpha:1.0]

//全局使用的字体颜色
#define ColorOfGlobalNormalText  RGBACOLOR(100.0f, 100.0f, 100.0f, 1.0f)
#define ColorOfGlobalHightedText RGBACOLOR(100.0f, 100.0f, 100.0f, 0.5f)

#pragma mark 系统宏
#define SLWidth             [[UIScreen mainScreen] bounds].size.width   //获取屏幕宽度
#define SLHeight            [[UIScreen mainScreen] bounds].size.height  //获取屏幕高度
#define SLScreenBounds      [[UIScreen mainScreen] bounds]


/* ----------------------------   edward  --------------------------------------------*/

#ifdef DEBUG
// 调试阶段 DEBUG
#define SCLog(...) NSLog(__VA_ARGS__);

#else

#define SCLog(...) {}
// 发布阶段
//#define PRLog(...)

#endif

#define SCFunc NSLog(@"%s",__func__);

#endif /* GlobalPublicDefine_h */
