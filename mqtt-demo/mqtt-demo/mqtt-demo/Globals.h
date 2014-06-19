//
//  Globals.h
//  mqtt-demo
//
//  Created by Jason Chaney on 6/9/14.
//  Copyright (c) 2014 Jason Chaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject
{
    NSString *clientID;
}

@property (nonatomic, retain) NSString *clientID;

+ (id)sharedClientID;

@end