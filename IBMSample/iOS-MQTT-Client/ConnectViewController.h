//
//  TestViewController.h
//  MQTTTest
//
//  Created by Bryan Boyd on 12/5/13.
//  Copyright (c) 2013 Bryan Boyd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UITextField *serverInput;
@property (weak, nonatomic) IBOutlet UITextField *portInput;
@property (weak, nonatomic) IBOutlet UISwitch *cleanSession;

@end
