//
//  ASIHTTPRequest+Parameters.h
//  ShareTapDJ
//
//  Created by jason on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OARequestParameter.h"
#import "NSURL+Base.h"
#import "ASIHTTPRequest.h"

@interface ASIHTTPRequest (OAParameterAdditions)

@property(nonatomic, retain) NSArray *parameters;

- (void)setHTTPBodyWithString:(NSString *)body;
- (void)attachFileWithName:(NSString *)name filename:(NSString*)filename contentType:(NSString *)contentType data:(NSData*)data;

@end
