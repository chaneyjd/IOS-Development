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

//- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
//    NSString *item = @"test";
    /* NSString *itemName = [notif.userInfo objectForKey:ToDoItemKey]; */
//    [MarquetteViewController displayItem:item];
//    app.applicationIconBadgeNumber = +1;
//}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:notification.alertAction message:notification.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

	// FIXME: only if compiled in debug mode?
	//[mosquittoClient setLogPriorities:MOSQ_LOG_ALL destinations:MOSQ_LOG_STDERR];
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
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    int taskID = [UIApplication SharedApplication].BeginBackgroundTask( (self.waitforme) => { });
    [UIApplication sharedApplication
    
    //runs on main or background thread
//    FinishLongRunningTask(taskID);
    
//    UIApplication.SharedApplication.EndBackgroundTask(taskID);

//    // This is where you can do your X Minutes, if >= 10Minutes is okay.
//    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ }];
//    if (backgroundAccepted)
//    {
//        NSLog(@"VOIP backgrounding accepted");
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
