//
//  LEAFSoapEntity.h
//  LeafTest
//
//  Created by Leaf.Chen on 14-1-4.
//  Copyright (c) 2014年 Leaf.Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEAFSoapEntity : NSObject

@property (nonatomic, strong) NSString * requestUrl;
@property (nonatomic, strong) NSString * soapUrl;
@property (nonatomic, strong) NSString * functionName;
@property (nonatomic, strong) NSString * nameSpace;
@property (nonatomic, strong) NSString * soapActionUrl;
@property (nonatomic, strong) NSString * verifyKey;
@property (nonatomic, strong) NSMutableDictionary * parameterDictionary;
@property (nonatomic, assign) BOOL isSyschronized;
@property (nonatomic, assign) BOOL isStrongQuote;

+ (LEAFSoapEntity *) LEAFSoapEntityConstructedByUrl : (NSString *) requestUrl
                                     isSyschronized : (BOOL) isSyschronized
                            configurationDictionary : (NSDictionary *) configurationDictionary;
- (void) setEntityWithConfigurationDictionary : (NSDictionary *) configurationDictionary;
- (void) setParameterStringValue : (NSString *) value forKey : (NSString *) key;
- (void) setParameterNumberValue : (NSNumber *) value forKey : (NSString *) key;
- (void) setParameterBoolValue : (BOOL) value forKey : (NSString *) key;
- (void) copyParameterDictionaryFrom : (NSDictionary *) parameterDictionary;
- (void) cleanParameterDictionary;
- (BOOL) checkEntityIsEffective;
- (NSString *) getUrlString;
- (NSString *) getSoapActionUrlString;

@end
