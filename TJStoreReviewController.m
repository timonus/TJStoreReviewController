//
//  TJStoreReviewController.m
//
//  Created by Tim Johnsen on 6/17/17.
//
//

#import "TJStoreReviewController.h"
#import <StoreKit/StoreKit.h>

static NSString *const kTJStoreReviewControllerNextReviewDateKey = @"kTJStoreReviewControllerNextReviewDateKey";

static NSUInteger const kTJStoreReviewControllerInitialDaysToRate = 7;
static NSUInteger const kTJStoreReviewControllerDaysToRate = 30;

@implementation TJStoreReviewController

+ (void)appDidLaunch
{
    NSDate *const date = [[NSUserDefaults standardUserDefaults] objectForKey:kTJStoreReviewControllerNextReviewDateKey];
    if (!date) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:3600.0 * 24.0 * kTJStoreReviewControllerInitialDaysToRate] forKey:kTJStoreReviewControllerNextReviewDateKey];
    }
}

+ (BOOL)requestThrottledReview
{
    BOOL didTryShow = NO;
    NSDate *const date = [[NSUserDefaults standardUserDefaults] objectForKey:kTJStoreReviewControllerNextReviewDateKey];
    if (!date) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:3600.0 * 24.0 * kTJStoreReviewControllerInitialDaysToRate] forKey:kTJStoreReviewControllerNextReviewDateKey];
    } else {
        if ([date earlierDate:[NSDate date]] == date) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:3600.0 * 24.0 * kTJStoreReviewControllerDaysToRate] forKey:kTJStoreReviewControllerNextReviewDateKey];
            if ([SKStoreReviewController class]) {
                [SKStoreReviewController requestReview];
                didTryShow = YES;
            }
        }
    }
    return didTryShow;
}

+ (void)reviewInAppStore:(NSString *const)appIdentifierString
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:3600.0 * 24.0 * kTJStoreReviewControllerDaysToRate] forKey:kTJStoreReviewControllerNextReviewDateKey];
    NSString *urlFormatString = nil;
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10, 3, 0}]) {
        urlFormatString = @"itms-apps://itunes.apple.com/app/id%@?action=write-review";
    } else {
        urlFormatString = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    }
    NSString *urlString = [NSString stringWithFormat:urlFormatString, appIdentifierString];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
