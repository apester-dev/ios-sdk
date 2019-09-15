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
    APEStripConfiguration *config = [[APEStripConfiguration alloc] initWithChannelToken:@"5890a541a9133e0e000e31aa"
                                                                                  shape:APEStripShapeRoundSquare
                                                                                   size:APEStripSizeMedium
                                                                                 shadow:NO
                                                                                 bundle:[NSBundle mainBundle]
                                                                              textColor:nil
                                                                             background:nil];
    self.stripView = [[APEStripView alloc] initWithConfiguration:config];
    [self.stripView displayIn:self.containerView containerViewConroller:self];
}

@end
