//
//  ASIOAuthHeaderProvider.h
//  ShareTapDJ
//
//  Created by jason on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"


@class OAConsumer;
@class OAToken;

typedef enum  {
    ASIOAuthHeaderTokenRequest,
    ASIOAuthHeaderAuthorizationRequest
} ASIOAuthHeaderType;

@interface ASIOAuthHeaderProvider : NSObject 
//<ASIHTTPRequestHeaderProvider> 

{
	
    ASIOAuthHeaderType type;
}

+ (ASIOAuthHeaderProvider*)authorizationHeaderProviderWithConsumer:(OAConsumer*)aConsumer;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;                                                


+ (ASIOAuthHeaderProvider*)headerproviderWithConsumer:(OAConsumer*)aConsumer 
										  accessToken:(OAToken*)aToken;

- (id)initWithConsumer:(OAConsumer*)aConsumer 
           accessToken:(OAToken*)aToken;

- (void)setHeaderFieldsForRequest:(ASIHTTPRequest*)request withParameters:(NSArray*)formParameters;

@property (nonatomic, retain) OAToken *token; //you may need to set this multiple times in certain applications

@end


//TODO: seperate authentication header and request header into 2 seperate things for better error cheking (you can check that a token is null)

