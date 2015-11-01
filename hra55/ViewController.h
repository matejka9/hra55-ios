//
//  ViewController.h
//  hra55
//
//  Created by Dusan Matejka on 10/17/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ViewController : UIViewController

@property NSMutableArray *solutions;
@property IBOutlet UILabel *question;
@property IBOutletCollection(UITextField) NSMutableArray *answers;
@property IBOutlet UITextField *guess;
@property IBOutlet UITextField *someInfo;
@property BOOL userFb;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

- (IBAction)submit:(id)sender;
- (void)sendAnswer;


@end

