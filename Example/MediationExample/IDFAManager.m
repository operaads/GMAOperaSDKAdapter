//
//  IDFAManager.m
//  MediationExample
//
//  Created by Luan Chen on 2026/1/13.
//  Copyright © 2026 Google, Inc. All rights reserved.
//


#import "IDFAManager.h"

@implementation IDFAManager

+ (instancetype)sharedManager {
    static IDFAManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IDFAManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - 权限状态检查

// iOS 14+ 的授权状态
- (ATTrackingManagerAuthorizationStatus)currentAuthorizationStatus {
    if (@available(iOS 14.0, *)) {
        return [ATTrackingManager trackingAuthorizationStatus];
    } else {
        // iOS 14 以下返回未决定状态
        return ATTrackingManagerAuthorizationStatusNotDetermined;
    }
}

// iOS 14 以下的追踪状态
- (IDFAStatus)legacyAuthorizationStatus {
    if (@available(iOS 14.0, *)) {
        // iOS 14+ 应该使用 currentAuthorizationStatus
        ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
        return (IDFAStatus)status;
    } else {
        // iOS 14 以下检查是否允许广告追踪
        BOOL isEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
        return isEnabled ? IDFAStatusAuthorized : IDFAStatusDenied;
    }
}

#pragma mark - 权限请求

- (void)requestTrackingAuthorizationWithCompletion:(void(^)(ATTrackingManagerAuthorizationStatus status))completion {
    if (@available(iOS 14.0, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(status);
                }
            });
        }];
    } else {
        // iOS 14 以下不需要请求权限
        if (completion) {
            ATTrackingManagerAuthorizationStatus status = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] ? 
                ATTrackingManagerAuthorizationStatusAuthorized : ATTrackingManagerAuthorizationStatusDenied;
            completion(status);
        }
    }
}

#pragma mark - 获取 IDFA

- (NSString *)getIDFA {
    // 检查授权状态
    BOOL isAuthorized = NO;
    
    if (@available(iOS 14.0, *)) {
        ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
        isAuthorized = (status == ATTrackingManagerAuthorizationStatusAuthorized);
    } else {
        // iOS 14 以下
        isAuthorized = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    }
    
    if (!isAuthorized) {
        NSLog(@"用户未授权广告追踪");
        return nil;
    }
    
    NSUUID *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString *idfaString = [idfa UUIDString];
    
    // 检查是否是无效的 IDFA（全零）
    if ([idfaString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        return nil;
    }
    
    return idfaString;
}

#pragma mark - 完整流程

- (void)fetchIDFAWithCompletion:(void(^)(NSString * _Nullable idfa, IDFAStatus status))completion {
    if (@available(iOS 14.0, *)) {
        ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
        
        switch (status) {
            case ATTrackingManagerAuthorizationStatusNotDetermined: {
                // 首次使用，需要请求权限
                [self requestTrackingAuthorizationWithCompletion:^(ATTrackingManagerAuthorizationStatus newStatus) {
                    NSString *idfa = nil;
                    if (newStatus == ATTrackingManagerAuthorizationStatusAuthorized) {
                        idfa = [self getIDFA];
                    }
                    if (completion) {
                        completion(idfa, (IDFAStatus)newStatus);
                    }
                }];
                break;
            }
                
            case ATTrackingManagerAuthorizationStatusAuthorized: {
                // 已授权，直接获取
                NSString *idfa = [self getIDFA];
                if (completion) {
                    completion(idfa, IDFAStatusAuthorized);
                }
                break;
            }
                
            case ATTrackingManagerAuthorizationStatusDenied:
            case ATTrackingManagerAuthorizationStatusRestricted: {
                // 用户拒绝或受限制
                if (completion) {
                    completion(nil, (IDFAStatus)status);
                }
                break;
            }
        }
    } else {
        // iOS 14 以下处理
        BOOL isEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
        
        if (isEnabled) {
            NSString *idfa = [self getIDFA];
            if (completion) {
                completion(idfa, IDFAStatusAuthorized);
            }
        } else {
            if (completion) {
                completion(nil, IDFAStatusDenied);
            }
        }
    }
}

#pragma mark - 工具方法

- (BOOL)isAdvertisingTrackingEnabled {
    if (@available(iOS 14.0, *)) {
        return [ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized;
    } else {
        return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    }
}

#pragma mark - 状态描述

+ (NSString *)stringFromStatus:(ATTrackingManagerAuthorizationStatus)status {
    switch (status) {
        case ATTrackingManagerAuthorizationStatusNotDetermined:
            return @"尚未决定";
        case ATTrackingManagerAuthorizationStatusRestricted:
            return @"受限制";
        case ATTrackingManagerAuthorizationStatusDenied:
            return @"已拒绝";
        case ATTrackingManagerAuthorizationStatusAuthorized:
            return @"已授权";
        default:
            return @"未知状态";
    }
}

@end