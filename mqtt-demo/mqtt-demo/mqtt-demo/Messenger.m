//
//  Messenger.m
//  MQTTTest
//
//  Created by Bryan Boyd on 12/6/13.
//  Copyright (c) 2013 Bryan Boyd. All rights reserved.
//

#import "Messenger.h"
#import "MqttOCClient.h"
#import "com_citi_exampleAppDelegate.h"
#import "LogMessage.h"
#import "Subscription.h"
#import "Globals.h"

@interface alertPaymentDueHandler : NSObject  <UIAlertViewDelegate>
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation alertPaymentDueHandler
- (void) alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1)//Save
    {
        NSLog(@"Saved");
        //        NSLog([actionSheet textFieldAtIndex:0].text);
    }
    if (buttonIndex == 0)//NO
    {
        NSLog(@"Not Saved");
        //        NSLog([actionSheet textFieldAtIndex:0].text);
    }
}
@end

// Connect Callbacks
@interface ConnectCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation ConnectCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);
    [[Messenger sharedMessenger] addLogMessage:@"Connected to server!" type:@"Action"];
    //    com_citi_exampleAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"%s:%d - invocationContext=%@  errorCode=%d  errorMessage=%@", __func__,
          __LINE__, invocationContext, errorCode, errorMessage);
    [[Messenger sharedMessenger] addLogMessage:@"Failed to connect!" type:@"Action"];
}
@end

// Publish Callbacks
@interface PublishCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString *)errorMessage;
@end
@implementation PublishCallbacks
- (void) onSuccess:(NSObject *) invocationContext
{
    NSLog(@"PublishCallbacks - onSuccess");
}
- (void) onFailure:(NSObject *) invocationContext errorCode:(int) errorCode errorMessage:(NSString *)errorMessage
{
    NSLog(@"PublishCallbacks - onFailure");
}
@end

// Subscribe Callbacks
@interface SubscribeCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation SubscribeCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"SubscribeCallbacks - onSuccess");
    NSString *topic = (NSString *)invocationContext;
    [[Messenger sharedMessenger] addLogMessage:[NSString stringWithFormat:@"Subscribed to %@", topic] type:@"Action"];
    
    com_citi_exampleAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate reloadSubscriptionList];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"SubscribeCallbacks - onFailure");
}
@end

// Unsubscribe Callbacks
@interface UnsubscribeCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation UnsubscribeCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);
    NSString *topic = (NSString *)invocationContext;
    [[Messenger sharedMessenger] addLogMessage:[NSString stringWithFormat:@"Unsubscribed to %@", topic] type:@"Action"];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"%s:%d - invocationContext=%@  errorCode=%d  errorMessage=%@", __func__, __LINE__, invocationContext, errorCode, errorMessage);
}
@end

@interface GeneralCallbacks : NSObject <MqttCallbacks>
- (void) onConnectionLost:(NSObject*)invocationContext errorMessage:(NSString*)errorMessage;
- (void) onMessageArrived:(NSObject*)invocationContext message:(MqttMessage*)msg;
- (void) onMessageDelivered:(NSObject*)invocationContext messageId:(int)msgId;
//- (void) alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation GeneralCallbacks
- (void) onConnectionLost:(NSObject*)invocationContext errorMessage:(NSString*)errorMessage
{
    [[[Messenger sharedMessenger] subscriptionData] removeAllObjects];
    com_citi_exampleAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate updateConnectButton];
    [appDelegate reloadSubscriptionList];
}
- (void) onMessageArrived:(NSObject*)invocationContext message:(MqttMessage*)msg
{
    int qos = msg.qos;
    BOOL retained = msg.retained;
    NSString *payload = [[NSString alloc] initWithBytes:msg.payload length:msg.payloadLength encoding:NSASCIIStringEncoding];
    NSString *topic = msg.destinationName;
    NSString *retainedStr = retained ? @" [retained]" : @"";
    NSString *logStr = [NSString stringWithFormat:@"[%@ QoS:%d] %@%@", topic, qos, payload, retainedStr];
    NSLog(@"%s:%d - %@", __func__, __LINE__, logStr);
    NSLog(@"GeneralCallbacks - onMessageArrived!");
    [[Messenger sharedMessenger] addLogMessage:logStr type:@"Subscribe"];
    
    NSError *error;
    NSData *jsonData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictData = [NSJSONSerialization
                                  JSONObjectWithData:jsonData
                                  options:kNilOptions
                                  error:&error];
    
    NSString *message = [jsonDictData objectForKey:@"message"];
    NSString *action = [jsonDictData objectForKey:@"action"];
    NSString *pos = [jsonDictData objectForKey:@"pos"];
    NSString *neg = [jsonDictData objectForKey:@"neg"];
    NSString *title = [jsonDictData objectForKey:@"title"];

    [[Messenger sharedMessenger] showAlert:action :message :pos :neg :title];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.alertBody = message;
    notification.alertLaunchImage = @"citi.png";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

//-(void) showAlert:(NSString*)action :(NSString*) message :(NSString*) pos :(NSString*) neg
//{
//    if ([action isEqualToString:@"paymentdue"]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Due" message:message delegate:self cancelButtonTitle:neg otherButtonTitles:pos, nil];
//        alert.alertViewStyle = UIAlertViewStyleDefault;
//        
//        //    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//        //    UITextField *textField = [alert textFieldAtIndex:0];
//        //    textField.placeholder = @"your text";
//
//        [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
//    }
//}
//
//- (void) test1:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    // the user clicked one of the OK/Cancel buttons
//    if (buttonIndex == 1)//Save
//    {
//        NSLog(@"Saved");
//        //        NSLog([actionSheet textFieldAtIndex:0].text);
//    }
//    if (buttonIndex == 0)//NO
//    {
//        NSLog(@"Not Saved");
//        //        NSLog([actionSheet textFieldAtIndex:0].text);
//    }
//}

//- (void) displaymessage {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"got message" message:@"message" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"other", nil];
//    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
////    [alertView textFieldAtIndex:0].delegate = self;
//    [alertView show];
//    //    if (alertView) {
//    //        [alertView release];
//    //    }
//}

- (void) onMessageDelivered:(NSObject*)invocationContext messageId:(int)msgId
{
    NSLog(@"GeneralCallbacks - onMessageDelivered!");
}
@end


@implementation Messenger

@synthesize client;

#pragma mark Singleton Methods

+ (id)sharedMessenger {
    static Messenger *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        self.client = [MqttClient alloc];
        self.clientID = nil;
        self.client.callbacks = [[GeneralCallbacks alloc] init];
        self.logMessages = [[NSMutableArray alloc] init];
        self.SubscriptionData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)connectWithHosts:(NSArray *)hosts ports:(NSArray *)ports clientId:(NSString *)clientId cleanSession:(BOOL)cleanSession
{
    /*NSUInteger currentIndex = 0;
     for (id obj in self.subscriptionData) {
     NSString *topicFilter = ((Subscription *)obj).topicFilter;
     [client unsubscribe:topicFilter invocationContext:topicFilter onCompletion:[[UnsubscribeCallbacks alloc] init]];
     currentIndex++;
     }
     [[self subscriptionData] removeAllObjects];
     AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
     [appDelegate reloadSubscriptionList];*/
    
    client = [client initWithHosts:hosts ports:ports clientId:self.clientID];
    ConnectOptions *opts = [[ConnectOptions alloc] init];
    opts.timeout = 3600;
    opts.cleanSession = cleanSession;
    NSLog(@"%s:%d host=%@, port=%@, clientId=%@", __func__, __LINE__, hosts, ports, clientId);
    [client connectWithOptions:opts invocationContext:self onCompletion:[[ConnectCallbacks alloc] init]];
}

- (void)disconnectWithTimeout:(int)timeout {
    DisconnectOptions *opts = [[DisconnectOptions alloc] init];
    [opts setTimeout:timeout];
    
    [[self subscriptionData] removeAllObjects];
    com_citi_exampleAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate reloadSubscriptionList];
    
    [client disconnectWithOptions:opts invocationContext:self onCompletion:[[ConnectCallbacks alloc] init]];
}

- (void)publish:(NSString *)topic payload:(NSString *)payload qos:(int)qos retained:(BOOL)retained
{
    NSString *retainedStr = retained ? @" [retained]" : @"";
    NSString *logStr = [NSString stringWithFormat:@"[%@] %@%@", topic, payload, retainedStr];
    NSLog(@"%s:%d - %@", __func__, __LINE__, logStr);
    [[Messenger sharedMessenger] addLogMessage:logStr type:@"Publish"];
    
    MqttMessage *msg = [[MqttMessage alloc] initWithMqttMessage:topic payload:(char*)[payload UTF8String] length:(int)payload.length qos:qos retained:retained duplicate:NO];
    [client send:msg invocationContext:self onCompletion:[[PublishCallbacks alloc] init]];
}

- (void)subscribe:(NSString *)topicFilter qos:(int)qos
{
    NSLog(@"%s:%d topicFilter=%@, qos=%d", __func__, __LINE__, topicFilter, qos);
    [client subscribe:topicFilter qos:qos invocationContext:topicFilter onCompletion:[[SubscribeCallbacks alloc] init]];
    
    Subscription *sub = [[Subscription alloc] init];
    sub.topicFilter = topicFilter;
    sub.qos = qos;
    [self.subscriptionData addObject:sub];
}

- (void)unsubscribe:(NSString *)topicFilter
{
    NSLog(@"%s:%d topicFilter=%@", __func__, __LINE__, topicFilter);
    [client unsubscribe:topicFilter invocationContext:topicFilter onCompletion:[[UnsubscribeCallbacks alloc] init]];
    
    NSUInteger currentIndex = 0;
    for (id obj in self.subscriptionData) {
        if ([((Subscription *)obj).topicFilter isEqualToString:topicFilter]) {
            [self.subscriptionData removeObjectAtIndex:currentIndex];
            break;
        }
        currentIndex++;
    }
}

- (void)clearLog
{
    self.logMessages = [[NSMutableArray alloc] init];
}

- (void)addLogMessage:(NSString *)data type:(NSString *)type
{
    LogMessage *msg = [[LogMessage alloc] init];
    msg.data = data;
    msg.type = type;
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    msg.timestamp = [DateFormatter stringFromDate:[NSDate date]];
    
    [self.logMessages addObject:msg];
    com_citi_exampleAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate reloadLog];
}

- (void) showAlert:(NSString*)action :(NSString*) message :(NSString*) pos :(NSString*) neg :(NSString*) title
{
//    alertPaymentDueHandler *avr = [[alertPaymentDueHandler alloc] init];
    if ([action isEqualToString:@"paymentdue"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Due" message:message delegate:self cancelButtonTitle:neg otherButtonTitles:pos, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        alert.restorationIdentifier = action;
        [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    }
    
    if ([action isEqualToString:@"spend"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Spend Alert" message:message delegate:self cancelButtonTitle:neg otherButtonTitles:pos, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        alert.restorationIdentifier = action;
        [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    }

    if ([action isEqualToString:@"spend_pos"]) {
        [[Messenger sharedMessenger] showAlertOK:message :title];
    }

    if ([action isEqualToString:@"spend_neg"]) {
        [[Messenger sharedMessenger] showAlertOK:message :title];
    }

    if ([action isEqualToString:@"activate1"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Activate Your Card" message:message delegate:self cancelButtonTitle:neg otherButtonTitles:pos, nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.placeholder = @"XXXX";
        alert.restorationIdentifier = @"activate2";
        [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    }
    
    if ([action isEqualToString:@"activate-end"]) {
        [[Messenger sharedMessenger] showAlertOK:message :title];
    }
}

- (void) showAlertOK:(NSString *)message :(NSString*) title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

- (void) alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    NSLog(@"%@", actionSheet.restorationIdentifier);
    
    if ([actionSheet.restorationIdentifier isEqualToString:@"spend"]) {
        if (buttonIndex == 1)//Save
        {
            NSLog(@"Saved");
            //        NSLog([actionSheet textFieldAtIndex:0].text);
//            [[Messenger sharedMessenger] showAlertOK:@"Approved" :@"Transaction Approved"];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"mqtt-demo" ofType:@"plist"];
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
            NSString *clientID = [[Globals sharedClientID] clientID];
            NSString *publish = [dict objectForKey:@"publish_topic"];
            NSString *private = [@"apple/" stringByAppendingString:clientID];
            
            NSError *error;
//            NSData *jsonData = [payload dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *jsonDictData = [[NSMutableDictionary alloc] init];
            [jsonDictData setValue:private forKey:@"id"];
            [jsonDictData setValue:@"spend_pos" forKey:@"action"];

            NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonDictData options:0 error:&error] encoding:NSUTF8StringEncoding];

            [[Messenger sharedMessenger] publish:publish payload:jsonString qos:0 retained:false];
        }
        if (buttonIndex == 0)//NO
        {
            NSLog(@"Not Saved");
            //        NSLog([actionSheet textFieldAtIndex:0].text);
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"mqtt-demo" ofType:@"plist"];
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
            NSString *clientID = [[Globals sharedClientID] clientID];
            NSString *publish = [dict objectForKey:@"publish_topic"];
            NSString *private = [@"apple/" stringByAppendingString:clientID];
            
            NSError *error;
            //            NSData *jsonData = [payload dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *jsonDictData = [[NSMutableDictionary alloc] init];
            [jsonDictData setValue:private forKey:@"id"];
            [jsonDictData setValue:@"spend_neg" forKey:@"action"];
            
            NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonDictData options:0 error:&error] encoding:NSUTF8StringEncoding];
            
            [[Messenger sharedMessenger] publish:publish payload:jsonString qos:0 retained:false];
        }
    }
    
    if ([actionSheet.restorationIdentifier isEqualToString:@"activate1"]) {
        if (buttonIndex == 1)//Save
        {
            NSLog(@"Saved");
            //        NSLog([actionSheet textFieldAtIndex:0].text);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Activate Your Card" message:@"Please enter the last four digits of your Social Security Number" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Activate", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *textField = [alert textFieldAtIndex:0];
            textField.placeholder = @"XXXX";
            alert.restorationIdentifier = @"activate2";
            [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
        if (buttonIndex == 0)//NO
        {
            NSLog(@"Not Saved");
            //        NSLog([actionSheet textFieldAtIndex:0].text);
        }
    }

    if ([actionSheet.restorationIdentifier isEqualToString:@"activate2"]) {
        if (buttonIndex == 1)//Save
        {
            NSLog(@"Saved");
            //        NSLog([actionSheet textFieldAtIndex:0].text);
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"mqtt-demo" ofType:@"plist"];
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
            NSString *clientID = [[Globals sharedClientID] clientID];
            
            NSString *publish = [dict objectForKey:@"publish_topic"];
            NSString *private = [@"apple/" stringByAppendingString:clientID];

            NSError *error;
            //            NSData *jsonData = [payload dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *jsonDictData = [[NSMutableDictionary alloc] init];
            [jsonDictData setValue:private forKey:@"id"];
            [jsonDictData setValue:@"activatecard2" forKey:@"action"];
            [jsonDictData setValue:[actionSheet textFieldAtIndex:0].text forKey:@"ssn"];
            [jsonDictData setValue:@"1111222233334444" forKey:@"account"];
            
            
            NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonDictData options:0 error:&error] encoding:NSUTF8StringEncoding];
            
            [[Messenger sharedMessenger] publish:publish payload:jsonString qos:0 retained:false];
//
//            
//            get numbers and submit -> back to say ok / no
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Activate Your Card" message:@"Please enter the last four digits of your Social Security Number" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Activate", nil];
//            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//            UITextField *textField = [alert textFieldAtIndex:0];
//            textField.placeholder = @"XXXX";
//            alert.restorationIdentifier = @"activate3";
//            [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
        if (buttonIndex == 0)//NO
        {
            NSLog(@"Not Saved");
            //        NSLog([actionSheet textFieldAtIndex:0].text);
        }
    }

//    if ([actionSheet.restorationIdentifier isEqualToString:@"activate3"]) {
//        if (buttonIndex == 1)//Save
//        {
//            NSLog(@"Saved");
//            //        NSLog([actionSheet textFieldAtIndex:0].text);
//            publish; build json; as with eclipse; also fix eclipse to send response queue and bot to respond
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Activate Your Card" message:@"Please enter the last four digits of your Social Security Number" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Activate", nil];
//            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//            UITextField *textField = [alert textFieldAtIndex:0];
//            textField.placeholder = @"XXXX";
//            alert.restorationIdentifier = @"activate2";
//            [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
//        }
//        if (buttonIndex == 0)//NO
//        {
//            NSLog(@"Not Saved");
//            //        NSLog([actionSheet textFieldAtIndex:0].text);
//        }
//    }
}


@end