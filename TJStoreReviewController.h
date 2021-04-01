//
//  TJStoreReviewController.h
//
//  Created by Tim Johnsen on 6/17/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TJStoreReviewController : NSObject

/// Optional
/// Call this on launch of your app to mark the first launch time, which +requestThrottledReview will use to decide when to show
/// If you don't call this then the first call into +requestThrottledReview will be treated as the app's launch time, which is often good enough.
+ (void)appDidLaunch;

/// Call this to optimistically show an app rating prompt.
/// This isn't guaranteed to show a prompt, but it may.
/// Doesn't do anything in iOS versions prior to 10.3.
+ (BOOL)requestThrottledReview NS_EXTENSION_UNAVAILABLE_IOS("+requestThrottledReview: isn't available in app extensions because it requires a UIApplication instance");
// App-only
// Window Scene
// Bypass throttling
// Did Show Block
// Did Dismiss Block
// Improve docs

+ (BOOL)requestThrottledReviewWithDidShowBlock:(nullable dispatch_block_t)didShowBlock
                               didDismissBlock:(nullable dispatch_block_t)didDismissBlock NS_EXTENSION_UNAVAILABLE_IOS("+requestThrottledReview: isn't available in app extensions because it requires a UIApplication instance");

/// Call this passing in your app's iTunes identifier to show the rating UI in the App Store.
/// Calling this defers the next time that +requestThrottledReview will show a review prompt.
+ (void)reviewInAppStore:(NSString *const)appIdentifierString NS_EXTENSION_UNAVAILABLE_IOS("+reviewInAppStore: isn't available in app extensions because it requires a UIApplication instance and -openURL:");

+ (NSString *)appStoreURLStringForAppIdentifierString:(NSString *const)appIdentifierString;

/// Call this passing in your app's iTunes identifier to show your app in the App Store.
+ (void)showInAppStore:(NSString *const)appIdentifierString NS_EXTENSION_UNAVAILABLE_IOS("+showInAppStore: isn't available in app extensions because it requires a UIApplication instance and -openURL:");

@end

NS_ASSUME_NONNULL_END
