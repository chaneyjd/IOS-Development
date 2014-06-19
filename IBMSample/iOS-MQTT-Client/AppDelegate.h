//
//  AppDelegate.h
//  MQTTTest
//
//  Created by Bryan Boyd on 12/5/13.
//  Copyright (c) 2013 Bryan Boyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectViewController.h"
#import "PublishViewController.h"
#import "SubscribeViewController.h"
#import "LogViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) UITabBarController *tabBar;
@property (weak, nonatomic) ConnectViewController *connectView;
@property (weak, nonatomic) PublishViewController *publishView;
@property (weak, nonatomic) SubscribeViewController *subscribeView;
@property (weak, nonatomic) LogViewController *logView;
@property (weak, nonatomic) UITableView *subListView;

- (void)switchToConnect;
- (void)switchToPublish;
- (void)switchToSubscribe;
- (void)switchToLog;
- (void)clearLog;
- (void)reloadLog;
- (void)updateConnectButton;
- (void)reloadSubscriptionList;

@end
