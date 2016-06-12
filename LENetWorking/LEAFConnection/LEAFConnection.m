//
//  LEAFConnection.m
//  LeafTest
//
//  Created by Leaf.Chen on 14-1-4.
//  Copyright (c) 2014年 Leaf.Chen. All rights reserved.
//

#import "LEAFConnection.h"

@implementation LEAFConnection

- (id) init {
    self = [super init];
    if ( self ) {
        _entity = [[LEAFSoapEntity alloc] init];
    }
    return self;
}

+ (id) LEAFConnectionWithConfigurateName : (NSString *) configurationName
                              requestUrl : (NSString *) requestUrl
                           isSynchonized : (BOOL) isSynchonized {
    LEAFConnection * connection = [[LEAFConnection alloc] init];
    [connection LEAFConnectionConstructWithConfigurationKey:configurationName
                                                 requestUrl:requestUrl
                                              isSynchonized:isSynchonized];
    return connection;
}

+ (id) LEAFConnectionWithConfigurateEntity : (LEAFSoapEntity *) entity{
    LEAFConnection * connection = [[LEAFConnection alloc] init];
    if ( [connection LEAFConnectionConstructWithEntity:entity] ) {
        [connection prepare];
        return connection;
    }
    return nil;
}

+ (id) LEAFConnectionWithConfigurateName : (NSString *) configurationName
                              requestUrl : (NSString *) requestUrl
                           isSynchonized : (BOOL) isSynchonized
                     parameterDictionary : (NSDictionary *) parameterDict {
    LEAFConnection * connection = [[LEAFConnection alloc] init];
    [connection LEAFConnectionConstructWithConfigurationKey:configurationName
                                                 requestUrl:requestUrl
                                              isSynchonized:isSynchonized];
    if ( [connection LEAFConnectionEntityParameterDictionaryConstructWith:parameterDict] ) {
        [connection prepare];
        return connection;
    }
    return nil;
}

- (void) LEAFConnectionConstructWithConfigurationKey : (NSString *) configurationName
                                          requestUrl : (NSString *) requestUrl
                                       isSynchonized : (BOOL) isSynchonized {
    _entity = [LEAFSoapEntity LEAFSoapEntityConstructedByUrl:requestUrl
                                              isSyschronized:isSynchonized
                                     configurationDictionary:[[LEAFCManager shareInstance] getSoapConfigurationWithName:configurationName]];
}

- (BOOL) LEAFConnectionEntityParameterDictionaryConstructWith : (NSDictionary *) parameterDictionary {
    if ( [self isSoapConfigurationEntityIsEffective] ) {
        [_entity copyParameterDictionaryFrom:parameterDictionary];
        return YES;
    }
    return NO;
}

- (BOOL) LEAFConnectionConstructWithEntity : (LEAFSoapEntity *) entity {
    if ( [entity checkEntityIsEffective] ) {
        _entity = entity;
        return YES;
    } else {
        printf("LEAFConnection : not correct configuration or construct for your input <entity>!");
    }
    return NO;
}

- (void) resetStringValue : (NSString *) value forKey : (NSString *) key {
    if ( [self isSoapConfigurationEntityIsEffective] ) {
        [_entity setParameterStringValue:value forKey:key];
    }
}

- (void) resetNumberValue : (NSNumber *) value forKey : (NSString *) key {
    if ( [self isSoapConfigurationEntityIsEffective] ) {
        [_entity setParameterNumberValue:value forKey:key];
    }
}

- (void) resetBoolValue : (BOOL) value forKey : (NSString *) key {
    if ( [self isSoapConfigurationEntityIsEffective] ) {
        [_entity setParameterBoolValue:value forKey:key];
    }
}

- (void) resetSoapEntityRequestUrl : (NSString *) requestUrl
                     isSynchonized : (BOOL) isSynchonized
                     isStrongQuote : (BOOL) isStrongQuote{
    if ( [self isSoapConfigurationEntityIsEffective] ) {
        [_entity setRequestUrl:requestUrl];
        [_entity setIsSyschronized:isSynchonized];
        [_entity setIsStrongQuote:isStrongQuote];
    }
}

- (BOOL) isSoapConfigurationEntityIsEffective {
    if ( _entity == nil ) {
        printf("LEAFConnection : <_entity> had not be init! you will resived nil!");
    } else if ( ![_entity checkEntityIsEffective] ) {
        printf("LEAFConnection : <_entity> not corrected configurated before you wanna use!");
    } else {
        return YES;
    }
    return NO;
}

- (void) cleanParameterDictionary {
    if ( [self isSoapConfigurationEntityIsEffective] ) {
        [_entity cleanParameterDictionary];
    }
}

- (void) setCompleteBlock : (LEAFSoapComplete) completeBlock {
    _completeBlock = completeBlock;
}

- (BOOL) prepare {
    if ( [self isSoapConfigurationEntityIsEffective] ) {
        @autoreleasepool {
            _soap = nil;
            _soap = [LEAFSoap LeafSoapWithUrlString:[_entity getUrlString]
                                       functionName:[_entity functionName]
                                          nameSpace:[_entity nameSpace]
                                      soapActionUrl:[_entity getSoapActionUrlString]
                                   paramsDictionary:[_entity parameterDictionary]
                                          verifyKey:[_entity verifyKey]
                                     isSynchronized:[_entity isSyschronized]
                                      isStrongQuote:[_entity isStrongQuote]
                                           delegate:self];
        }
        return YES;
    }
    return NO;
}

- (void) start {
    if ( _soap ) {
        [_soap start];
    } else {
        printf("LEAFConnection : may need you call <prepare> before you wanna start!");
    }
}

- (void) startRequestWithCompleteBlock : (LEAFSoapComplete) completeBlock {
    _completeBlock = completeBlock;
    if ( _completeBlock ) {
        NSLog(@"_completeBlock:true");
    }
    [self start];
}

- (LEAFSoapEntity *) getSoapEntity {
    [self isSoapConfigurationEntityIsEffective];
    return _entity;
}

//LEAFSoapDelegate
- (void) LEAFSoapEndWithStatus : (LEAFStatusType) status request : (NSString *) request {
    if ( _completeBlock ) {
        _completeBlock(status == LEAFSTATUSNORMAL, status, request);
    }
}

@end
