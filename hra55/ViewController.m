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

- (void) setTimer {
    seconds=60;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(second:) userInfo:nil repeats:YES];
}

- (void)viewDidLoad {
    
    NSString *newS = [self normalizedString:@"šiRoké e"];
    
    NSLog(@"%@",newS);
    
    NSInteger score = [[NSUserDefaults standardUserDefaults] integerForKey:@"score"];
    self.score.text = [@(score) stringValue];
    
    
    [super viewDidLoad];
    
   
    [self loadNextQuestion];
    
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
        self.time.text=[NSString stringWithFormat:@"00:%02d",seconds];
    }
    
}

- (BOOL)prefersStatusBarHidden { return YES; }



- (void) resetAnswers {
    for (UILabel *l in self.answers) {
        l.text=nil;
    }
}

- (void) loadNextQuestion {
    [self setTimer];
    [self resetAnswers];
    NSInteger questionNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastNumber"]+1;

    
    NSString *url = [NSString stringWithFormat:@"http://hra55-1108.appspot.com/command?action=get_qa&n=%d",questionNumber];
    
    [[NSUserDefaults standardUserDefaults] setInteger:questionNumber forKey:@"lastNumber"];
    
    NSURL *urlRequest = [NSURL URLWithString:url];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:urlRequest];
    
    self.solutions = [NSMutableArray new];
    
    NSMutableDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error)
        NSLog(@"JSONObjectWithData error: %@", error);
    else {
        self.question.text = [NSString stringWithFormat:@"%d. %@",questionNumber, d[@"question"]];
        
        for (NSArray *answer in d[@"answers"]) {
            NSString *ans = answer[0];
            [self.solutions addObject:ans];
        }
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

#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
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
    
    //self.topConstraint.constant=-80;
    
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
}

@end
