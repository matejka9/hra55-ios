//
//  ViewController.m
//  hra55
//
//  Created by Dusan Matejka on 10/17/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *url = @"http://www.myuyh.com/otazky.txt";
    NSURL *urlRequest = [NSURL URLWithString:url];
    NSError *err = nil;
    self.userFb = NO;
    
    NSString *html = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&err];
    
    if(err)
    {
        //Handle
    }
    
    self.solutions = @[@"peppa pig",
                       @"macko usko",
                       @"ben and holly",
                       @"cielka maja",
                       @"matko a kubko"
                       ];

    // Do any additional setup after loading the view, typically from a nib.
    
    //FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    //loginButton.center = self.view.center;
    //[self.view addSubview:loginButton];
    
    
}

- (IBAction)loginButtonClicked:(id)sender {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void) submit:(id)sender {
    NSString *currentAnswer = self.guess.text;
    NSInteger found;
    [self sendAnswer];
    
    for(found=0;found<self.answers.count;found++) {
        if ([self.solutions[found] isEqualToString:currentAnswer])
            break;
    }
    
    if (found<self.answers.count) {
        ((UITextField *)self.answers[found]).text=self.solutions[found];
    }
    
    self.guess.text=@"";
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user = %@", result);
             }
         }];
    }
}

- (void)sendAnswer{
    NSString *post = [NSString stringWithFormat:@"action=%@&q=%@&a=%@",@"answer",self.question.text, self.guess.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"http://hra55-1108.appspot.com/command"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }
}


@end
