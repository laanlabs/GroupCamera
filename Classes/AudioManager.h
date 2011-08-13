//
//  AudioManager.h
//  ntpA
//
//  Created by Chris Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AudioOutputUnit;

@interface AudioManager : NSObject {
	
	AudioOutputUnit * outputUnit;
	
}

@end
