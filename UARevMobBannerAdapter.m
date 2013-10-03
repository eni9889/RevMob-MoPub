//
//  LSMMobclixAdapter.m
//  LSMSDK
//
//  Copyright (c) 2012 LifeStreet Media. All rights reserved.
//

#import "UARevMobBannerAdapter.h"
#import <RevMobAds/RevMobAds.h>

static CGRect const kLSMMobclixAdViewiPhoneSize = {0, 0, 320, 50};


@interface UARevMobBannerAdapter () <RevMobAdsDelegate>

@property (nonatomic, strong)  RevMobBannerView *revMobAdView;

@end

@implementation UARevMobBannerAdapter

@synthesize revMobAdView;

- (void)dealloc
{
    CCLOG(@"%s: %@", __func__,self.revMobAdView);
    if (self.revMobAdView != nil)
    {
        self.revMobAdView.delegate = nil;
        self.revMobAdView = nil;
    }
}

#pragma mark -

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to load a banner here.
	[super requestAdWithSize:size customEventInfo:info];
    CCLOG(@"%s: info: %@", __func__, info);
    
    BOOL debug = FALSE;
#ifdef DEBUG
    debug = TRUE;
#endif
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive ||
        [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground || debug)
    {
        CCLOG(@"Inactive so going to mobclix");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
    }
    else
    {
        if ([RevMobAds session] == nil)
        {
            [RevMobAds startSessionWithAppID:[info valueForKey:@"id"]];
        }
        
        self.revMobAdView = [[RevMobAds session] bannerViewWithPlacementId:[info valueForKey:@"pid"]]; // you must retain this object
        self.revMobAdView.delegate = self;
        [self.revMobAdView loadAd];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.revMobAdView.frame = CGRectMake(0, 0, 768, 114);
        } else {
            self.revMobAdView.frame = CGRectMake(0, 0, 320, 50);
        }
    }
    
    
    
}

# pragma mark Ad Callbacks (Fullscreen, Banner and Popup)

- (void)revmobAdDidFailWithError:(NSError *)error
{
    CCLOG(@"%s withAd: %@", __func__, self.revMobAdView);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

/**
 Fired by Fullscreen, banner and popup. Called when the communication with the server is finished with success.
 */
- (void)revmobAdDidReceive
{
    CCLOG(@"%s withAd: %@ andDelegate: %@", __func__, self.revMobAdView,self.delegate);
    [self.delegate bannerCustomEvent:self didLoadAd:self.revMobAdView];
}

/**
 Fired by Fullscreen, banner and popup. Called when the Ad is displayed in the screen.
 */
- (void)revmobAdDisplayed
{
    CCLOG(@"%s",__func__);
}

/**
 Fired by Fullscreen, banner, button and popup.
 */
- (void)revmobUserClickedInTheAd
{
    CCLOG(@"%s withAd: %@", __func__, self.revMobAdView);
	[self.delegate bannerCustomEventWillBeginAction:self];
}

/**
 Fired by Fullscreen and popup.
 */
- (void)revmobUserClosedTheAd
{
    CCLOG(@"%s withAd: %@", __func__, self.revMobAdView);
	[self.delegate bannerCustomEventDidFinishAction:self];
}

@end
