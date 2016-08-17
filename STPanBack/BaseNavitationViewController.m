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
    [self st_addEdgePanGestureRecognizer];
    self.interactivePopGestureRecognizer.enabled = NO;
    // Do any additional setup after loading the view.
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
