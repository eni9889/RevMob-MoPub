//
//  GreystripeInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UARevMobInterstitialAdapter.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UARevMobInterstitialAdapter ()

@property (nonatomic, retain) RevMobFullscreen *revmobFullscreenAd;

@end

@implementation UARevMobInterstitialAdapter

@synthesize revmobFullscreenAd = _revmobFullscreenAd;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    CCLOG(@"%s: %@",__func__,info);
    if ([RevMobAds session] == nil)
    {
        [RevMobAds startSessionWithAppID:[info valueForKey:@"id"]];
    }
    
    self.revmobFullscreenAd = [[RevMobAds session] fullscreen];
    self.revmobFullscreenAd.delegate = self;
    [self.revmobFullscreenAd loadAd];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.revmobFullscreenAd showAd];
}

- (void)dealloc
{
    CCLOG(@"%s",__func__);
    self.revmobFullscreenAd.delegate = nil;
    self.revmobFullscreenAd = nil;
}

- (void)revmobAdDidFailWithError:(NSError *)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

# pragma mark Ad Callbacks (Fullscreen, Banner and Popup)

/**
 Fired by Fullscreen, banner and popup. Called when the communication with the server is finished with success.
 */
- (void)revmobAdDidReceive
{
    [self.delegate interstitialCustomEvent:self didLoadAd:self.revmobFullscreenAd];
}

/**
 Fired by Fullscreen, banner and popup. Called when the Ad is displayed in the screen.
 */
- (void)revmobAdDisplayed
{
    [self.delegate interstitialCustomEventWillAppear:self];
    
    // RevMob doesn't seem to have a separate callback for the "did appear" event, so we
    // signal that manually.
    [self.delegate interstitialCustomEventDidAppear:self];
}

/**
 Fired by Fullscreen, banner, button and popup.
 */
- (void)revmobUserClickedInTheAd
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

/**
 Fired by Fullscreen and popup.
 */
- (void)revmobUserClosedTheAd
{
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
