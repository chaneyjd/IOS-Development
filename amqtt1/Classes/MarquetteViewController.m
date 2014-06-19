//
//  MarquetteViewController.m
//  Marquette
//
//  Created by Nicholas Humfrey on 15/01/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MarquetteViewController.h"
#import "MarquetteAppDelegate.h"
#import "MosquittoClient.h"

@implementation MarquetteViewController

- (void) didConnect:(NSUInteger)code {
}

- (void) didDisconnect {
    
}

- (void)viewDidLoad {
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"gm.PNG"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void) didReceiveMessage:(MosquittoMessage*) mosq_msg {
    
	NSLog(@"%@ => %@", mosq_msg.topic, mosq_msg.payload);
    
    NSError *error;
    NSData *jsonData = [mosq_msg.payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *allCourses = [NSJSONSerialization
                                JSONObjectWithData:jsonData
                                options:kNilOptions
                                error:&error];
    
    //    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    //    notification.alertBody = mosq_msg.payload;
    //    notification.timeZone = [NSTimeZone defaultTimeZone];
    //    notification.soundName = UILocalNotificationDefaultSoundName;
    //    notification.applicationIconBadgeNumber = 2;
    //
    //    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"got message" message:mosq_msg.payload delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"other", nil];
//    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alertView textFieldAtIndex:0].delegate = self;
//    [alertView show];
//    if (alertView) {
//        [alertView release];
//    }
}

- (void)showAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"got message" message:@"message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alertView textFieldAtIndex:0].delegate = self;
    [alertView show];
    if (alertView) {
        [alertView release];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void) didPublish: (NSUInteger)messageId {}
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos {}
- (void) didUnsubscribe: (NSUInteger)messageId {}

- (void)dealloc {
    [super dealloc];
}

@end
