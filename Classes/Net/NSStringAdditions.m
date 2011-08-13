// 
// Copyright (c) 2009 Eric Czarny <eczarny@gmail.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of  this  software  and  associated documentation files (the "Software"), to
// deal  in  the Software without restriction, including without limitation the
// rights  to  use,  copy,  modify,  merge,  publish,  distribute,  sublicense,
// and/or sell copies  of  the  Software,  and  to  permit  persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED,  INCLUDING  BUT  NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY,  WHETHER  IN  AN  ACTION  OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
// 

// 
// Cocoa XML-RPC Framework
// NSStringAdditions.m
// 
// Created by Eric Czarny on Wednesday, January 14, 2004.
// Copyright (c) 2009 Divisible by Zero.
// 

#import "NSStringAdditions.h"



/* Base64 Encoding Table */
static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

@implementation NSString (NSStringExtensions)


- (NSString*)encodeAsURIComponent
{
	const char* p = [self UTF8String];
	NSMutableString* result = [NSMutableString string];
	
	for (;*p ;p++) {
		unsigned char c = *p;
		if ('0' <= c && c <= '9' || 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z' || c == '-' || c == '_' || c == '.') {
			[result appendFormat:@"%c", c];
		} else {
			[result appendFormat:@"%%%02X", c];
		}
	}
	return result;
}




- (NSString*)decodeURIComponent
{
	NSString * string = self;

	NSString * result = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	return result;
}



+ (NSString *)stringByGeneratingUUID {
    CFUUIDRef UUIDReference = CFUUIDCreate(nil);
    NSString *newUUID = (NSString *)CFUUIDCreateString(nil, UUIDReference);
    
    CFRelease(UUIDReference);
    
    return [newUUID autorelease];
}

+ (NSString *)base64StringFromData: (NSData *)data length: (int)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    
    if (lentext < 1) {
        return @"";
    }
    
    result = [NSMutableString stringWithCapacity: lentext];
    
    raw = [data bytes];
    
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        
        if (ctremaining <= 0) {
            break;
        }
        
        for (i = 0; i < 3; i++) { 
            unsigned long ix = ixtext + i;
            
            if (ix < lentext) {
                input[i] = raw[ix];
            } else {
                input[i] = 0;
            }
        }
        
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        
        ctcopy = 4;
        
        switch (ctremaining) {
            case 1: 
                ctcopy = 2;
                break;
            case 2: 
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++) {
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        }
        
        for (i = ctcopy; i < 4; i++) {
            [result appendString: @"="];
        }
        
        ixtext += 3;
        charsonline += 4;
        
        if ((ixtext % 90) == 0) {
            [result appendString: @"\n"];
        }
        
        if (length > 0) {
            if (charsonline >= length) {
                charsonline = 0;
                
                [result appendString: @"\n"];
            }
        }
    }
    
    return result;
}


+ (NSString*)base64encode:(NSString*)str 
{
    if ([str length] == 0)
        return @"";
	
    const char *source = [str UTF8String];
    int strlength  = strlen(source);
    
    char *characters = malloc(((strlength + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
	
    NSUInteger length = 0;
    NSUInteger i = 0;
	
    while (i < strlength) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < strlength)
            buffer[bufferLength++] = source[i++];
        characters[length++] = base64EncodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = base64EncodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = base64EncodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = base64EncodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

- (NSDictionary*)queryDictionaryUsingEncoding: (NSStringEncoding)encoding { 
	
	NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"] ;
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary] ;
    NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
    while (![scanner isAtEnd]) {
        NSString* pairString ;
        [scanner scanUpToCharactersFromSet:delimiterSet
                                intoString:&pairString] ;
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL] ;
		NSArray* kvPair = [pairString componentsSeparatedByString:@"="] ;
        if ([kvPair count] == 2) {
			NSString* key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding] ; NSString* value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding] ;
            [pairs setObject:value forKey:key] ;
        }
    }
	
    return [NSDictionary dictionaryWithDictionary:pairs] ;
}

@end
