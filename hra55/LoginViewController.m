//
//  LoginViewController.m
//  hra55
//
//  Created by Dusan Matejka on 11/27/15.
//  Copyright © 2015 Gee Whiz Stuff. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startButton.hidden = YES;
    self.userFb = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButtonClicked:(id)sender{
    if (!self.userFb){
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                // Process error
                NSLog(@"error %@",error);
            } else if (result.isCancelled) {
                // Handle cancellations
                NSLog(@"Cancelled");
            } else {
                if ([result.grantedPermissions containsObject:@"email"]) {
                    // Do work
                    self.userFb = !self.userFb;
                    self.startButton.hidden = NO;
                    [self fetchUserInfo];
                    UIImage *btnImage = [UIImage imageNamed:@"logout.png"];
                    [self.facebookButton setBackgroundImage:btnImage forState:UIControlStateNormal];
                }
            }
        }];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Log out"
                                                                       message:@"Naozaj sa chcete odhlásiť z facebooku?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Áno" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  UIImage *btnImage = [UIImage imageNamed:@"login.png"];
                                                                  [self.facebookButton setBackgroundImage:btnImage forState:UIControlStateNormal];
                                                                  [[FBSDKLoginManager new] logOut];
                                                                  self.startButton.hidden = YES;
                                                                  self.userFb = !self.userFb;
                                                              }];
        
        [alert addAction:defaultAction];
        
        UIAlertAction* otherAction = [UIAlertAction actionWithTitle:@"Nie" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {}];
        
        [alert addAction:otherAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


-(void)fetchUserInfo {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        NSLog(@"Token is available");
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *uzilovatelovoMeno = result[@"name"];
                 NSString *uzivateloveId = result[@"id"];
                 [[NSUserDefaults standardUserDefaults] setObject:uzilovatelovoMeno forKey:@"facebookName"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [[NSUserDefaults standardUserDefaults] setObject:uzivateloveId forKey:@"facebookId"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 
                 NSLog(@"Meno z fb:%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookName"]);
                 NSLog(@"Id z fb:%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"]);
                 
             }
             else {
                 NSLog(@"Error %@",error);
             }
         }];
        
    } else {
        
        NSLog(@"User is not Logged in");
    }
}


@end
