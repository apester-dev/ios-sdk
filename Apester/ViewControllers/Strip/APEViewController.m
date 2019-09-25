//
//  APEViewController.m
//  Apester
//
//  Created by Hasan Sawaed Tabash on 9/13/19.
//  Copyright © 2019 Apester. All rights reserved.
//

#import "APEViewController.h"
#import <ApesterKit/ApesterKit.h>

@interface APEViewController()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) APEStripView *stripView;
@end

@implementation APEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // setup the strip view style
    APEStripStyle *style = [[APEStripStyle alloc] initWithShape:APEStripShapeRoundSquare
                                                           size:APEStripSizeMedium
                                                        padding:UIEdgeInsetsMake(10.0, 0, 0, 0)
                                                         shadow:NO textColor:nil background:nil];
    // initate the strip config
    NSError *error = nil;
    APEStripConfiguration *config = [[APEStripConfiguration alloc] initWithChannelToken:@"5890a541a9133e0e000e31aa"
                                                                                  style:style
                                                                                 bundle:[NSBundle mainBundle]
                                                                                  error:&error];
    if (error == nil) {
        self.stripView = [[APEStripView alloc] initWithConfiguration:config];
        [self.stripView displayIn:self.containerView containerViewConroller:self];
    }
}

@end
