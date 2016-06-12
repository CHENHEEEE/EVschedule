//
//  LEAFCManager.m
//  LeafTest
//
//  Created by Leaf.Chen on 14-1-4.
//  Copyright (c) 2014年 Leaf.Chen. All rights reserved.
//

#import "LEAFCManager.h"

@implementation LEAFCManager

@synthesize LEAFCDictionary = _LEAFCDictionary;

- (id) init {
    self = [super init];
    if ( self ) {
        _LEAFCDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LEAFSoapConfiguration" ofType:@"plist"]];
    
    }
    return self;
}

+ (LEAFCManager *) shareInstance {
    static LEAFCManager * __singleton;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        __singleton = [[self alloc] init];
    });
    return __singleton;
}

- (NSDictionary *) getSoapConfigurationWithName : (NSString *) name {
    return [_LEAFCDictionary objectForKey:name];
}

@end
