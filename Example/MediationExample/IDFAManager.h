//
//  IDFAManager.h
//  MediationExample
//
//  Created by Luan Chen on 2026/1/13.
//  Copyright © 2026 Google, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IDFAStatus) {
    IDFAStatusNotDetermined,  // 尚未决定
    IDFAStatusRestricted,     // 受限制
    IDFAStatusDenied,         // 已拒绝
    IDFAStatusAuthorized      // 已授权
};

@interface IDFAManager : NSObject

+ (instancetype)sharedManager;

// 检查当前授权状态
- (ATTrackingManagerAuthorizationStatus)currentAuthorizationStatus API_AVAILABLE(ios(14.0));
- (IDFAStatus)legacyAuthorizationStatus API_DEPRECATED("Use currentAuthorizationStatus for iOS 14+", ios(4.0, 14.0));

// 请求追踪授权
- (void)requestTrackingAuthorizationWithCompletion:(void(^)(ATTrackingManagerAuthorizationStatus status))completion API_AVAILABLE(ios(14.0));

// 获取 IDFA（如果已授权）
- (NSString * _Nullable)getIDFA;

// 完整的获取流程
- (void)fetchIDFAWithCompletion:(void(^)(NSString * _Nullable idfa, IDFAStatus status))completion;

// 是否可以追踪（iOS 13及以下）
- (BOOL)isAdvertisingTrackingEnabled;

+ (NSString *)stringFromStatus:(ATTrackingManagerAuthorizationStatus)status;
@end

NS_ASSUME_NONNULL_END
