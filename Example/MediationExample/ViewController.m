//
// Copyright (C) 2015 Google, Inc.
//
// ViewController.m
// Mediation Example
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "ViewController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
//#import <SampleAdSDK/SampleAdSDK.h>

#import "ExampleNativeAdView.h"

@interface ViewController () <GADFullScreenContentDelegate, GADNativeAdLoaderDelegate>

@property(nonatomic, strong) AdSourceConfig *config;

@property(nonatomic, weak) IBOutlet GADBannerView *bannerAdView;

@property(weak, nonatomic) IBOutlet UIButton *appOpenButton;

@property(nonatomic, weak) IBOutlet UIButton *interstitialButton;

@property(nonatomic, weak) IBOutlet UIButton *rewardedButton;

@property(weak, nonatomic) IBOutlet UIButton *rewardedInterstitialButton;

@property(assign, nonatomic) BOOL didShowInterstitial;
@property(assign, nonatomic) BOOL didShowRewarded;
@property(assign, nonatomic) BOOL didShowRewardedInterstitial;
@property(assign, nonatomic) BOOL didShowAppOpen;

@property(weak, nonatomic) IBOutlet UIButton *nativeLoadButton;
@property(weak, nonatomic) IBOutlet UIButton *bannerLoadButton;
@property(weak, nonatomic) IBOutlet UIButton *appOpenLoadButton;

@property(nonatomic, weak) IBOutlet UIButton *interstitialLoadButton;

@property(nonatomic, weak) IBOutlet UIButton *rewardedLoadButton;

@property(weak, nonatomic) IBOutlet UIButton *rewardedInterstitialLoadButton;

@property(nonatomic, weak) IBOutlet UIView *nativeAdPlaceholder;

@property(nonatomic, strong) GADAppOpenAd *appOpenAd;

@property(nonatomic, strong) GADInterstitialAd *interstitial;

@property(nonatomic, strong) GADRewardedAd *rewardedAd;

@property(nonatomic, strong) GADRewardedInterstitialAd *rewardedInterstitialAd;

/// You must keep a strong reference to the GADAdLoader during the ad loading process.
@property(nonatomic, strong) GADAdLoader *adLoader;
@property(nonatomic, strong) ExampleNativeAdView *nativeAdView;

/// Shows the most recently loaded interstitial ad in response to a button tap.
- (IBAction)showInterstitial:(UIButton *)sender;

/// Shows the most recently loaded rewarded ad in response to a button tap.
- (IBAction)showRewarded:(UIButton *)sender;

/// Shows the most recently loaded rewarded interstitial ad in response to a button tap.
- (IBAction)showRewardedInterstitial:(UIButton *)sender;

@end

@implementation ViewController

+ (instancetype)controllerWithAdSourceConfig:(AdSourceConfig *)adSourceConfig {
  ViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
      instantiateViewControllerWithIdentifier:@"ViewController"];
  controller.config = adSourceConfig;
  return controller;
}

- (IBAction)refreshNativeAd:(id)sender {
  GADNativeAdViewAdOptions *adViewOptions = [[GADNativeAdViewAdOptions alloc] init];
  adViewOptions.preferredAdChoicesPosition = GADAdChoicesPositionTopRightCorner;

  self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:self.config.nativeAdUnitID
                                     rootViewController:self
                                                adTypes:@[ GADAdLoaderAdTypeNative ]
                                                options:@[ adViewOptions ]];
  self.adLoader.delegate = self;
  [self.adLoader loadRequest:[GADRequest request]];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = self.config.title;
//进页面自动请求? 
//  self.bannerAdView.adUnitID = self.config.bannerAdUnitID;
//  self.bannerAdView.rootViewController = self;
//  [self.bannerAdView loadRequest:[GADRequest request]];
//
//  [self requestAppOpen];
//  [self requestInterstitial];
//  [self requestRewarded];
//  [self requestRewardedInterstitial];
//  [self refreshNativeAd:nil];
}

- (IBAction)loadAppOpen:(UIButton *)sender {
    [self requestAppOpen];
}
- (IBAction)loadInterstitial:(UIButton *)sender {
    [self requestInterstitial];
}
- (IBAction)loadRewarded:(UIButton *)sender {
    [self requestRewarded];
}
- (IBAction)loadRewardedInterstitial:(UIButton *)sender {
    [self requestRewardedInterstitial];
}
- (IBAction)loadNativeAd:(UIButton *)sender {
    [self refreshNativeAd:nil];
}
- (IBAction)loadBanner:(UIButton *)sender {
    self.bannerAdView.adUnitID = self.config.bannerAdUnitID;
    self.bannerAdView.rootViewController = self;
    [self.bannerAdView loadRequest:[GADRequest request]];
}

- (void)requestAppOpen {
  [GADAppOpenAd
       loadWithAdUnitID:self.config.appOpenAdUnitID
                request:[GADRequest request]
      completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
      self.appOpenButton.enabled = YES;
        if (error) {
          NSLog(@"Failed to load an app open ad with error: %@", error.localizedDescription);
          return;
        }
        NSLog(@"App Open ad loaded.");
        self.appOpenAd = appOpenAd;
        self.appOpenAd.fullScreenContentDelegate = self;
      }];
}

- (IBAction)showAppOpen:(UIButton *)sender {
  if (self.appOpenAd && !self.didShowAppOpen) {
      self.didShowAppOpen = YES;
    [self.appOpenAd presentFromRootViewController:self];
  } else {
    NSLog(@"Ad wasn't ready");
      self.didShowAppOpen = NO;
      self.appOpenAd = nil;
      sender.enabled = NO;
    [self requestAppOpen];
  }
}

- (void)requestInterstitial {
  [GADInterstitialAd
       loadWithAdUnitID:self.config.interstitialAdUnitID
                request:[GADRequest request]
      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
      self.interstitialButton.enabled = YES;
        if (error) {
          NSLog(@"Failed to load an interstitial ad with error: %@", error.localizedDescription);
          return;
        }
        NSLog(@"Interstitial ad loaded.");
        self.interstitial = ad;
        self.interstitial.fullScreenContentDelegate = self;
      }];
}


- (IBAction)showInterstitial:(UIButton *)sender {
  if (self.interstitial && !self.didShowInterstitial) {
      self.didShowInterstitial = YES;
    [self.interstitial presentFromRootViewController:self];
  } else {
    NSLog(@"Ad wasn't ready");
      self.didShowInterstitial = NO;
      self.interstitial = nil;
      sender.enabled = NO;
    [self requestInterstitial];
  }
}

- (void)requestRewarded {
  GADRequest *request = [GADRequest request];
  [GADRewardedAd loadWithAdUnitID:self.config.rewardedAdUnitID
                          request:request
                completionHandler:^(GADRewardedAd *ad, NSError *error) {
      self.rewardedButton.enabled = YES;
                  if (error) {
                    // Handle ad failed to load case.
                    NSLog(@"Rewarded ad failed to load with error: %@", error.localizedDescription);
                    return;
                  }
                  // Ad successfully loaded.
                  NSLog(@"Rewarded ad loaded.");
                  self.rewardedAd = ad;
                  self.rewardedAd.fullScreenContentDelegate = self;
                }];
}

- (IBAction)showRewarded:(UIButton *)sender {
    
  if (self.rewardedAd && !self.didShowRewarded) {
      self.didShowRewarded = YES;
    [self.rewardedAd presentFromRootViewController:self
                          userDidEarnRewardHandler:^{
                            GADAdReward *reward = self.rewardedAd.adReward;
                            NSString *rewardMessage = [NSString
                                stringWithFormat:@"Reward received with currency %@ , amount %lf",
                                                 reward.type, [reward.amount doubleValue]];
                            NSLog(@"%@", rewardMessage);
                          }];
  } else {
      self.didShowRewarded = NO;
      self.rewardedAd = nil;
      sender.enabled = NO;
    NSLog(@"Ad wasn't ready");
    [self requestRewarded];
  }
}

- (void)requestRewardedInterstitial {
  GADRequest *request = [GADRequest request];
  [GADRewardedInterstitialAd
       loadWithAdUnitID:self.config.rewardedInterstitialAdUnitID
                request:request
      completionHandler:^(GADRewardedInterstitialAd *_Nullable rewardedInterstitialAd,
                          NSError *_Nullable error) {
      self.rewardedInterstitialButton.enabled = YES;
        if (error) {
          // Handle ad failed to load case.
          NSLog(@"Rewarded interstitial ad failed to load with error: %@",
                error.localizedDescription);
          return;
        }
        // Ad successfully loaded.
        NSLog(@"Rewarded Interstitial ad loaded.");
        self.rewardedInterstitialAd = rewardedInterstitialAd;
        self.rewardedInterstitialAd.fullScreenContentDelegate = self;
      }];
}

- (IBAction)showRewardedInterstitial:(UIButton *)sender {
  if (self.rewardedInterstitialAd && !self.didShowRewardedInterstitial) {
      self.didShowRewardedInterstitial = YES;
    [self.rewardedInterstitialAd
        presentFromRootViewController:self
             userDidEarnRewardHandler:^{
               GADAdReward *reward = self.rewardedInterstitialAd.adReward;
               NSString *rewardMessage =
                   [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
                                              reward.type, [reward.amount doubleValue]];
               NSLog(@"%@", rewardMessage);
             }];
  } else {
      self.didShowRewardedInterstitial = NO;
      self.rewardedInterstitialAd = nil;
      sender.enabled = NO;
    NSLog(@"Ad wasn't ready");
    [self requestRewardedInterstitial];
  }
}

- (void)replaceNativeAdView:(UIView *)nativeAdView inPlaceholder:(UIView *)placeholder {
  // Remove anything currently in the placeholder.
  NSArray *currentSubviews = [placeholder.subviews copy];
  for (UIView *subview in currentSubviews) {
    [subview removeFromSuperview];
  }

  if (!nativeAdView) {
    return;
  }

  // Add new ad view and set constraints to fill its container.
  [placeholder addSubview:nativeAdView];
  nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;

  NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(nativeAdView);
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
}

- (NSString *)getFullScreenAdType:(nonnull id<GADFullScreenPresentingAd>)ad {
  if ([ad isKindOfClass:[GADInterstitialAd class]]) {
    return @"Interstitial ad";
  }
  if ([ad isKindOfClass:[GADRewardedAd class]]) {
    return @"Rewarded ad";
  }
  return @"Full screen ad";
}

#pragma mark GADFullScreenContentDelegate implementation

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
  NSString *fullScreenAdType = [self getFullScreenAdType:ad];
  NSLog(@"%@ failed to present full screen content with error: %@.", fullScreenAdType,
        error.localizedDescription);
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSString *fullScreenAdType = [self getFullScreenAdType:ad];
  NSLog(@"%@ did present full screen content.", fullScreenAdType);
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  NSString *fullScreenAdType = [self getFullScreenAdType:ad];
  NSLog(@"%@ did dismiss full screen content.", fullScreenAdType);
}

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"%@ failed with error: %@", adLoader, error.localizedDescription);
}

#pragma mark Utility Method

/// Gets an image representing the number of stars. Returns nil if rating is less than 3.5 stars.
- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
  double starRating = numberOfStars.doubleValue;
  if (starRating >= 5) {
    return [UIImage imageNamed:@"stars_5"];
  } else if (starRating >= 4.5) {
    return [UIImage imageNamed:@"stars_4_5"];
  } else if (starRating >= 4) {
    return [UIImage imageNamed:@"stars_4"];
  } else if (starRating >= 3.5) {
    return [UIImage imageNamed:@"stars_3_5"];
  } else {
    return nil;
  }
}

#pragma mark GADNativeAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
  NSLog(@"%s, %@", __PRETTY_FUNCTION__, nativeAd);
    
    NSLog(@"akai-101 didReceiveNativeAd: _mediaView: %@ %@ %@",nativeAd,nativeAd.mediaContent,nativeAd.mediaContent.mainImage);
  // Create and place ad in view hierarchy.
  ExampleNativeAdView *nativeAdView =
      [[NSBundle mainBundle] loadNibNamed:@"ExampleNativeAdView" owner:nil options:nil].firstObject;

  nativeAdView.nativeAd = nativeAd;
  UIView *placeholder = self.nativeAdPlaceholder;
  ;
  NSString *awesomenessKey = self.config.awesomenessKey;

  [self replaceNativeAdView:nativeAdView inPlaceholder:placeholder];

  nativeAdView.mediaView.contentMode = UIViewContentModeScaleAspectFit;
  nativeAdView.mediaView.hidden = NO;
  [nativeAdView.mediaView setMediaContent:nativeAd.mediaContent];
  // Populate the native ad view with the native ad assets.
  // Some assets are guaranteed to be present in every native ad.
  ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
  ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
  [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction
                                               forState:UIControlStateNormal];

  // These assets are not guaranteed to be present, and should be checked first.
    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    if (nativeAd.icon != nil) {
      nativeAdView.iconView.hidden = NO;
    } else {
      nativeAdView.iconView.hidden = YES;
    }
    
//    if  (nativeAd.images && nativeAd.images.count > 0 ){
//        GADNativeAdImage *adImage = nativeAd.images.firstObject;
//        ((UIImageView *)nativeAdView.imageView).image = adImage.image;
////        nativeAdView.mediaView.mediaContent.mainImage = image.images.firstObject;
////        ((UIImageView *)nativeAdView.iconView).image = image.image;
//        if (adImage.image != nil) {
//            nativeAdView.imageView.hidden = NO;
//        } else {
//            nativeAdView.imageView.hidden = YES;
//        }
//    }
  ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
  if (nativeAd.starRating) {
    nativeAdView.starRatingView.hidden = NO;
  } else {
    nativeAdView.starRatingView.hidden = YES;
  }

  ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
  if (nativeAd.store) {
    nativeAdView.storeView.hidden = NO;
  } else {
    nativeAdView.storeView.hidden = YES;
  }

  ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
  if (nativeAd.price) {
    nativeAdView.priceView.hidden = NO;
  } else {
    nativeAdView.priceView.hidden = YES;
  }

  ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
  if (nativeAd.advertiser) {
    nativeAdView.advertiserView.hidden = NO;
  } else {
    nativeAdView.advertiserView.hidden = YES;
  }

  // If the ad came from the Sample SDK, it should contain an extra asset, which is retrieved here.
  NSString *degreeOfAwesomeness = nativeAd.extraAssets[awesomenessKey];

  if (degreeOfAwesomeness) {
    nativeAdView.degreeOfAwesomenessView.text = degreeOfAwesomeness;
    nativeAdView.degreeOfAwesomenessView.hidden = NO;
  } else {
    nativeAdView.degreeOfAwesomenessView.hidden = YES;
  }
    self.nativeAdView = nativeAdView;
  // In order for the SDK to process touch events properly, user interaction should be disabled.
//  nativeAdView.callToActionView.userInteractionEnabled = YES;
}

@end
