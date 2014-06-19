//
//  MarquetteAppDelegate.m
//  Marquette
//
//  Created by Nicholas Humfrey on 15/01/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MarquetteAppDelegate.h"
#import "MarquetteViewController.h"

#include "getMacAddress.h"
#include "mosquitto.h"


@implementation MarquetteAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize mosquittoClient;


#pragma mark -
#pragma mark Application lifecycle

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:notification.alertAction message:notification.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"other", nil];
    [alertView show];
    if (alertView) {
        [alertView release];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

	NSString *clientId = [NSString stringWithFormat:@"marquette_%@", getMacAddress()];
	NSLog(@"Client ID: %@", clientId);
    mosquittoClient = [[MosquittoClient alloc] initWithClientId:clientId];
	[mosquittoClient setDelegate: self.viewController];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"amqtt" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    MarquetteAppDelegate *app = [[UIApplication sharedApplication] delegate];
	MosquittoClient *mosq = [app mosquittoClient];
    
    NSString *host = [dict objectForKey:@"host"];
    NSLog(@"Value of host is %@", host);
	[mosq setHost: host];
	[mosq connect];
    
    [mosq subscribe:@"com/citi/example/messages"];
    [mosq subscribe:[NSString stringWithFormat:@"com/citi/example/apple/%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    for (int x=0; x < 1000000; x++) {
//        NSLog([NSString stringWithFormat:@"%d",x]);
//    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[mosquittoClient disconnect];
}

- (void) waitforme {
    [NSThread sleepForTimeInterval: 600];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}

- (void)dealloc {
    [viewController release];
    [window release];
	if (mosquittoClient) [mosquittoClient dealloc];

    [super dealloc];
}


@end
