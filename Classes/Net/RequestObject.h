//
//  RequestObject.h
//  ShareMedia
//
//  Created by jason on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ConstantsShare.h"

@class ASIOAuthHeaderProvider;

@interface RequestObject : NSObject {

	id delegate;
	
	SEL onSuccess;
	SEL onFail;
	


	
	ASIHTTPRequest * currentRequest;
	
}


@property (nonatomic, assign) id delegate;

@property (nonatomic) SEL onSuccess;
@property (nonatomic) SEL onFail;

@property (nonatomic, copy) NSString * media_title;
@property (nonatomic, copy) NSString * media_desc;
@property (nonatomic, copy) NSString * media_tags;
@property (nonatomic, copy) NSString * media_file;
@property (nonatomic, copy) NSString * media_message;

@property (nonatomic, assign) UIImage* currentImage;

@property (nonatomic, assign) ASIHTTPRequest * currentRequest;


@property (nonatomic, assign) id  headerProvider;

- (NSData*) formBodyFromDictionary:(NSDictionary*) _parameters;
- (NSString *)generateTimeStamp;
- (NSString *)md5Hash:(NSString*)inputString;
- (NSMutableDictionary*) getValuePairs:(NSString*)inputString withSeperator:(NSString*)seperator; 
- (NSString *)generateQueryStringFromDict:(NSDictionary *)parameters; 

- (NSString *)generateSigForParameters:(NSDictionary *)parameters sessionSecret:(NSString*)sessionSecret;
- (NSString*) getLocaleCode;

- (void) cancelCalled;
@end
