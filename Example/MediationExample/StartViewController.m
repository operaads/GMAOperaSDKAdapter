//
// Copyright (C) 2017 Google, Inc.
//
// StartViewController.m
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

#import "StartViewController.h"
#import "ViewController.h"
#import "IDFAManager.h"

typedef enum : NSUInteger {
  CellIndexObjC = 0,
  CellIndexSwift,
} CellIndex;

@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
    
    [self requestIDFA];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case CellIndexObjC:
      [self launchViewControllerOfType:AdSourceTypeCustomEventObjC];
      break;
    case CellIndexSwift:
      [self launchViewControllerOfType:AdSourceTypeCustomEventSwift];
      break;
    default:
      break;
  }
}

- (void)launchViewControllerOfType:(AdSourceType)adSourceType {
  AdSourceConfig *config = [AdSourceConfig configWithType:adSourceType];
  ViewController *controller = [ViewController controllerWithAdSourceConfig:config];
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 请求 IDFA

- (void)requestIDFA {
    // 检查当前状态
    if (@available(iOS 14.0, *)) {
        ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
        NSLog(@"当前授权状态: %@", [IDFAManager stringFromStatus:status]);
    }
    
    // 获取 IDFA
    [[IDFAManager sharedManager] fetchIDFAWithCompletion:^(NSString * _Nullable idfa, IDFAStatus status) {
        if (idfa) {
            NSLog(@"成功获取 IDFA: %@", idfa);
            [self sendIDFAToServer:idfa];
        } else {
            NSLog(@"获取 IDFA 失败，状态: %lu", (unsigned long)status);
            
            // 根据状态提示用户
            switch (status) {
                case IDFAStatusNotDetermined:
                    NSLog(@"用户尚未决定");
                    break;
                    
                case IDFAStatusDenied:
                    [self showAuthorizationDeniedAlert];
                    break;
                    
                case IDFAStatusRestricted:
                    NSLog(@"设备限制（如家长控制）");
                    break;
                    
                default:
                    break;
            }
        }
    }];
}


#pragma mark - 辅助方法

- (void)sendIDFAToServer:(NSString *)idfa {
    // 将 IDFA 发送到服务器
//    NSLog(@"发送 IDFA 到服务器: %@", idfa);
//    
//    // 示例网络请求
//    NSDictionary *params = @{
//        @"idfa": idfa,
//        @"device_id": [[[UIDevice currentDevice] identifierForVendor] UUIDString]
//    };
//    
    // 这里添加你的网络请求代码
    // [self sendRequestWithParams:params];
}

- (void)showAuthorizationDeniedAlert {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"广告追踪权限被拒绝"
                         message:@"您可以在设置中重新开启广告追踪权限，以获得更个性化的广告体验"
                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction
        actionWithTitle:@"取消"
                  style:UIAlertActionStyleCancel
                handler:nil];
    
    UIAlertAction *settings = [UIAlertAction
        actionWithTitle:@"前往设置"
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * _Nonnull action) {
                    [self openAppSettings];
                }];
    
    [alert addAction:cancel];
    [alert addAction:settings];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openAppSettings {
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:settingsURL
                                               options:@{}
                                     completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
}

#pragma mark - 在合适时机请求权限

// 可以在应用启动时请求
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 延迟请求，避免在应用刚启动时就弹出权限请求
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkAndRequestAuthorizationIfNeeded];
        });
    });
}

- (void)checkAndRequestAuthorizationIfNeeded {
    if (@available(iOS 14.0, *)) {
        ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
        
        if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
            // 显示引导说明后再请求
            [self showExplanationBeforeRequest];
        }
    }
}

- (void)showExplanationBeforeRequest {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"个性化广告"
                         message:@"为了给您提供更相关的广告内容，我们需要获取广告标识符。这有助于我们优化广告展示，不会收集您的个人信息。"
                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *later = [UIAlertAction
        actionWithTitle:@"稍后再说"
                  style:UIAlertActionStyleCancel
                handler:nil];
    
    UIAlertAction *allow = [UIAlertAction
        actionWithTitle:@"允许追踪"
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * _Nonnull action) {
                    [[IDFAManager sharedManager] requestTrackingAuthorizationWithCompletion:^(ATTrackingManagerAuthorizationStatus status) {
                        NSLog(@"用户选择: %@", [IDFAManager stringFromStatus:status]);
                    }];
                }];
    
    [alert addAction:later];
    [alert addAction:allow];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
