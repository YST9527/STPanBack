//
//  DetailViewController.h
//  STPanBack
//
//  Created by jryghq on 16/3/28.
//  Copyright © 2016年 jryghq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

