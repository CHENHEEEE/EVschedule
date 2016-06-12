//
//  LEAFCManager.h
//  LeafTest
//
//  Created by Leaf.Chen on 14-1-4.
//  Copyright (c) 2014年 Leaf.Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEAFCManager : NSObject

@property (nonatomic, strong) NSDictionary * LEAFCDictionary;

+ (LEAFCManager *) shareInstance;
- (NSDictionary *) getSoapConfigurationWithName : (NSString *) name;

@end
