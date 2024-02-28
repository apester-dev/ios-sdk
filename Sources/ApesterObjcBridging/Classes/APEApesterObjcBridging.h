//
//  APEApesterObjcBridging.h
//  ApesterKit: https://github.com/apester-dev/ios-sdk
//
//  Created by Arkadi Yoskovitz on 3/8/23.
//  Copyright © 2020 Apester. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APEApesterObjcBridging : NSObject
/// Used to blindly instantiate a class based on it's name
/// - Parameters:
///   - aClassName: The fully quilified name of the class you wish to instantiate
///   - selectorName: Selector to use for instantiation
///   - object: Optional object, in case ou need to pass a paramater
+ (id _Nullable)instantiateClassNamedWithObject:(nonnull NSString *)aClassName selectorName:(nonnull  NSString *)selectorName withObject:(id _Nonnull)object;
@end

