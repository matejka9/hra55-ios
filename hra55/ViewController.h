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
#import <AVFoundation/AVAudioPlayer.h>

@interface ViewController : UIViewController {
    NSInteger seconds;
    NSTimer *timer;
    AVAudioPlayer *player;
}

@property NSMutableArray *solutions;
@property IBOutlet UILabel *question, *time, *score;;
@property IBOutletCollection(UILabel) NSMutableArray *answers;
@property IBOutlet UITextField *guess;
@property IBOutlet UITextField *someInfo;
@property IBOutlet UIView *loginView;
@property IBOutlet NSLayoutConstraint *topConstraint,*timeConstraint,*heightConstraint,*bottomConstraint;


@property BOOL userFb;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

- (IBAction)submit:(id)sender;
- (void)sendAnswer;


@end

