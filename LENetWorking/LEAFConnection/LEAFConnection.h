//
//  LEAFConnection.h
//  LeafTest
//
//  Created by Leaf.Chen on 14-1-4.
//  Copyright (c) 2014年 Leaf.Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEAFSoap.h"
#import "LEAFSoapEntity.h"
#import "LEAFCManager.h"

typedef void(^LEAFSoapComplete)(BOOL isSuccess, LEAFStatusType status, NSString * requestString);

@interface LEAFConnection : NSObject <LESoapDelegate> {
    LEAFSoap * _soap;
    LEAFSoapEntity * _entity;
    LEAFSoapComplete _completeBlock;
}

+ (id) LEAFConnectionWithConfigurateName : (NSString *) configurationName
                              requestUrl : (NSString *) requestUrl
                           isSynchonized : (BOOL) isSynchonized;
+ (id) LEAFConnectionWithConfigurateEntity : (LEAFSoapEntity *) entity;
+ (id) LEAFConnectionWithConfigurateName : (NSString *) configurationName
                              requestUrl : (NSString *) requestUrl
                           isSynchonized : (BOOL) isSynchonized
                     parameterDictionary : (NSDictionary *) parameterDict;
- (void) LEAFConnectionConstructWithConfigurationKey : (NSString *) configurationName
                                          requestUrl : (NSString *) requestUrl
                                       isSynchonized : (BOOL) isSynchonized;
- (BOOL) LEAFConnectionConstructWithEntity : (LEAFSoapEntity *) entity;
- (BOOL) LEAFConnectionEntityParameterDictionaryConstructWith : (NSDictionary *) parameterDictionary;
- (void) resetStringValue : (NSString *) value forKey : (NSString *) key;
- (void) resetNumberValue : (NSNumber *) value forKey : (NSString *) key;
- (void) resetBoolValue : (BOOL) value forKey : (NSString *) key;
- (void) resetSoapEntityRequestUrl : (NSString *) requestUrl
                     isSynchonized : (BOOL) isSynchonized
                     isStrongQuote : (BOOL) isStrongQuote;
- (void) cleanParameterDictionary;
- (void) setCompleteBlock : (LEAFSoapComplete) completeBlock;
- (BOOL) prepare;
- (void) start;
- (void) startRequestWithCompleteBlock : (LEAFSoapComplete) completeBlock;
- (LEAFSoapEntity *) getSoapEntity;

@end
