//
//  YgcdNavViewController.h
//  YgcdClient
//
//  Created by jryghq on 15/9/6.
//  Copyright (c) 2015年 jryghq. All rights reserved.
//
/**
 *  返回方式
 */
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, STPanType) {
    /**
     *  淡出
     */
    STPanTypeFadeOut,
    /**
     *  侧滑
     */
    STPanTypeSideslip
};
@interface BaseNavViewController : UINavigationController

@property (nonatomic, assign) STPanType panType;

/**
 *  打开自定义的返回效果
 */
- (void)enableSTEdgePan;

/**
 *  关闭自定义的返回效果
 */
- (void)unableSTEdgePan;

@end
