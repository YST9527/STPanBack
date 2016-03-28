//
//  YgcdNavViewController.m
//  YgcdClient
//
//  Created by jryghq on 15/9/6.
//  Copyright (c) 2015年 jryghq. All rights reserved.
//

#ifndef UIDEFINE_h
/**
 *  设备的高度
 */

#define __DEVICE_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)

/**
 *  设备的宽度
 */

#define __DEVICE_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#endif

//偏移系数
#define __ST_OFFSET 0.6
//阴影系数
#define __SHADOW_ALPHA 0.4
//最小偏移量
#define __MIN_OFFSET __DEVICE_WIDTH/2
//返回时间
#define __TIME 0.23

#define __ST_SCALE 0.07

#import "BaseNavViewController.h"
#import "UIViewController+ScreenShot.h"
@interface STLastScreenShot : UIView

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *shadowView;

@end

@implementation STLastScreenShot

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc]initWithImage:image];
        _imageView.frame = self.bounds;
        [self addSubview:_imageView];
        _shadowView = [[UIView alloc]initWithFrame:self.bounds];
        _shadowView.backgroundColor = [UIColor blackColor];
        _shadowView.alpha = __SHADOW_ALPHA;
        [self addSubview:_shadowView];
    }
    return self;
}

@end

@interface BaseNavViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) STLastScreenShot *lastScreenShot;

@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, assign) BOOL isMoving;

/**
 *  该手势添加在了导航控制器上的View上，可以实现全屏幕右滑返回的效果
 */
@property (nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer *popGesture;

@end

@implementation BaseNavViewController

- (void)enableSTEdgePan {
    self.popGesture.enabled = YES;
}

- (void)unableSTEdgePan {
    self.popGesture.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationBar setShadowImage:[UIImage new]];
    self.interactivePopGestureRecognizer.enabled = NO;
    //滑动返回
    self.view.layer.shadowOffset = CGSizeMake(0, 10);
    self.view.layer.shadowOpacity = 0.7;
    self.view.layer.shadowRadius = 10;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.isMoving = NO;
    self.startPoint = CGPointZero;
    _popGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenEdgePanGestureRecognizer:)];
    _popGesture.edges = UIRectEdgeLeft;
    [_popGesture delaysTouchesBegan];
    _popGesture.delegate = self;
    [self.view addGestureRecognizer:_popGesture];
}

- (void)screenEdgePanGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)panGesture {
    CGPoint touchPoint = [panGesture locationInView:[[UIApplication sharedApplication]keyWindow]];
    CGFloat offsetX = touchPoint.x - self.startPoint.x;
    if(panGesture.state == UIGestureRecognizerStateBegan)
    {
        [self initViewsWithImage:self.topViewController.prefixShot];
        self.isMoving = YES;
        self.startPoint = touchPoint;
        offsetX = 0;
    }
    
    if(panGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [panGesture velocityInView:self.view];
        if (offsetX > __MIN_OFFSET || velocity.x > 600)
        {
            CGFloat time = (1-offsetX/__DEVICE_WIDTH)*__TIME;
            [UIView animateWithDuration:time animations:^{
                [self doMoveViewWithX:__DEVICE_WIDTH];
                self.lastScreenShot.shadowView.alpha = 0;
            } completion:^(BOOL finished) {
                [super popViewControllerAnimated:NO];
                [self completionPanBackAnimation];
                self.isMoving = NO;
            }];
        }else{
            CGFloat time = offsetX/__DEVICE_WIDTH*__TIME;
            [UIView animateWithDuration:time animations:^{
                [self doMoveViewWithX:0];
                self.lastScreenShot.shadowView.alpha = __SHADOW_ALPHA;
            } completion:^(BOOL finished) {
                self.isMoving = NO;
                self.bgView.hidden = YES;
            }];
        }
        self.isMoving = NO;
    }
    if(panGesture.state == UIGestureRecognizerStateCancelled)
    {
        CGFloat time = offsetX/__DEVICE_WIDTH*__TIME;
        [UIView animateWithDuration:time animations:^{
            [self doMoveViewWithX:0];
            self.lastScreenShot.shadowView.alpha = __SHADOW_ALPHA;
        } completion:^(BOOL finished) {
            self.isMoving = NO;
            self.bgView.hidden = YES;
        }];
        self.isMoving = NO;
    }
    if (self.isMoving) {
        [self doMoveViewWithX:offsetX];
        self.lastScreenShot.shadowView.alpha = __SHADOW_ALPHA*(1-offsetX/__DEVICE_WIDTH);
    }
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
        _bgView.backgroundColor = [UIColor blackColor];
        [self.view.superview insertSubview:_bgView belowSubview:self.view];
    }
    return _bgView;
}

//初始化截屏的view
-(void)initViewsWithImage:(UIImage *)image{
    self.bgView.hidden = NO;
    if (self.lastScreenShot) [self.lastScreenShot removeFromSuperview];
    self.lastScreenShot = [[STLastScreenShot alloc] initWithFrame:self.view.frame image:image];
    
    if (self.panType == STPanTypeFadeOut) {
        self.lastScreenShot.imageView.transform = CGAffineTransformMakeScale(1-__ST_SCALE, 1-__ST_SCALE);
    }else {
        self.lastScreenShot = [[STLastScreenShot alloc] initWithFrame:(CGRect){-(__DEVICE_WIDTH*__ST_OFFSET),0,__DEVICE_WIDTH,__DEVICE_HEIGHT} image:image];
    }
    [self.bgView addSubview:self.lastScreenShot];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.prefixShot = [self captureScreenShot];
    self.topViewController.currentShot = [self captureScreenShot];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (animated) {
        [self initViewsWithImage:self.topViewController.prefixShot];
        [UIView animateWithDuration:__TIME animations:^{
            [self doMoveViewWithX:__DEVICE_WIDTH];
            self.lastScreenShot.shadowView.alpha = 0;
        } completion:^(BOOL finished) {
            [super popViewControllerAnimated:NO];
            [self completionPanBackAnimation];
        }];
        return nil;
    } else {
        return [super popViewControllerAnimated:animated];
    }
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated{
    if (animated) {
        [self initViewsWithImage:self.viewControllers[0].currentShot];
        [UIView animateWithDuration:__TIME animations:^{
            [self doMoveViewWithX:__DEVICE_WIDTH];
            self.lastScreenShot.shadowView.alpha = 0;
        } completion:^(BOOL finished) {
            [super popToRootViewControllerAnimated:NO];
            [self completionPanBackAnimation];
        }];
        return nil;
    } else {
        return [super popToRootViewControllerAnimated:animated];
    }
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated) {
        [self initViewsWithImage:viewController.currentShot];
        [UIView animateWithDuration:__TIME animations:^{
            [self doMoveViewWithX:__DEVICE_WIDTH];
            self.lastScreenShot.shadowView.alpha = 0;
        } completion:^(BOOL finished) {
            [super popToViewController:viewController animated:NO];
            [self completionPanBackAnimation];
        }];
        return nil;
    }
    return [super popToViewController:viewController animated:animated];
}

-(void)doMoveViewWithX:(CGFloat)x{
    x = x>__DEVICE_WIDTH?__DEVICE_WIDTH:x;
    x = x<0?0:x;
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    CGAffineTransform transform = CGAffineTransformMakeScale(1-(1-x/__DEVICE_WIDTH)*__ST_SCALE, 1-(1-x/__DEVICE_WIDTH)*__ST_SCALE);
    if (self.panType == STPanTypeFadeOut) {
        self.lastScreenShot.imageView.transform = transform;
    }else {
        self.lastScreenShot.frame = (CGRect){-(__DEVICE_WIDTH*__ST_OFFSET)+x*__ST_OFFSET,0,__DEVICE_WIDTH,__DEVICE_HEIGHT};
    }
}

-(void)completionPanBackAnimation{
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    self.view.frame = frame;
    self.bgView.hidden = YES;
}

- (UIImage *)captureScreenShot
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.viewControllers.count != 1;
}

@end
