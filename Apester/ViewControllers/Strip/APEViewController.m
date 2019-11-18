//
//  APEViewController.m
//  Apester
//
//  Created by Hasan Sawaed Tabash on 9/13/19.
//  Copyright © 2019 Apester. All rights reserved.
//

#import "APEViewController.h"
#import <ApesterKit/ApesterKit.h>
#import "Apester-Swift.h"

@interface APEViewController()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) APEStripView *stripView;
@end

@implementation APEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    APEStripHeader *header =  [[APEStripHeader alloc] initWithText:@"Weitere Beiträge" size:25.0  family:@"Knockout" weight:400 color:[UIColor purpleColor]];
    // setup the strip view style
    APEStripStyle *style = [[APEStripStyle alloc] initWithShape:APEStripShapeRoundSquare
                                                           size:APEStripSizeMedium
                                                        padding:UIEdgeInsetsMake(10.0, 0, 0, 0)
                                                         shadow:NO textColor:nil background:nil
                                                         header:header];
    // initate the strip config
    NSError *error = nil;
    NSString *token = APEStripConfiguration.tokens.firstObject;
    APEStripConfiguration *config = [[APEStripConfiguration alloc] initWithChannelToken:token
                                                                                  style:style
                                                                                 bundle:[NSBundle mainBundle]
                                                                                  error:&error];
    if (error == nil) {
        self.stripView = [[APEStripView alloc] initWithConfiguration:config];
        [self.stripView displayIn:self.containerView containerViewConroller:self];
    }
}

@end
