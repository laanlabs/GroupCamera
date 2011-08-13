//
//  AudioManager.m
//  ntpA
//
//  Created by Chris Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import "AudioManager.h"
#import "AudioOutputUnit.h"

@implementation AudioManager

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
		outputUnit = [[AudioOutputUnit alloc] initWithDelegate:self];
		
		
		[self setupAudioSession];
		
		[outputUnit start];
		
		
	}
	return self;
}


#pragma mark -
#pragma mark Audio Functions

-(void) setupAudioSession {
	
	NSLog(@"SETUP ENGINE--");
	
	AudioSessionInitialize(NULL, NULL, NULL, NULL);
	
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	
	//float aBufferLength = 0.05; // In seconds
	
	float aBufferLength = 0.01; // In seconds
	AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(aBufferLength), &aBufferLength);
	
	
	
	
	[self performSelector:@selector(overrideSpeaker) withObject:nil afterDelay:0.2];
	
	AudioSessionSetActive(YES);
	
}

-(void) overrideSpeaker {
	
	// send audio out of the bottom speaker.
	UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;  // 1
	
	AudioSessionSetProperty (
							 kAudioSessionProperty_OverrideAudioRoute,                         // 2
							 sizeof (audioRouteOverride),                                      // 3
							 &audioRouteOverride                                               // 4
							 );
	
}

-(void)audioOutputUnit:(id)audioOutputUnit fillFrameBufferL:(SInt32*)frameBuffer fillFrameBufferR:(SInt32*)frameBuffer2 withNumberOfFrames:(UInt32)numberOfFrames {
	
	SInt32 * micInput = frameBuffer;
	
	SInt32 *data_ptr_dst = frameBuffer;
	SInt32 *data_ptr_dst2 = frameBuffer2;
	

}




@end
