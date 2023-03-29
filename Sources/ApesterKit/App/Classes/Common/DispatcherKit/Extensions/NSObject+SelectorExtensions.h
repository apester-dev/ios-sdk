//
//  NSObject+SelectorExtensions.h
//  
//
//  Created by Arkadi Yoskovitz on 12/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SelectorExtensions)
- (BOOL)overridesSelector:(SEL)aSelector;
@end

NS_ASSUME_NONNULL_END
