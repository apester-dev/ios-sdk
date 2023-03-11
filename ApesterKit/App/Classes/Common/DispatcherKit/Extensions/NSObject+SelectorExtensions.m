//
//  NSObject+SelectorExtensions.m
//  
//
//  Created by Arkadi Yoskovitz on 12/4/22.
//

#import "NSObject+SelectorExtensions.h"

@implementation NSObject (SelectorExtensions)

- (BOOL)overridesSelector:(SEL)aSelector {

    Class aSuperType = [self superclass];
    BOOL  overridden = NO;
    
    while (aSuperType != nil) {
        overridden = ([aSuperType instancesRespondToSelector:aSelector]) && ([self methodForSelector: aSelector] != [aSuperType instanceMethodForSelector: aSelector]);
        if (overridden) {
            break;
        }
        aSuperType = [aSuperType superclass];
    }
    return overridden;
}
@end
