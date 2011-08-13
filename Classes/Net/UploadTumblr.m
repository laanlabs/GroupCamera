//
//  UploadTumblr.m
//  ShareMedia
//
//  Created by jason on 12/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UploadTumblr.h"


@implementation UploadTumblr

- (void) startMediaUpload {
	
	
	[delegate performSelectorOnMainThread:@selector(updateUplaodDisplay:) withObject:@"Uploading..." waitUntilDone:NO];
	
	
	NSString * url_string  =  @"http://www.tumblr.com/api/write";
	
	
	
	NSString * caption = self.media_message;

	
	NSMutableDictionary *tempDictionary = [[[NSMutableDictionary alloc] init] autorelease];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[tempDictionary setValue:[[defaults stringForKey:@"tumblrUsername"] copy] forKey:@"email"];
	[tempDictionary setValue:[[defaults stringForKey:@"tumblrPassword"] copy] forKey:@"password"];
	
	
	[tempDictionary setValue:@"photo" forKey:@"type"];
	[tempDictionary setValue:caption forKey:@"caption"];
		
		

	
	

	
	

	
	NSURL *url = [NSURL URLWithString:url_string];
	ASIHTTPRequest * asrequest = [[[ASIHTTPRequest alloc] initWithURL:url] retain];
	[asrequest setDelegate:self];
	[asrequest setUploadProgressDelegate:self];
	[asrequest setShowAccurateProgress:YES];
	[asrequest setDidFinishSelector:@selector(videoUploadSuccess:)];
	[asrequest setDidFailSelector:@selector(videoUploadFail:)];
	[asrequest setTimeOutSeconds:120];
	[asrequest setShouldStreamPostDataFromDisk:YES];
	
	
	[asrequest addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", MULTIPART_BOUNDARY] ];
	
	[asrequest appendPostData:[[NSString stringWithFormat:@"--%@\r\n", MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	
	[asrequest appendPostData:[self formBodyFromDictionary:tempDictionary]];
	
	
	
	[asrequest appendPostData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"data\"; filename=\"%@\"\r\n", [self.media_file lastPathComponent] ] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//photo
	[asrequest appendPostData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	

	
	NSData *jpeg = UIImageJPEGRepresentation(self.currentImage, 0.8);
	[asrequest appendPostData:jpeg];
	
	//[asrequest appendPostDataFromFile:self.media_file];
	
	[asrequest appendPostData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
	
	currentRequest = asrequest;
	
	[asrequest startAsynchronous];
	
	
}	



- (void)videoUploadSuccess:(ASIHTTPRequest *)asrequest
{
	NSString *response = [asrequest responseString];
	NSLog(@"RESPONSE: %@", response);
	
	
	BOOL mediaUploadFail = NO;
	
	//reponse ok = google uses status codes properly
	if ( [asrequest responseStatusCode] == 200 || [asrequest responseStatusCode] == 201 ) {
		
		
		
		if ( delegate && [delegate respondsToSelector: onSuccess ] ) {
			[delegate performSelector:onSuccess withObject:response];
		}
		
	} else {
		
		mediaUploadFail = YES;
		goto out;
		
	}
	
	
	out:
	
	if (mediaUploadFail) {
		
		if ([response length] == 0) 
			response = @"Unknown Upload Fail";
		
		if ( delegate && [delegate respondsToSelector: onFail ] ) {
			[delegate performSelector:onFail withObject:response];
		}		
	}	
	
	
	
	
	currentRequest = nil;
	[currentRequest release];
	
}



- (void)videoUploadFail:(ASIHTTPRequest *)asrequest
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




#pragma mark -
#pragma mark upload progress

- (void) setProgress:(float)progress {
	
	float pComplete = fmax(.05, fmin(.95, progress));
	//NSLog(@"progress: %f", pComplete);
	NSNumber* f = [NSNumber numberWithFloat:pComplete] ;
	[delegate performSelectorOnMainThread:@selector(updateUplaod:) withObject:f waitUntilDone:NO];
	
	
	
}

@end
