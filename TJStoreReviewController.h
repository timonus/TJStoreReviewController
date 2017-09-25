//
//  TJStoreReviewController.h
//
//  Created by Tim Johnsen on 6/17/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TJStoreReviewController : NSObject

+ (void)appDidLaunch;

+ (BOOL)requestThrottledReview;

+ (void)reviewInAppStore:(NSString *const)appIdentifierString NS_EXTENSION_UNAVAILABLE_IOS("+reviewInAppStore: isn't available in app extensions because it requires a UIApplication instance and -openURL:");

@end

NS_ASSUME_NONNULL_END
