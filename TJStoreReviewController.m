//
//  TJStoreReviewController.m
//
//  Created by Tim Johnsen on 6/17/17.
//
//

#import "TJStoreReviewController.h"
#import <StoreKit/StoreKit.h>

static NSString *const kTJStoreReviewControllerNextReviewDateKey = @"kTJStoreReviewControllerNextReviewDateKey";

static const NSUInteger kTJStoreReviewControllerInitialDaysToRate = 7;
static const NSUInteger kTJStoreReviewControllerSubsequentDaysToRate = 120;

#if defined(__has_attribute) && __has_attribute(objc_direct_members)
__attribute__((objc_direct_members))
#endif
@implementation TJStoreReviewController

+ (void)appDidLaunch
{
    NSDate *const date = [[NSUserDefaults standardUserDefaults] objectForKey:kTJStoreReviewControllerNextReviewDateKey];
    if (!date) {
        deferNextRateDayByDaysFromPresent(kTJStoreReviewControllerInitialDaysToRate);
    }
}

+ (BOOL)requestThrottledReview
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return NO;
    }
    BOOL didTryShow = NO;
    NSDate *const date = [[NSUserDefaults standardUserDefaults] objectForKey:kTJStoreReviewControllerNextReviewDateKey];
    if (!date) {
        deferNextRateDayByDaysFromPresent(kTJStoreReviewControllerInitialDaysToRate);
    } else {
        if ([date earlierDate:[NSDate date]] == date) {
#if !defined(__IPHONE_10_3) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_3
            if (@available(iOS 10.3, *))
#endif
            {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeVisibleNotification
                                                                      object:nil
                                                                       queue:nil
                                                                  usingBlock:^(NSNotification * _Nonnull notification) {
                        if ([NSStringFromClass([notification.object class]) hasPrefix:[NSStringFromClass([SKStoreReviewController class]) substringToIndex:13]]) {
                            deferNextRateDayByDaysFromPresent(kTJStoreReviewControllerSubsequentDaysToRate);
                        }
                    }];
                });
                deferNextRateDayByDaysFromPresent(1);
                [SKStoreReviewController requestReview];
                didTryShow = YES;
            }
        }
    }
    return didTryShow;
}

+ (void)reviewInAppStore:(NSString *const)appIdentifierString
{
    deferNextRateDayByDaysFromPresent(kTJStoreReviewControllerSubsequentDaysToRate);
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

static void deferNextRateDayByDaysFromPresent(const NSUInteger daysFromPresent)
{
    NSDate *deferDate = [NSDate dateWithTimeIntervalSinceNow:3600.0 * 24.0 * daysFromPresent];
    // Floor the input date to the very beginning of the specified day.
    NSCalendar *const calendar = [NSCalendar currentCalendar];
    NSDateComponents *const deferDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitTimeZone fromDate:deferDate];
    deferDate = [calendar dateFromComponents:deferDateComponents];
    
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
