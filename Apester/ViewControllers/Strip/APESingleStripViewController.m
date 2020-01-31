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
    // 1 - Get token form the ChannleTokens Service
    NSString *token = StripConfigurationsFactory.configurations.firstObject.channelToken;
    // 2 - load
    self.stripView = [APEStripViewService.shared stripViewFor:token];;
    self.stripView.delegate = self;
    self.containerViewHeightConstraint.constant = self.stripView.height;
    [self.stripView displayIn:self.containerView containerViewConroller:self];

}

#pragma mark - APEStripViewDelegate

- (void)stripView:(APEStripView * _Nonnull)stripView didFailLoadingChannelToken:(NSString * _Nonnull)token {}

- (void)stripView:(APEStripView * _Nonnull)stripView didFinishLoadingChannelToken:(NSString * _Nonnull)token {}

- (void)stripView:(APEStripView * _Nonnull)stripView didUpdateHeight:(CGFloat)height {
    self.containerViewHeightConstraint.constant = height;
}

@end
