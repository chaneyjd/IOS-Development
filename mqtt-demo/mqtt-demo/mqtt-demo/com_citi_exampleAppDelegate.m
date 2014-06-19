//
//  com_citi_exampleAppDelegate.m
//  mqtt-demo
//
//  Created by Jason Chaney on 6/6/14.
//  Copyright (c) 2014 Jason Chaney. All rights reserved.
//

#import "com_citi_exampleAppDelegate.h"
#import "Messenger.h"
#import "Globals.h"

@implementation com_citi_exampleAppDelegate {
    NSDictionary *dict;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSLog(@"%s:%d", __func__, __LINE__);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mqtt-demo" ofType:@"plist"];
    dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString *host = [dict objectForKey:@"host"];
    NSString *port = [dict objectForKey:@"port"];
    NSString *clientID = [[Globals sharedClientID] clientID];
    
    NSArray *servers = [NSArray arrayWithObject:host];
    NSArray *ports = [NSArray arrayWithObject:port];
    NSString *public = [dict objectForKey:@"public_topic"];
    NSString *private = [[dict objectForKey:@"private_topic"] stringByAppendingString:clientID];
    
    [[Messenger sharedMessenger] setClientID:clientID];
    [[Messenger sharedMessenger] connectWithHosts:servers ports:ports clientId:clientID cleanSession:true];
    
    sleep(3);

    [[Messenger sharedMessenger] subscribe:public qos:(int)0];
    [[Messenger sharedMessenger] subscribe:private qos:(int)0];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        NSLog(@"Multitasking Supported");
        
        __block UIBackgroundTaskIdentifier background_task;
        background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
            
            //Clean up code. Tell the system that we are done.
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        }];
        
        //To make the code block asynchronous
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //### background task starts
            NSLog(@"Running in the background\n");
            while(TRUE)
            {
                NSLog(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
                [NSThread sleepForTimeInterval:5]; //wait for 1 sec
            }
            //#### background task ends
            
            //Clean up code. Tell the system that we are done.
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
            NSLog(@"Stopped Running in the backdround\n");
        });
    }
    else
    {
        NSLog(@"Multitasking Not Supported");
    }
    

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)updateConnectButton
{
    
}

- (void)reloadSubscriptionList
{
    
}

- (void)clearLog
{
    Messenger *messenger = [Messenger sharedMessenger];
    [messenger clearLog];
    [self reloadLog];
}

- (void)reloadLog
{
    // must do this on the main thread, since we are updating the UI
    dispatch_async(dispatch_get_main_queue(), ^{
        Messenger *messenger = [Messenger sharedMessenger];
        NSString *badge = [NSString stringWithFormat:@"%lu", (unsigned long)[messenger.logMessages count]];
        if ([badge isEqualToString:@"0"]) {
            badge = nil;
        }
        //        self.logView.navigationController.tabBarItem.badgeValue = badge;
        //
        //        [self.logView.tableView reloadData];
    });
}

@end
