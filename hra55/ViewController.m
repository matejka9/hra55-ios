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
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) setTimer {
    seconds=30;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(second:) userInfo:nil repeats:YES];
}

- (void)viewDidLoad {
    
    NSInteger score = [[NSUserDefaults standardUserDefaults] integerForKey:@"score"];
    self.score.text = [@(score) stringValue];
    
    
    
    [super viewDidLoad];
    self.userFb = NO;
   
    [self loadNextQuestion];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"first"]) {
        self.guess.placeholder = [NSString stringWithFormat:@"Tap here and answer. E.g. write %@",self.solutions[0]];
    }
    
}

- (void)alertView:(UIAlertView *)alertView
        didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self loadNextQuestion];
}

- (void) second: (NSTimer *) t {
    seconds--;
    if (!seconds) {
        [t invalidate];
        UIAlertView *aView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Spravne odpovede: 1. %@\n2. %@\n3. %@\n4. %@\n5. %@.\nStlacte OK pre dalsiu otazku",self.solutions[0],self.solutions[1],self.solutions[2],self.solutions[3],self.solutions[4]] message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [aView show];

    } else {
        //self.time.text=[NSString stringWithFormat:@"00:%02d",seconds];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        self.timeConstraint.constant = (1.0 - seconds/30.0)*(screenWidth-40)-30;
    }
    
}

- (BOOL)prefersStatusBarHidden { return YES; }

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

- (void) resetAnswers {
    for (UILabel *l in self.answers) {
        l.text=nil;
    }
}


- (void) loadNextQuestion {
    
    [self.guess resignFirstResponder];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"v2_nextQuestion" properties:[APP_DELEGATE mpProperties]];
    [self setTimer];
    [self resetAnswers];
    NSInteger questionNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastNumber"]+1;

    
    NSString *url = [NSString stringWithFormat:@"http://hra55-1108.appspot.com/command?action=get_qa&n=%ld",questionNumber];
    
    [[NSUserDefaults standardUserDefaults] setInteger:questionNumber forKey:@"lastNumber"];
    
    NSURL *urlRequest = [NSURL URLWithString:url];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:urlRequest];
    
    self.solutions = [NSMutableArray new];
    
    NSMutableDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error)
        NSLog(@"JSONObjectWithData error: %@", error);
    else {
        self.question.text = [NSString stringWithFormat:@"%ld. %@",(long)questionNumber, d[@"question"]];
        
        for (NSArray *answer in d[@"answers"]) {
            NSString *ans = answer[0];
            [self.solutions addObject:ans];
        }
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

- (NSString *) normalizedString:(NSString *) str {
    NSDictionary *map = @{
        @".":@"",
        @",":@"",
        @";":@"",
        @"-":@"",
        @"+":@"",
        @"á":@"a",
        @"ä":@"a",
        @"č":@"c",
        @"ď":@"d",
        @"ž":@"z",
        @"é":@"e",
        @"ľ":@"l",
        @"ň":@"n",
        @"ó":@"o",
        @"í":@"i",
        @"ĺ":@"l",
        @"ô":@"o",
        @"ŕ":@"r",
        @"š":@"s",
        @"ť":@"t",
        @"ú":@"u",
        @"ý":@"y",
        @"ž":@"z"
    };
    
    str = str.lowercaseString;
    for (NSInteger charIdx=0; charIdx<str.length; charIdx++) {
        NSString *cS = [str substringWithRange:NSMakeRange(charIdx, 1)];
        NSString *cN = [map objectForKey:cS];
        if (cN) {
            str = [str stringByReplacingCharactersInRange:NSMakeRange(charIdx, 1) withString:cN];
        }
    }
    
    return str;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self submit:textField];
    return NO;
}

- (void) submit:(id)sender {
    NSString *currentAnswer = self.guess.text;
    NSInteger found;
    [self sendAnswer];
    
    for(found=0;found<self.answers.count;found++) {
        NSString *option1 = [self normalizedString:self.solutions[found]];
        NSString *option2 = [self normalizedString:currentAnswer];
        
        if ([option1 isEqualToString:option2])
            break;
    }
    
    if (found<self.answers.count) {
        ((UITextField *)self.answers[found]).text=self.solutions[found];
        NSInteger score = [[NSUserDefaults standardUserDefaults] integerForKey:@"score"];
        score++;
        self.score.text= [@(score) stringValue];
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"score"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *path;
        
        NSURL *url;
        
        //where you are about to add sound
        
        path = [[NSBundle mainBundle] pathForResource:@"bravo1" ofType:@"m4a"];
        
        url = [NSURL fileURLWithPath:path];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        [player setVolume:1.0];
        [player play];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"first"];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"v2_goodGuess" properties:[APP_DELEGATE mpProperties]];
    } else {
        NSString *path;
        
        NSURL *url;
        
        //where you are about to add sound
        
        path = [[NSBundle mainBundle] pathForResource:@"coin-poof-1" ofType:@"m4a"];
        
        url = [NSURL fileURLWithPath:path];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        [player setVolume:0.2];
        [player play];
       
        UIView *lockView = self.guess;
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:4];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([lockView center].x - 20.0f, [lockView center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([lockView center].x + 20.0f, [lockView center].y)]];
        [[lockView layer] addAnimation:animation forKey:@"position"];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"v2_badGuess" properties:[APP_DELEGATE mpProperties]];
    }
    
    self.guess.text=@"";
    
    
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

#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow {
    [self setViewMovedUp:YES];
}

-(void)keyboardWillHide {
    [self setViewMovedUp:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:self.guess])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    if (movedUp) {
        self.topConstraint.constant=-45;
        self.question.alpha=0;
        
        if ([ [ UIScreen mainScreen ] bounds ].size.height < 500) {
            self.heightConstraint.constant=25;
        }
        self.bottomConstraint.constant=10;
    }
    else {
        self.topConstraint.constant=40;
        self.question.alpha=0;
        self.heightConstraint.constant=40;
        self.bottomConstraint.constant=40;
        self.question.alpha=1;
    }
    
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [timer invalidate];
    timer = nil;
    
    NSString *fbId = [[NSUserDefaults standardUserDefaults] stringForKey:@"fbid"];
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"fbname"];
    NSInteger score = [[NSUserDefaults standardUserDefaults] integerForKey:@"score"];
    if (fbId) {
        NSString *url = [NSString stringWithFormat:@"http://hra55-1108.appspot.com/command?action=ss&fbid=%@&fbname=%@&score=%ld",fbId,[name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],score];
        
        NSURL *urlRequest = [NSURL URLWithString:url];
        [NSData dataWithContentsOfURL:urlRequest];
    }
    // XXX
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

@end
