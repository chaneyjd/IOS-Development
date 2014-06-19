//
//  MqttTestTrace.m
//  MQTTTest
//
//  Created by Bryan Boyd on 12/5/13.
//  Copyright (c) 2013 Bryan Boyd. All rights reserved.
//

#import "MqttTestTrace.h"

@implementation MqttTestTrace
- (void) traceDebug: (NSString *)message { NSLog(@"D] %@", message); }
- (void) traceLog:   (NSString *)message { NSLog(@"L] %@", message); }
- (void) traceInfo:  (NSString *)message { NSLog(@"I] %@", message); }
- (void) traceWarn:  (NSString *)message { NSLog(@"W] %@", message); }
- (void) traceError: (NSString *)message { NSLog(@"E] %@", message); }
@end
