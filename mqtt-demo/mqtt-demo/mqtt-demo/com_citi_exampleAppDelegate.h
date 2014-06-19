//
//  com_citi_exampleAppDelegate.h
//  mqtt-demo
//
//  Created by Jason Chaney on 6/6/14.
//  Copyright (c) 2014 Jason Chaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface com_citi_exampleAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)updateConnectButton;
- (void)reloadSubscriptionList;
- (void)clearLog;
- (void)reloadLog;

@end
