//
//  BaseNavitationViewController.m
//  STPanBack
//
//  Created by jryghq on 16/8/17.
//  Copyright © 2016年 jryghq. All rights reserved.
//

#import "BaseNavitationViewController.h"

@interface BaseNavitationViewController ()

@end

@implementation BaseNavitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self st_addEdgePanGestureRecognizer];
    self.interactivePopGestureRecognizer.enabled = NO;
    self.st_default.animationTime = 0.3;
    // Do any additional setup after loading the view.
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self pushViewController:vc animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self st_pushViewController:viewController animated:animated completionHandler:^{
        [super pushViewController:viewController animated:NO];
        //do other things
    }];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (!animated) {
        return [super popViewControllerAnimated:NO];
    }
    [self st_popViewControllerAnimated:animated completionHandler:^{
        [super popViewControllerAnimated:NO];
        //do other things
    }];
    return nil;
}

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!animated) {
        return [super popToViewController:viewController animated:NO];
    }
    [self st_popToViewController:viewController animated:animated completionHandler:^{
        [super popToViewController:viewController animated:NO];
        //do other things
    }];
    return nil;
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    if (!animated) {
        return [super popToRootViewControllerAnimated:NO];
    }
    [self st_popToRootViewControllerAnimated:animated completionHandler:^{
        [super popToRootViewControllerAnimated:NO];
        //do other things
    }];
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
