//
//  APEApesterObjcBridging.h
//  ApesterKit: https://github.com/apester-dev/ios-sdk
//
//  Created by Arkadi Yoskovitz on 3/8/23.
//  Copyright © 2020 Apester. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APEApesterObjcBridging.h"

@implementation APEApesterObjcBridging

+ (id _Nullable)instantiateClassNamedWithObject:(nonnull NSString *)aClassName selectorName:(nonnull  NSString *)selectorName withObject:(id _Nonnull)object
{
    SEL action  = NSSelectorFromString(selectorName);
    Class klass = NSClassFromString(aClassName);
    if (!klass) {
        return nil;
    }
    if (!action) {
        return nil;
    }
    
    if (![klass instancesRespondToSelector:action]) {
        return nil;
    }
    
    id result = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (object) {
        result = [[klass alloc] performSelector:action withObject:object];
    } else {
        result = [[klass alloc] performSelector:action];
    }
#pragma clang diagnostic pop
    return result;
}
@end
