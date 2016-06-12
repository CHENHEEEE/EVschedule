//
//  LEAFSoap.m
//  LeafTest
//
//  Created by Leaf.Chen on 14-1-3.
//  Copyright (c) 2014年 Leaf.Chen. All rights reserved.
//

#import "LEAFSoap.h"

@implementation LEAFSoap

@synthesize delegate = _delegate;

- (id) init {
    self = [super init];
    if ( self ) {
        _status = LEAFSTATUSNORMAL;
        _isStrongQuote = NO;
        _appendLock = NO;
        _hadUnlock = NO;
    }
    return self;
}

+ (LEAFSoap *) LeafSoapWithUrlString : (NSString *) urlStr
                        functionName : (NSString *) functionName
                           nameSpace : (NSString *) nameSpace
                       soapActionUrl : (NSString *) soapActionUrl
                    paramsDictionary : (NSDictionary *) paramsDict
                           verifyKey : (NSString *) verifyKey
                      isSynchronized : (BOOL) isSynchronized
                       isStrongQuote : (BOOL) isStrongQuote {
    LEAFSoap * soap = [[LEAFSoap alloc] init];
    [soap resetQuote:isStrongQuote];
    [soap constructLEAFSoapRequestWithURLString:urlStr
                                   functionName:functionName
                                      nameSpace:nameSpace
                                  soapActionUrl:soapActionUrl
                               paramsDictionary:paramsDict
                                 isSynchronized:isSynchronized];
    [soap setVerifyKey:verifyKey];
    return soap;
}

+ (LEAFSoap *) LeafSoapWithUrlString : (NSString *) urlStr
                        functionName : (NSString *) functionName
                           nameSpace : (NSString *) nameSpace
                       soapActionUrl : (NSString *) soapActionUrl
                    paramsDictionary : (NSDictionary *) paramsDict
                           verifyKey : (NSString *) verifyKey
                      isSynchronized : (BOOL) isSynchronized
                       isStrongQuote : (BOOL) isStrongQuote
                            delegate : (id) delegate {
    LEAFSoap * soap = [[LEAFSoap alloc] init];
    [soap resetQuote:isStrongQuote];
    [soap constructLEAFSoapRequestWithURLString:urlStr
                                   functionName:functionName
                                      nameSpace:nameSpace
                                  soapActionUrl:soapActionUrl
                               paramsDictionary:paramsDict
                                 isSynchronized:isSynchronized];
    [soap setVerifyKey:verifyKey];
    soap.delegate = delegate;
    return soap;
}

- (void) constructLEAFSoapRequestWithURLString : (NSString *) urlStr
                                  functionName : (NSString *) functionName
                                     nameSpace : (NSString *) nameSpace
                                 soapActionUrl : (NSString *) soapActionUrl
                              paramsDictionary : (NSDictionary *) paramsDict
                                isSynchronized : (BOOL) isSynchronized {
    NSString * soapMessage = [self assembledSoapRequestWithFunctionName:functionName
                                                              nameSpace:nameSpace
                                                             paramsDict:paramsDict];
    NSString * soapLength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    
    NSURL * theURL = [NSURL URLWithString:urlStr];
    _theRequest = [NSMutableURLRequest requestWithURL:theURL];
    [_theRequest setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [_theRequest setValue:soapActionUrl forHTTPHeaderField:@"SOAPAction"];
    [_theRequest setValue:soapLength forHTTPHeaderField:@"Content-Length"];
    [_theRequest setHTTPMethod:@"POST"];
    [_theRequest setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [_theRequest setTimeoutInterval:60.0];
    
    _isSynchronized = isSynchronized;
    if ( !_isSynchronized ) {
        _theConnection = [[NSURLConnection alloc] initWithRequest:_theRequest delegate:self];
    }
}

- (void) start {
    if ( _isSynchronized ) {
        NSError * error = nil;
        [self soapBegin];
        _requestData = [NSMutableData dataWithData:[NSURLConnection sendSynchronousRequest:_theRequest
                                                                         returningResponse:nil
                                                                                     error:&error]];
        if ( error ) {
            _status = LEAFNONETWORKSTATUS;
            [self soapFailed];
            [self soapEnd];
        } else {
            [self beginSOAPXMLParser];
        }
    } else if ( _theConnection ) {
        [self soapBegin];
        [_theConnection start];
    }
}

- (void) cancel {
    if ( _theConnection ) {
        [_theConnection cancel];
    }
}

- (void) setVerifyKey : (NSString *) verifyKey {
    _verifyKey = [verifyKey uppercaseString];
}

- (NSString *) getRequestString {
    return _requestString ? _requestString : nil;
}

- (LEAFStatusType) getStatus {
    return  _status;
}

- (void) resetQuote : (BOOL) quote {
    _isStrongQuote = quote;
}

//ConnectionDelegate
- (void) connection : (NSURLConnection *) connection didReceiveResponse : (NSURLResponse *) response {
    _requestData = nil;
    _requestData = [NSMutableData data];
}

- (void) connection : (NSURLConnection *) connection didReceiveData : (NSData *) data {
    [_requestData appendData:data];
}

- (void) connection : (NSURLConnection *) connection didFailWithError : (NSError *) error {
    _status = LEAFNONETWORKSTATUS;
    [self soapFailed];
    [self soapEnd];
}

- (void) connection : (NSURLConnection *) connection didCancelAuthenticationChallenge : (NSURLAuthenticationChallenge *) challenge {
    _status = LEAFCANCEL;
    [self soapCancel];
    [self soapEnd];
}

- (void) connectionDidFinishLoading : (NSURLConnection *) connection {
    [self beginSOAPXMLParser];
}

- (void) beginSOAPXMLParser {
    [self parserBegin];
    _xmlParser = nil;
    _xmlParser = [[NSXMLParser alloc] initWithData:_requestData];
    [_xmlParser setShouldGroupAccessibilityChildren:YES];
    [_xmlParser setShouldProcessNamespaces:YES];
    [_xmlParser setShouldReportNamespacePrefixes:YES];
    _xmlParser.delegate = self;
    [_xmlParser parse];
}

//XMLParserDelegate
- (void) parser : (NSXMLParser *) parser
didStartElement : (NSString *) elementName
   namespaceURI : (NSString *) namespaceURI
  qualifiedName : (NSString *) qName
     attributes : (NSDictionary *) attributeDict {
    if ( _requestString == nil ) {
        _requestString = [NSMutableString string];
    }
    if ( _appendLock ) {
        [_requestString appendString:[self recodingXMLFromQualifieldName : qName attributes : attributeDict]];
    } else if ( [[elementName uppercaseString] isEqualToString:_verifyKey] ) {
        _appendLock = YES;
        _hadUnlock = YES;
    }
}

- (void) parser : (NSXMLParser *) parser
foundCharacters : (NSString *) string {
    [_requestString appendString:string];
    AppDelegate *appdelegate = [[UIApplication sharedApplication]delegate];
    switch (appdelegate.state) {
        case NSlogin:
            break;
        case NSStuList:{
            NSString *temp = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [appdelegate.StuList addObject:temp];
            break;
        }
        case NSSchedule:{
            if(appdelegate.Scheduleneedrefresh){
                [appdelegate.Schedule removeAllObjects];
                appdelegate.Scheduleneedrefresh = NO;
            }
            NSString *temp = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [appdelegate.Schedule addObject:temp];
            break;
        }
        case NSUpdatetime:{
            if(appdelegate.updatetimeneedrefresh){
                [appdelegate.updatetime removeAllObjects];
                appdelegate.updatetimeneedrefresh = NO;
            }
            NSString *temp = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([self validateNum:temp] ||[temp isEqualToString:@""]){
                [appdelegate.updatetime addObject:temp];
            }else{
                NSInteger count = appdelegate.updatetime.count -1;
                NSString *s = appdelegate.updatetime.lastObject;
                s = [s stringByAppendingString:temp];
                [appdelegate.updatetime replaceObjectAtIndex:count withObject:s];
            }
            break;
        }
        default:
            break;
    }
}

- (void) parser : (NSXMLParser *) parser
  didEndElement : (NSString *) elementName
   namespaceURI : (NSString *) namespaceURI
  qualifiedName : (NSString *) qName {
    if ( [[elementName uppercaseString] isEqualToString:_verifyKey] ) {
        _appendLock = NO;
    }
    if ( _appendLock ) {
        [_requestString appendFormat:@"</%@>",elementName];
    }
}

- (void)parser : (NSXMLParser *) parser parseErrorOccurred : (NSError *) parseError {
    _status = LEAFPARSERERROR;
    [self parserFailed];
    [self soapEnd];
}

- (void) parserDidEndDocument : (NSXMLParser *) parser {
    if ( _hadUnlock ) {
        [self parserEnd];
        _hadUnlock = NO;
    } else {
        _status = LEAFVERIFYERROR;
        [self verifyFailed];
    }
    [self soapEnd];
}

//Below Functions just call delegate function
- (void) soapBegin {
    if ( _delegate && [_delegate respondsToSelector:@selector(LEAFSoapDidBegin)] ) {
        [_delegate LEAFSoapDidBegin];
    }
}

- (void) soapFailed {
    if ( _delegate && [_delegate respondsToSelector:@selector(LEAFSoapDidFailed)] ) {
        [_delegate LEAFSoapDidFailed];
    }
}

- (void) soapCancel {
    if ( _delegate && [_delegate respondsToSelector:@selector(LEAFSoapDidCancel)] ) {
        [_delegate LEAFSoapDidCancel];
    }
}

- (void) parserBegin {
    if ( _delegate && [_delegate respondsToSelector:@selector(LEAFSoapDidParserBegin)] ) {
        [_delegate LEAFSoapDidParserBegin];
    }
}

- (void) parserFailed {
    if ( _delegate && [_delegate respondsToSelector:@selector(LEAFSoapDidParserFailed)] ) {
        [_delegate LEAFSoapDidParserFailed];
    }
}

- (void) parserEnd {
    if ( _delegate && [_delegate respondsToSelector:@selector(LEAFSoapDidParserEnd)] ) {
        [_delegate LEAFSoapDidParserEnd];
    }
}

- (void) verifyFailed {
    if ( _delegate && [_delegate respondsToSelector:@selector(LEAFSoapNotVerifiedKey)] ) {
        [_delegate LEAFSoapNotVerifiedKey];
    }
}

- (void) soapEnd {
    if ( _delegate && [_delegate respondsToSelector:@selector(LEAFSoapEndWithStatus:request:)] ) {
        [_delegate LEAFSoapEndWithStatus:_status request:_requestString];
    }
}

- (NSString *) recodingXMLFromQualifieldName : (NSString *) qName attributes : (NSDictionary *) attributes {
    NSMutableString * recodingStr = [NSMutableString string];
    [recodingStr appendFormat:@"<%@",qName];
    for ( NSString * key in [attributes allKeys] ) {
        [recodingStr appendFormat:@" %@=\"%@\"",key,[attributes valueForKey:key]];
    }
    [recodingStr appendFormat:@">"];
    return recodingStr;
}

//This is the function for assembled soap request xml
- (NSString *) assembledSoapRequestWithFunctionName : (NSString * ) functionName
                                          nameSpace : (NSString *) nameSpace
                                         paramsDict : (NSDictionary *) paramsDict {
    NSMutableString * soapMessage = [[NSMutableString alloc] initWithFormat:
                                     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                     "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                     "<soap:Body>\n"
                                     "<leaf:%@ xmlns:leaf=\"%@\" elementFormDefault=\"unqualified\">\n",
                                     functionName,nameSpace];
    if ( _isStrongQuote ) {
        for ( NSString * keys in [paramsDict allKeys] ) {
            [soapMessage appendFormat:@"<leaf:%@>%@</leaf:%@>\n",keys,[paramsDict objectForKey:keys],keys];
        }
    } else {
        for ( NSString * keys in [paramsDict allKeys] ) {
            [soapMessage appendFormat:@"<%@>%@</%@>\n",keys,[paramsDict objectForKey:keys],keys];
        }
    }
    [soapMessage appendFormat:@"</leaf:%@></soap:Body></soap:Envelope>",functionName];
    return soapMessage;
}

//更新时间正则验证
-(BOOL)validateNum:(NSString *)textString{
    NSString *Regtext = @"^[0-9]{1,2}";
    NSPredicate *textPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Regtext];
    return [textPre evaluateWithObject:textString];
}
@end
