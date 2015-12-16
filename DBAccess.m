//
//  DBAccess.m
//  hra55
//
//  Created by Sapan Bhatia on 9/29/15.
//  Copyright (c) 2015 Sapan Bhatia. All rights reserved.
//

#import "DBAccess.h"
#import "FMDatabase.h"

@implementation DBAccess

+(DBAccess*) sharedInstance
{
    static DBAccess *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (DBAccess *) init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *absolutePath = [documentsDirectory stringByAppendingPathComponent:@"questions.db"];
        
        FMDatabase *db = [FMDatabase databaseWithPath:absolutePath];
        if (![db open]) {
            [self createDB];
        }
        self.database = db;
        
    }
    return self;
}

-(void) createDB
{
    BOOL result = [self.database executeUpdate:@"CREATE table qna(id INTEGER PRIMARY KEY AUTOINCREMENT, date DATE DEFAULT CURRENT_TIMESTAMP, question VARCHAR, answer VARCHAR, count INT, played INT)"];
    if (!result) {
        NSLog(@"Error creating table: %@", [self.database lastErrorMessage]);
    }
}

- (void) addQuestionToDB:(NSString *) question answer:(NSString *) answer count:(NSInteger) count {

    NSString *insertString = [NSString stringWithFormat:@"INSERT INTO table qna (question, answer, count, played) VALUES (\"%@\",\"%@\",%ld,%d)]",question,answer,(long)count,0];
    BOOL result = [self.database executeUpdate:insertString];
    if (!result) {
        NSLog(@"Error adding to table: %@", [self.database lastErrorMessage]);
    }
}


@end
