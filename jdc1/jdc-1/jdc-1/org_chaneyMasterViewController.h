//
//  org_chaneyMasterViewController.h
//  jdc-1
//
//  Created by Jason Chaney on 5/17/14.
//  Copyright (c) 2014 Chaney Household. All rights reserved.
//

#import <UIKit/UIKit.h>

@class org_chaneyDetailViewController;

@interface org_chaneyMasterViewController : UITableViewController

@property (strong, nonatomic) org_chaneyDetailViewController *detailViewController;

@end
