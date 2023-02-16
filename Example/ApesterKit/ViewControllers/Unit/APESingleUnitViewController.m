//
//  APEUnitObjcViewController.m
//  Apester
//
//  Created by Hasan Sawaed Tabash on 8/5/20.
//  Copyright © 2020 Apester. All rights reserved.
//

#import "APESingleUnitViewController.h"
#import <ApesterKit/ApesterKit-umbrella.h>
#import <ApesterKit_Example-Swift.h>

@interface APESingleUnitViewController ()<APEUnitViewDelegate>

@property (nonatomic, strong) APEUnitView* apesterUnitView;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end

@implementation APESingleUnitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    APEUnitConfiguration *configuration = [UnitConfigurationsFactory configurationsWithHideApesterAds:NO
                                                                                           gdprString:nil
                                                                                              baseUrl: nil
                                           ].firstObject;
    NSString *unitId = [[UnitConfigurationsFactory unitsIds] lastObject];

    if (unitId != nil) {
        // preLoad implementation
        _apesterUnitView = [APEViewService.shared unitViewFor:unitId];
    }

    if (configuration == nil) {
        return;
    }

    if (_apesterUnitView == nil) {
        // not preload!
        _apesterUnitView = [[APEUnitView alloc] initWithConfiguration: configuration];

    }

    _apesterUnitView.delegate = self;

    [_apesterUnitView displayIn:_containerView containerViewController:self];

    NSString *gdpr = [UnitConfigurationsFactory gdprString];
    if (gdpr && [gdpr length] > 0) {
        [_apesterUnitView setGdprString:UnitConfigurationsFactory.gdprString];
    }
}

- (IBAction)refreshButton:(id)sender {
    [_apesterUnitView reload];
}

- (void)unitView:(APEUnitView * _Nonnull)unitView didCompleteAdsForUnit:(NSString * _Nonnull)unitId {

}

- (void)unitView:(APEUnitView * _Nonnull)unitView didFailLoadingUnit:(NSString * _Nonnull)unitId {

}

- (void)unitView:(APEUnitView * _Nonnull)unitView didFinishLoadingUnit:(NSString * _Nonnull)unitId {

}

- (void)unitView:(APEUnitView * _Nonnull)unitView didUpdateHeight:(CGFloat)height {
    [[self heightConstraint] setConstant:height];
    NSLog(@"## unitView.didUpdateHeight: %f", height);
}
@end
