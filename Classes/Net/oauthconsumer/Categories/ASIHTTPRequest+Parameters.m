//
//  ASIHTTPRequest+Parameters.m
//  ShareTapDJ
//
//  Created by jason on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ASIHTTPRequest+Parameters.h"



static NSString *Boundary = @"-----------------------------------0xCoCoaouTHeBouNDaRy"; 

@implementation ASIHTTPRequest (OAParameterAdditions)

- (BOOL)isMultipart {
	return [[[self requestHeaders] objectForKey:@"Content-Type"] hasPrefix:@"multipart/form-data"];
}

- (NSArray *)parameters {
    NSString *encodedParameters = nil;
    
	if (![self isMultipart]) {
		if ([[self requestMethod] isEqualToString:@"GET"] || [[self requestMethod] isEqualToString:@"DELETE"]) {
			encodedParameters = [[self url] query];
		} else {
			encodedParameters = [[[NSString alloc] initWithData:[self postBody] encoding:NSASCIIStringEncoding] autorelease];
		}
	}
    
    if (encodedParameters == nil || [encodedParameters isEqualToString:@""]) {
        return nil;
    }
	//    NSLog(@"raw parameters %@", encodedParameters);
    NSArray *encodedParameterPairs = [encodedParameters componentsSeparatedByString:@"&"];
    NSMutableArray *requestParameters = [NSMutableArray arrayWithCapacity:[encodedParameterPairs count]];
    
    for (NSString *encodedPair in encodedParameterPairs) {
        NSArray *encodedPairElements = [encodedPair componentsSeparatedByString:@"="];
        OARequestParameter *parameter = [[OARequestParameter alloc] initWithName:[[encodedPairElements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                           value:[[encodedPairElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [requestParameters addObject:parameter];
    }
    
    return requestParameters;
}

- (void)setParameters:(NSArray *)parameters
{
	NSMutableArray *pairs = [[[NSMutableArray alloc] initWithCapacity:[parameters count]] autorelease];
	for (OARequestParameter *requestParameter in parameters) {
		[pairs addObject:[requestParameter URLEncodedNameValuePair]];
	}
	
	NSString *encodedParameterPairs = [pairs componentsJoinedByString:@"&"];
    
	if ([[self requestMethod] isEqualToString:@"GET"] || [[self requestMethod] isEqualToString:@"DELETE"]) {
		[self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [[self url] URLStringWithoutQuery], encodedParameterPairs]]];
	} else {
		// POST, PUT
		[self setHTTPBodyWithString:encodedParameterPairs];
		[self addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	}
}

- (void)setHTTPBodyWithString:(NSString *)body {
	NSData *bodyData = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	[self addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [bodyData length]]];
	[self setPostBody:(NSMutableData*)bodyData];
}




- (void)attachFileWithName:(NSString *)name filename:(NSString*)filename contentType:(NSString *)contentType data:(NSData*)data {
	
	NSArray *parameters = [self parameters];
	[self addRequestHeader:@"Content-type" value:[@"multipart/form-data; boundary=" stringByAppendingString:Boundary] ];
	
	NSMutableData *bodyData = [NSMutableData new];
	for (OARequestParameter *parameter in parameters) {
		NSString *param = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",
						   Boundary, [parameter URLEncodedName], [parameter value]];
		
		[bodyData appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	NSString *filePrefix = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n",
							Boundary, name, filename, contentType];
	[bodyData appendData:[filePrefix dataUsingEncoding:NSUTF8StringEncoding]];
	[bodyData appendData:data];
	
	[bodyData appendData:[[[@"--" stringByAppendingString:Boundary] stringByAppendingString:@"--"] dataUsingEncoding:NSUTF8StringEncoding]];
	[self  addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [bodyData length]]];
	[self setPostBody:bodyData];
	[bodyData release];
}

@end
