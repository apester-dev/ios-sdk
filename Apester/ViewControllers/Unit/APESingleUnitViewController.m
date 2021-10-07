//
//  APEUnitObjcViewController.m
//  Apester
//
//  Created by Hasan Sawaed Tabash on 8/5/20.
//  Copyright © 2020 Apester. All rights reserved.
//

#import "APESingleUnitViewController.h"
#import <ApesterKit/ApesterKit.h>
#import "Apester-Swift.h"

@interface APESingleUnitViewController ()<APEUnitViewDelegate>

@property (nonatomic, strong) APEUnitView* apesterUnitView;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation APESingleUnitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    APEUnitConfiguration *configuration = [UnitConfigurationsFactory configurationsWithHideApesterAds:NO
                                                                                           gdprString:nil
                                                                                              baseUrl: nil
                                           ].firstObject;
    //.configurations(for: .stage, hideApesterAds: false, gdprString: nil)[0]
    NSString *unitId = [[UnitConfigurationsFactory unitsIds] firstObject];

    if (unitId != nil) {
        // preLoad implemntation
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

    [_apesterUnitView setGdprString:UnitConfigurationsFactory.gdprString];
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

}
@end
