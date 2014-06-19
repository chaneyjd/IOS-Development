//
//  com_citi_exampleViewController.m
//  mqtt-demo
//
//  Created by Jason Chaney on 6/6/14.
//  Copyright (c) 2014 Jason Chaney. All rights reserved.
//

#import "com_citi_exampleViewController.h"

@interface com_citi_exampleViewController ()

@end

@implementation com_citi_exampleViewController

- (void)viewDidLoad
{
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [[UIImage imageNamed:@"gm.PNG"] drawInRect:self.view.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gm.png"]];
    NSLog(@"viewDidLoad");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
