//
//  LEAFSoap.h
//  LeafTest
//
//  Created by Leaf.Chen on 14-1-3.
//  Copyright (c) 2014年 Leaf.Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, LEAFStatusType ) {
    LEAFSTATUSNORMAL    = 0,
    LEAFNONETWORKSTATUS = 1,
    LEAFPARSERERROR     = 2,
    LEAFVERIFYERROR     = 3,
    LEAFCANCEL          = 4
};

@protocol LESoapDelegate <NSObject>

@optional
- (void) LEAFSoapDidBegin;
- (void) LEAFSoapDidFailed;
- (void) LEAFSoapDidCancel;
- (void) LEAFSoapDidParserBegin;
- (void) LEAFSoapDidParserFailed;
- (void) LEAFSoapDidParserEnd;
- (void) LEAFSoapNotVerifiedKey;

@required
- (void) LEAFSoapEndWithStatus : (LEAFStatusType) status request : (NSString *) request;

@end

@interface LEAFSoap : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate, NSXMLParserDelegate> {
    NSMutableURLRequest * _theRequest;
    NSURLConnection * _theConnection;
    NSMutableData * _requestData;
    NSXMLParser * _xmlParser;
    NSString * _verifyKey;
    NSMutableString * _requestString;
    LEAFStatusType _status;
    BOOL _isSynchronized;
    BOOL _isStrongQuote;
    BOOL _appendLock;
    BOOL _hadUnlock;
}

@property (nonatomic, weak) id<LESoapDelegate> delegate;

+ (LEAFSoap *) LeafSoapWithUrlString : (NSString *) urlStr
                        functionName : (NSString *) functionName
                           nameSpace : (NSString *) nameSpace
                       soapActionUrl : (NSString *) soapActionUrl
                    paramsDictionary : (NSDictionary *) paramsDict
                           verifyKey : (NSString *) verifyKey
                      isSynchronized : (BOOL) isSynchronized
                       isStrongQuote : (BOOL) isStrongQuote;
+ (LEAFSoap *) LeafSoapWithUrlString : (NSString *) urlStr
                        functionName : (NSString *) functionName
                           nameSpace : (NSString *) nameSpace
                       soapActionUrl : (NSString *) soapActionUrl
                    paramsDictionary : (NSDictionary *) paramsDict
                           verifyKey : (NSString *) verifyKey
                      isSynchronized : (BOOL) isSynchronized
                       isStrongQuote : (BOOL) isStrongQuote
                            delegate : (id) delegate;
- (void) constructLEAFSoapRequestWithURLString : (NSString *) urlStr
                                  functionName : (NSString *) functionName
                                     nameSpace : (NSString *) nameSpace
                                 soapActionUrl : (NSString *) soapActionUrl
                              paramsDictionary : (NSDictionary *) paramsDict
                                isSynchronized : (BOOL) isSynchronized;
- (void) setVerifyKey : (NSString *) verifyKey;
- (void) resetQuote : (BOOL) quote;
- (void) start;
- (void) cancel;
- (NSString *) getRequestString;
- (LEAFStatusType) getStatus;


@end
