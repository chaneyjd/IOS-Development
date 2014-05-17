//
//  org_chaneyDetailViewController.h
//  jdc-1
//
//  Created by Jason Chaney on 5/17/14.
//  Copyright (c) 2014 Chaney Household. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface org_chaneyDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
