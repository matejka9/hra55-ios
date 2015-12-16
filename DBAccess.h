//
//  DBAccess.h
//  hra55
//
//  Created by Sapan Bhatia on 9/29/15.
//  Copyright (c) 2015 Sapan Bhatia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBAccess : NSObject

@property(nonatomic,retain) FMDatabase *database;
+(DBAccess*) sharedInstance;
@end
