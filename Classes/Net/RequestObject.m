//
//  RequestObject.m
//  ShareMedia
//
//  Created by jason on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RequestObject.h"
#import "ConstantsShare.h"
#import "NSDataAdditions.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSStringAdditions.h"

@implementation RequestObject

@synthesize delegate;
@synthesize onSuccess, onFail;
@synthesize currentRequest;
@synthesize media_title, media_desc, media_tags, media_file,media_message;
@synthesize currentImage;
@synthesize headerProvider;

- (void) cancelCalled {
	
	NSLog(@"cancel called");
	if (currentRequest)
		[currentRequest cancel];
}	


-(NSString *)generateTimeStamp
{
	return [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
}

- (NSData*) formBodyFromDictionary:(NSDictionary*) _parameters {
	
	NSMutableData *body = [NSMutableData data];
	NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", MULTIPART_BOUNDARY];
	
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n", MULTIPART_BOUNDARY]
					  dataUsingEncoding:NSUTF8StringEncoding]];
	
	for (id key in [_parameters keyEnumerator]) {
		
		if (![[_parameters objectForKey:key] isKindOfClass:[UIImage class]]) {
			
			NSString* value;
			
			//id obj = [_parameters valueForKey:key];
			id obj = [_parameters objectForKey:key];
			
			if ( [obj isKindOfClass:[NSString class]] ) {
				
				value = (NSString*)obj;
				
			} else {
				
				value = [NSString stringWithFormat:@"%@" , obj ];
				
			}
			
			
			
			[body appendData:[[NSString
							   stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]
							  dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];        
		}
	}
	

	return body;
}


-(NSString *)md5Hash:(NSString*)inputString
{
	NSData *tempData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
	
	unsigned char digest[16];
	char finaldigest[32];
	int i;
	
	CC_MD5([tempData bytes],[tempData length],digest);
	for(i=0;i<16;i++) sprintf(finaldigest+i*2,"%02x",digest[i]);
	
	return [NSString stringWithCString:finaldigest length:32];
}

- (NSString*) sha1:(NSString*) text
		withSecret:(NSString*) secret shouldUrlEncode:(BOOL) enc  {
	

	
	
    NSData* secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData* clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
	
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	
    CCHmacContext hmacContext;
    CCHmacInit(&hmacContext, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
    CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
    CCHmacFinal(&hmacContext, digest);
	
    return [[NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH] base64Encoding ];
}

-(NSMutableDictionary*) getValuePairs:(NSString*)inputString withSeperator:(NSString*)seperator {
	NSArray *params = [inputString componentsSeparatedByString:seperator ];
	NSEnumerator *cursor = [ params objectEnumerator ];
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	id string;
	
	
	while(string = [ cursor nextObject ]){
		
		if (string) {
			
			NSRange searchRange=NSMakeRange(0, [string length]);
			NSRange splitRange = [string rangeOfString:@"=" options:0 range:searchRange];
			NSString * key2; 
			NSString * value2;
			
			if (splitRange.length > 0)	
				key2 = [string substringWithRange:NSMakeRange(0, splitRange.location)] ;
			
			NSLog(@"KEY: %@", key2);
			if (splitRange.length > 0)	
				value2 = [string substringWithRange:NSMakeRange(splitRange.location+1, [string length] - splitRange.location -1)] ;
			
			NSLog(@"VALUE: %@", value2);	
			
			if (value2 != nil && key2 != nil)	
				[dictionary setValue:value2  forKey:key2 ];	
			
			
		}
	}
	
	return dictionary;
	
}	


- (NSString *)generateQueryStringFromDict:(NSDictionary *)parameters 
{
	
	NSArray *sortedParameters1 = [NSArray arrayWithArray:[parameters keysSortedByValueUsingSelector:@selector(caseInsensitiveCompare:)]];
	NSArray *sortedParameters = [NSArray arrayWithArray:[sortedParameters1 sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
	//now sortedParameters is finally sorted correctly
	NSMutableString *tempString = [[[NSMutableString alloc] init] autorelease]; 
	
	
	NSEnumerator *enumerator =[sortedParameters objectEnumerator];
	id anObject; //keys of sortedParameters
	while(anObject = [enumerator nextObject])
	{
		[tempString appendString:anObject];
		[tempString appendString:@"="];
		[tempString appendString:[parameters valueForKey:anObject]];
		[tempString appendString:@"&"];
	}
	
	
	
	
	return tempString;
}


- (NSString *)generateSigForParameters:(NSDictionary *)parameters sessionSecret:(NSString*)sessionSecret
{
	
	NSArray *sortedParameters1 = [NSArray arrayWithArray:[parameters keysSortedByValueUsingSelector:@selector(caseInsensitiveCompare:)]];
	NSArray *sortedParameters = [NSArray arrayWithArray:[sortedParameters1 sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
	//now sortedParameters is finally sorted correctly
	NSMutableString *tempString = [[[NSMutableString alloc] init] autorelease]; 
	NSEnumerator *enumerator =[sortedParameters objectEnumerator];
	id anObject; //keys of sortedParameters
	while(anObject = [enumerator nextObject])
	{
		[tempString appendString:anObject];
		[tempString appendString:@"="];
		[tempString appendString:[parameters valueForKey:anObject]];
	}
	
	
	[tempString appendString:sessionSecret];
	
	//NSLog(tempString);
	//NSLog([self md5Hash:tempString]);
	
	return [self md5Hash:tempString];
}


- (NSString*) getLocaleCode {

	NSLocale* curentLocale = [NSLocale currentLocale];
	//return [curentLocale displayNameForKey:NSLocaleIdentifier
	//						  value:[curentLocale localeIdentifier]];
	
	
	return [curentLocale objectForKey: NSLocaleCountryCode];
	
}


@end
