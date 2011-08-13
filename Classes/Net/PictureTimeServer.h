//
//  TimeServer.h
//  ntpA
//
//  Created by Jason Cyril Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestObject.h"




@interface PictureTimeServer : RequestObject {
    
}


- (void) postTime:(NSString*)timeString;
- (void) readTime;

@end
