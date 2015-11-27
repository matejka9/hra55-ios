//
//  LoginViewController.h
//  hra55
//
//  Created by Dusan Matejka on 11/27/15.
//  Copyright © 2015 Gee Whiz Stuff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property BOOL userFb;

-(void)fetchUserInfo;
- (IBAction)loginButtonClicked:(id)sender;
@end
