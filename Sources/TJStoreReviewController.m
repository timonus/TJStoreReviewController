//
//  TJStoreReviewController.m
//
//  Created by Tim Johnsen on 6/17/17.
//
//

#import "TJStoreReviewController.h"
#import <StoreKit/StoreKit.h>

static NSString *const kTJStoreReviewControllerNextReviewDateKey = @"kTJStoreReviewControllerNextReviewDateKey";

#if defined(__has_attribute) && __has_attribute(objc_direct_members)
__attribute__((objc_direct_members))
#endif
@implementation TJStoreReviewController

static NSUInteger _initialDaysToRate = 7;
static NSUInteger _subsequentDaysToRate = 120;

+ (void)setInitialDaysToRate:(NSUInteger)initialDaysToRate
{
    _initialDaysToRate = initialDaysToRate;
}

+ (NSUInteger)initialDaysToRate
{
    return _initialDaysToRate;
}

+ (void)setSubsequentDaysToRate:(NSUInteger)subsequentDaysToRate
{
    _subsequentDaysToRate = subsequentDaysToRate;
}

+ (NSUInteger)subsequentDaysToRate
{
    return _subsequentDaysToRate;
}

+ (void)appDidLaunch
{
    NSDate *const date = [[NSUserDefaults standardUserDefaults] objectForKey:kTJStoreReviewControllerNextReviewDateKey];
    if (!date) {
        deferNextRateDayByDaysFromPresent(self.initialDaysToRate);
    }
}

+ (BOOL)requestThrottledReview:(dispatch_block_t)didPromptBlock
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        NSDate *const date = [[NSUserDefaults standardUserDefaults] objectForKey:kTJStoreReviewControllerNextReviewDateKey];
        if (!date) {
            deferNextRateDayByDaysFromPresent(self.initialDaysToRate);
        } else if ([date earlierDate:[NSDate date]] == date) {
            [self requestImmediateReview:didPromptBlock];
            
            // The trick we use for detecting if the prompt has shown doesn't work on macOS.
            // To avoid repeatedly prompting the user we assume success and defer by kTJStoreReviewControllerSubsequentDaysToRate.
            NSUInteger daysToDefer = 1;
            if (@available(iOS 13.0, *)) {
                if ([[NSProcessInfo processInfo] isMacCatalystApp]) {
                    daysToDefer = self.subsequentDaysToRate;
                } else if (@available(iOS 14.0, *)) {
                    if ([[NSProcessInfo processInfo] isiOSAppOnMac]) {
                        daysToDefer = self.subsequentDaysToRate;
                    }
                }
            }
            deferNextRateDayByDaysFromPresent(daysToDefer);
            return YES;
        }
    }
    return NO;
}

+ (void)requestImmediateReview:(dispatch_block_t)didPromptBlock
{
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeVisibleNotification
                                                                            object:nil
                                                                             queue:nil
                                                                        usingBlock:^(NSNotification * _Nonnull notification) {
        if ([NSStringFromClass([notification.object class]) hasPrefix:[NSStringFromClass([SKStoreReviewController class]) substringToIndex:13]]) {
            deferNextRateDayByDaysFromPresent(self.subsequentDaysToRate);
            if (didPromptBlock) {
                didPromptBlock();
            }
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }
    }];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [SKStoreReviewController requestReview];
#pragma clang diagnostic pop
}

+ (void)reviewInAppStore:(NSString *const)appIdentifierString
{
    deferNextRateDayByDaysFromPresent(self.subsequentDaysToRate);
    NSString *urlFormatString = nil;
#if !defined(__IPHONE_10_3) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_3
    if (@available(iOS 10.3, *)) {
#endif
        urlFormatString = @"https://itunes.apple.com/app/id%@?action=write-review";
#if !defined(__IPHONE_10_3) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_3
    } else {
        urlFormatString = @"https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    }
#endif
    NSString *urlString = [NSString stringWithFormat:urlFormatString, appIdentifierString];
    
    openWebURLStringWithFallback(urlString);
}

+ (NSString *)appStoreURLStringForAppIdentifierString:(NSString *const)appIdentifierString
{
    return [NSString stringWithFormat:@"https://apps.apple.com/app/id%@", appIdentifierString];
}

+ (void)showInAppStore:(NSString *const)appIdentifierString
{
    openWebURLStringWithFallback([self appStoreURLStringForAppIdentifierString:appIdentifierString]);
}

+ (void)setNextShowDate:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:_floorDate(date) forKey:kTJStoreReviewControllerNextReviewDateKey];
}

static NSDate *_floorDate(NSDate *const date)
{
    // Floor the input date to the very beginning of the specified day.
    NSCalendar *const calendar = [NSCalendar currentCalendar];
    NSDateComponents *const deferDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitTimeZone fromDate:date];
    return [calendar dateFromComponents:deferDateComponents];
}

static void deferNextRateDayByDaysFromPresent(const NSUInteger daysFromPresent)
{
    NSDate *const deferDate = _floorDate([NSDate dateWithTimeIntervalSinceNow:3600.0 * 24.0 * daysFromPresent]);
    [[NSUserDefaults standardUserDefaults] setObject:deferDate forKey:kTJStoreReviewControllerNextReviewDateKey];
}

static void openWebURLStringWithFallback(NSString *const urlString) NS_EXTENSION_UNAVAILABLE_IOS("+reviewInAppStore: isn't available in app extensions because it requires a UIApplication instance and -openURL:")
{
    NSURL *const url = [NSURL URLWithString:urlString];
#if !defined(__IPHONE_10_0) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    if (@available(iOS 10.0, *)) {
#endif
        [[UIApplication sharedApplication] openURL:url
                                           options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @YES}
                                 completionHandler:^(BOOL success) {
            if (!success) {
                NSURLComponents *const components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
                components.scheme = @"itms-apps";
                [[UIApplication sharedApplication] openURL:components.URL
                                                   options:@{}
                                         completionHandler:nil];
            }
        }];
#if !defined(__IPHONE_10_0) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
    }
#endif
}

@end
