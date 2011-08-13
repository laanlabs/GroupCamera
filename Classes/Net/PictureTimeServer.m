//
//  TimeServer.m
//  ntpA
//
//  Created by Jason Cyril Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import "TimeServer.h"


#define TIMESERVER_BASE_URL @"http://labs.laan.com/projects/iPhone/GroupCamera/"

@implementation PictureTimeServer


- (void) postTime:(NSString*)timeString {
    
    
    
    NSString * url_string  =  [NSString stringWithFormat:@"%@%@", TIMESERVER_BASE_URL,  @"postTime.php?"];
	
	
	
    
	
	NSMutableDictionary *tempDictionary = [[[NSMutableDictionary alloc] init] autorelease];
	
	[tempDictionary setValue:timeString forKey:@"camera_time"];
	

	NSURL *url = [NSURL URLWithString:url_string];
	ASIHTTPRequest * asrequest = [[[ASIHTTPRequest alloc] initWithURL:url] retain];
	[asrequest setDelegate:self];
	[asrequest setUploadProgressDelegate:self];
	[asrequest setShowAccurateProgress:YES];
	[asrequest setDidFinishSelector:@selector(postTimeSucces:)];
	[asrequest setDidFailSelector:@selector(postTimeFail:)];
	[asrequest setTimeOutSeconds:120];
	[asrequest setShouldStreamPostDataFromDisk:YES];
	
	
	[asrequest addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", MULTIPART_BOUNDARY] ];
	
	[asrequest appendPostData:[[NSString stringWithFormat:@"--%@\r\n", MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	
	[asrequest appendPostData:[self formBodyFromDictionary:tempDictionary]];
	
	
	[asrequest appendPostData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
	
	currentRequest = asrequest;
	
	[asrequest startAsynchronous];
    
    
}



- (void) readTime {
    
    NSString * url_string  =  [NSString stringWithFormat:@"%@%@", TIMESERVER_BASE_URL,  @"readTime.php?"];
	
	
	
    
	
	
	
    
	NSURL *url = [NSURL URLWithString:url_string];
	ASIHTTPRequest * asrequest = [[[ASIHTTPRequest alloc] initWithURL:url] retain];
	[asrequest setDelegate:self];
	[asrequest setUploadProgressDelegate:self];
	[asrequest setShowAccurateProgress:YES];
	[asrequest setDidFinishSelector:@selector(readTimeSucces:)];
	[asrequest setDidFailSelector:@selector(readTimeFail:)];
	[asrequest setTimeOutSeconds:120];

	currentRequest = asrequest;
	
	[asrequest startAsynchronous];
    
}




- (void)readTimeSucces:(ASIHTTPRequest *)asrequest
{
	NSString *response = [asrequest responseString];
	NSLog(@"RESPONSE: %@", response);
	
		
		
    if ( delegate && [delegate respondsToSelector: onSuccess ] ) {
        [delegate performSelector:onSuccess withObject:response];
    }
		
		
	currentRequest = nil;
	[currentRequest release];
	
}



- (void)readTimeFail:(ASIHTTPRequest *)asrequest
{
	NSString *response = [asrequest responseString];
	NSLog(@"RESPONSE: %@", response);
	
	if ([response length] == 0) 
		response = @"Unknown Upload Fail";
	
	
	
	if ( delegate && [delegate respondsToSelector: onFail ] ) {
		[delegate performSelector:onFail withObject:response];
	}
	
	currentRequest = nil;
	[currentRequest release];
	
	
	
}




@end
