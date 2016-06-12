//
//  LEAFSoapEntity.m
//  LeafTest
//
//  Created by Leaf.Chen on 14-1-4.
//  Copyright (c) 2014年 Leaf.Chen. All rights reserved.
//

#import "LEAFSoapEntity.h"

@implementation LEAFSoapEntity

@synthesize requestUrl = _requestUrl;
@synthesize soapUrl = _soapUrl;
@synthesize functionName = _functionName;
@synthesize nameSpace = _nameSpace;
@synthesize soapActionUrl = _soapActionUrl;
@synthesize verifyKey = _verifyKey;
@synthesize parameterDictionary = _parameterDictionary;
@synthesize isSyschronized = _isSyschronized;
@synthesize isStrongQuote = _isStrongQuote;

- (id) init {
    self = [super init];
    if ( self ) {
        _parameterDictionary = [NSMutableDictionary dictionary];
        _isSyschronized = YES;
    }
    return self;
}

+ (LEAFSoapEntity *) LEAFSoapEntityConstructedByUrl : (NSString *) requestUrl
                                     isSyschronized : (BOOL) isSyschronized
                            configurationDictionary : (NSDictionary *) configurationDictionary {
    LEAFSoapEntity * entity = [[LEAFSoapEntity alloc] init];
    [entity setEntityWithConfigurationDictionary:configurationDictionary];
    entity.requestUrl = requestUrl == nil ? nil : requestUrl;
    entity.isSyschronized = isSyschronized;
    return entity;
}

- (void) setEntityWithConfigurationDictionary : (NSDictionary *) configurationDictionary {
    _functionName = [configurationDictionary objectForKey:@"functionName"];
    _nameSpace = [configurationDictionary objectForKey:@"nameSpace"];
    _soapUrl = [configurationDictionary objectForKey:@"soapUrl"];
    _soapActionUrl = [configurationDictionary objectForKey:@"soapActionUrl"];
    _verifyKey = [configurationDictionary objectForKey:@"verifyKey"];
    _isStrongQuote = [[configurationDictionary objectForKey:@"isStrongQuote"] boolValue];
    _parameterDictionary = [NSMutableDictionary dictionaryWithDictionary:[configurationDictionary objectForKey:@"parameter"]];
}

- (void) setParameterStringValue : (NSString *) value forKey : (NSString *) key {
    [_parameterDictionary setObject:value forKey:key];
}

- (void) setParameterNumberValue : (NSNumber *) value forKey : (NSString *) key {
    [_parameterDictionary setObject:[value stringValue] forKey:key];
}

- (void) setParameterBoolValue : (BOOL) value forKey : (NSString *) key {
    NSString * sValue = value ? @"true" : @"false";
    [_parameterDictionary setObject:sValue forKey:key];
}

- (void) copyParameterDictionaryFrom : (NSDictionary *) parameterDictionary {
    for ( NSString * key in [parameterDictionary allKeys] ) {
        [_parameterDictionary setObject:[parameterDictionary objectForKey:key] forKey:key];
    }
}

- (void) cleanParameterDictionary {
    _parameterDictionary = nil;
    _parameterDictionary = [NSMutableDictionary dictionary];
}

- (BOOL) checkEntityIsEffective {
    if ( _requestUrl == nil || _requestUrl.length == 0 || _soapUrl == nil || _soapUrl.length == 0 || _functionName == nil || _functionName.length == 0 || _nameSpace == nil || _nameSpace.length == 0 ) {
        return NO;
    }
    return YES;
}

- (NSString *) getUrlString {
    return [NSString stringWithFormat:@"%@%@",_requestUrl,_soapUrl];
}

- (NSString *) getSoapActionUrlString {
    if ( [_soapActionUrl hasPrefix:@"http://"] ) {
        return _soapActionUrl;
    }
    return [NSString stringWithFormat:@"%@%@",_requestUrl,_soapActionUrl];
}

@end
