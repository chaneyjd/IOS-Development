//
//  DataViewController.h
//  JDC2
//
//  Created by Jason Chaney on 9/23/14.
//  Copyright (c) 2014 Jason Chaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;

@end

