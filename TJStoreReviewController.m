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
static const NSUInteger kTJStoreReviewControllerSubsequentDaysToRate = 30;

@implementation TJStoreReviewController

+ (void)appDidLaunch
{
    NSDate *const date = [[NSUserDefaults standardUserDefaults] objectForKey:kTJStoreReviewControllerNextReviewDateKey];
    if (!date) {
        [self deferNextRateDayByDaysFromPresent:kTJStoreReviewControllerInitialDaysToRate];
    }
}

+ (BOOL)requestThrottledReview
{
    BOOL didTryShow = NO;
    NSDate *const date = [[NSUserDefaults standardUserDefaults] objectForKey:kTJStoreReviewControllerNextReviewDateKey];
    if (!date) {
        [self deferNextRateDayByDaysFromPresent:kTJStoreReviewControllerInitialDaysToRate];
    } else {
        if ([date earlierDate:[NSDate date]] == date) {
            [self deferNextRateDayByDaysFromPresent:kTJStoreReviewControllerSubsequentDaysToRate];
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
    [self deferNextRateDayByDaysFromPresent:kTJStoreReviewControllerSubsequentDaysToRate];
    NSString *urlFormatString = nil;
    if (@available(iOS 10.3, *)) {
        urlFormatString = @"itms-apps://itunes.apple.com/app/id%@?action=write-review";
    } else {
        urlFormatString = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    }
    NSString *urlString = [NSString stringWithFormat:urlFormatString, appIdentifierString];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

+ (void)showInAppStore:(NSString *const)appIdentifierString
{
    NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appIdentifierString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

+ (void)deferNextRateDayByDaysFromPresent:(const NSUInteger)daysFromPresent
{
    NSDate *deferDate = [NSDate dateWithTimeIntervalSinceNow:3600.0 * 24.0 * daysFromPresent];
    // Floor the input date to the very beginning of the specified day.
    NSCalendar *const calendar = [NSCalendar currentCalendar];
    NSDateComponents *const deferDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitTimeZone fromDate:deferDate];
    deferDate = [calendar dateFromComponents:deferDateComponents];
    
    [[NSUserDefaults standardUserDefaults] setObject:deferDate forKey:kTJStoreReviewControllerNextReviewDateKey];
}

@end
