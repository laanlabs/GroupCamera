//
//  ASIOAuthHeaderProvider.m
//  ShareTapDJ
//
//  Created by jason on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ASIOAuthHeaderProvider.h"

#import "OARequestParameter.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "OASignatureProviding.h"
#import "ASIHTTPRequest+Parameters.h"

@interface ASIOAuthHeaderProvider()

@property (nonatomic, retain) OAConsumer *consumer;
@property (nonatomic, copy) NSString *realm;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, retain) id<OASignatureProviding, NSObject> signatureProvider;
@property (nonatomic, copy) NSString *nonce;
@property (nonatomic, copy) NSString *timestamp;

@property (nonatomic) ASIOAuthHeaderType type;


- (NSString *)_signatureBaseStringForRequest:(ASIHTTPRequest*)request;
- (void)_generateNonce;
- (void)_generateTimestamp;

- (id)initWithConsumer:(OAConsumer*)aConsumer;

@end


@implementation ASIOAuthHeaderProvider

@synthesize consumer;
@synthesize token;
@synthesize realm;
@synthesize signature;
@synthesize signatureProvider;
@synthesize nonce;
@synthesize timestamp;
@synthesize username;
@synthesize password;
@synthesize type;




- (void) dealloc
{
    [username release];
    username = nil;
    [password release];
    password = nil;    
    [consumer release];
    consumer = nil;
    [token release];
    token = nil;
    [realm release];
    realm = nil;
    [signature release];
    signature = nil;
    [signatureProvider release];
    signatureProvider = nil;
    [nonce release];
    nonce = nil;
    [timestamp release];
    timestamp = nil;
    [super dealloc];
}


- (id)initWithConsumer:(OAConsumer*)aConsumer accessToken:(OAToken*)aToken{
    
    if(aConsumer == nil)
        return nil;
    
    self = [self initWithConsumer:aConsumer];
    if (self != nil) {
		
        self.token = aToken;
		
    }
    return self;
    
}

- (id)initWithConsumer:(OAConsumer*)aConsumer{
    if(aConsumer == nil)
        return nil;
    
    self = [super init];
    if (self != nil) {
        
        self.consumer = aConsumer;
        self.realm = @"";
        self.signatureProvider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
        
    }
    return self;
    
}

+ (ASIOAuthHeaderProvider*)headerproviderWithConsumer:(OAConsumer*)aConsumer accessToken:(OAToken*)aToken{
    
    ASIOAuthHeaderProvider* p = [[[self class] alloc] initWithConsumer:aConsumer accessToken:aToken];
    p.type = ASIOAuthHeaderAuthorizationRequest;
    return [p autorelease];
    
}

+ (ASIOAuthHeaderProvider*)authorizationHeaderProviderWithConsumer:(OAConsumer*)aConsumer{
	
    ASIOAuthHeaderProvider* p = [[[self class] alloc] initWithConsumer:aConsumer];
    p.type = ASIOAuthHeaderTokenRequest;
    return [p autorelease];
}


- (void)_generateTimestamp {
    timestamp = [[NSString stringWithFormat:@"%d", time(NULL)] retain];
}

- (void)_generateNonce {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
    nonce = (NSString *)string;
}


- (NSString *)_signatureBaseStringForRequest:(ASIHTTPRequest*)request {
    // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
    // build a sorted array of both request parameters and OAuth header parameters
	NSDictionary *tokenParameters = [token parameters];
	// 6 being the number of OAuth params in the Signature Base String
	NSMutableArray *parameterPairs = [[NSMutableArray alloc] initWithCapacity:(5 + [[request parameters] count] + [tokenParameters count])];
    
    [parameterPairs addObject:[[[OARequestParameter alloc] initWithName:@"oauth_consumer_key" value:consumer.key] URLEncodedNameValuePair]];
    [parameterPairs addObject:[[[OARequestParameter alloc] initWithName:@"oauth_signature_method" value:[signatureProvider name]] URLEncodedNameValuePair]];
    [parameterPairs addObject:[[[OARequestParameter alloc] initWithName:@"oauth_timestamp" value:timestamp] URLEncodedNameValuePair]];
    [parameterPairs addObject:[[[OARequestParameter alloc] initWithName:@"oauth_nonce" value:nonce] URLEncodedNameValuePair]];
    [parameterPairs addObject:[[[OARequestParameter alloc] initWithName:@"oauth_version" value:@"1.0"] URLEncodedNameValuePair]];
	
    
	for(NSString *k in tokenParameters) {
		[parameterPairs addObject:[[OARequestParameter requestParameter:k value:[tokenParameters objectForKey:k]] URLEncodedNameValuePair]];
	}
    
	if (![[[request requestHeaders] objectForKey:@"Content-Type"] hasPrefix:@"multipart/form-data"]) {
		for (OARequestParameter *param in [request parameters]) {
			[parameterPairs addObject:[param URLEncodedNameValuePair]];
		}
	}
    
    NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
    
    //	NSLog(@"Normalized: %@", normalizedRequestParameters);
    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
    return [NSString stringWithFormat:@"%@&%@&%@",
            [request requestMethod],
            [[[request url] URLStringWithoutQuery] encodedURLParameterString],
            [normalizedRequestParameters encodedURLString]];
}


#pragma mark -
#pragma mark ASIBlockURLRequestHeaderProvider

- (void)setHeaderFieldsForRequest:(ASIHTTPRequest*)request withParameters:(NSArray*)formParameters {
    
    [self _generateTimestamp];
    [self _generateNonce];
    
	if (formParameters !=nil) {
		[request setParameters:formParameters];		
	}
	
	
    
    // sign
    //	NSLog(@"Base string is: %@", [self _signatureBaseString]);
    self.signature = [signatureProvider signClearText:[self _signatureBaseStringForRequest:request]
                                           withSecret:[NSString stringWithFormat:@"%@&%@", consumer.secret, token.secret ? token.secret : @""]];
    
    // set OAuth headers
	NSMutableArray *chunks = [[NSMutableArray alloc] init];
	[chunks addObject:[NSString stringWithFormat:@"realm=\"%@\"", [realm encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_consumer_key=\"%@\"", [consumer.key encodedURLParameterString]]];
    
	NSDictionary *tokenParameters = [token parameters];
	for (NSString *k in tokenParameters) {
		[chunks addObject:[NSString stringWithFormat:@"%@=\"%@\"", k, [[tokenParameters objectForKey:k] encodedURLParameterString]]];
	}
    
	[chunks addObject:[NSString stringWithFormat:@"oauth_signature_method=\"%@\"", [[signatureProvider name] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_signature=\"%@\"", [signature encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_timestamp=\"%@\"", timestamp]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_nonce=\"%@\"", nonce]];
	[chunks	addObject:@"oauth_version=\"1.0\""];
	
	NSString *oauthHeader = [NSString stringWithFormat:@"OAuth %@", [chunks componentsJoinedByString:@", "]];
	[chunks release];
    
    [request addRequestHeader:@"Authorization" value:oauthHeader];
    
}


@end

