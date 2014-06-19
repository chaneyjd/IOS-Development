//
//  Globals.m
//  mqtt-demo
//
//  Created by Jason Chaney on 6/9/14.
//  Copyright (c) 2014 Jason Chaney. All rights reserved.
//

#import "Globals.h"

@implementation Globals

@synthesize clientID;

#pragma mark Singleton Methods

+ (id)sharedClientID {
    static Globals *sharedGlobals = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGlobals = [[self alloc] init];
    });
    return sharedGlobals;
}

- (id)init {
    if (self = [super init]) {
        
        NSString *lettes = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        NSMutableString *randomstring = [NSMutableString stringWithCapacity:32];
        
        for (int i = 0; i < 32; i++) {
            [randomstring appendFormat: @"%C", [lettes characterAtIndex: arc4random_uniform(32) % [lettes length]]];
        }

        clientID = randomstring;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end
