//
//  APESingleStripViewController.m
//  Apester
//
//  Created by Hasan Sawaed Tabash on 9/13/19.
//  Copyright © 2019 Apester. All rights reserved.
//

#import "APESingleStripViewController.h"
#import <ApesterKit/ApesterKit.h>
#import "Apester-Swift.h"

@interface APESingleStripViewController() <APEStripViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (nonatomic, strong) APEStripView *stripView;
@end

@implementation APESingleStripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    APEStripHeader *header =  [[APEStripHeader alloc] initWithText:@"Weitere Beiträge" size:25.0  family:@"Knockout" weight:400 color:[UIColor purpleColor]];
    // setup the strip view style
    APEStripStyle *style = [[APEStripStyle alloc] initWithShape:APEStripShapeRoundSquare
                                                           size:APEStripSizeMedium
                                                        padding:UIEdgeInsetsMake(5.0, 5.0, 0, 0)
                                                         shadow:NO textColor:nil background:nil
                                                         header:header];
    // initate the strip config
    NSError *error = nil;
    NSString *token = APEStripConfiguration.tokens.firstObject;
    APEEnvironment *env = APEEnvironment.production;
    APEStripConfiguration *config = [[APEStripConfiguration alloc] initWithChannelToken:token
                                                                                  style:style
                                                                                 bundle:[NSBundle mainBundle]
                                                                            environment:env
                                                                                  error:&error];
    if (error == nil) {
        self.stripView = [[APEStripView alloc] initWithConfiguration:config];
        self.stripView.delegate = self;
        [self.stripView displayIn:self.containerView containerViewConroller:self];
    }
}

#pragma mark - APEStripViewDelegate

- (void)stripView:(APEStripView * _Nonnull)stripView didFailLoadingChannelToken:(NSString * _Nonnull)token {}

- (void)stripView:(APEStripView * _Nonnull)stripView didFinishLoadingChannelToken:(NSString * _Nonnull)token {}

- (void)stripView:(APEStripView * _Nonnull)stripView didUpdateHeight:(CGFloat)height {
    self.containerViewHeightConstraint.constant = height;
}

@end
