//
//  AppDelegate.h
//  hra55
//
//  Created by Dusan Matejka on 10/17/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Mixpanel.h"

#define APP_DELEGATE ((AppDelegate *) ([UIApplication sharedApplication].delegate))
#define MIXPANEL_TOKEN @"889f8ea7b0077cf3ef1e0338e9914873"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSDictionary *) mpProperties;
@end

