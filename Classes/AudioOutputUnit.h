//
//  AudioOutputUnit.h
//  MantuPlay
//
//  Created by Markus Sintonen on 7.11.2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol AudioOutputUnitDelegate <NSObject>

@required

-(void)audioOutputUnit:(id)audioOutputUnit fillFrameBuffer:(SInt32*)frameBuffer withNumberOfFrames:(UInt32)numberOfFrames;
-(void)audioOutputUnit:(id)audioOutputUnit fillFrameBufferL:(SInt32*)frameBuffer fillFrameBufferR:(SInt32*)frameBuffer2 withNumberOfFrames:(UInt32)numberOfFrames;


@end

@interface AudioOutputUnit : NSObject {
	
	AudioComponentInstance audioUnit;
	AudioStreamBasicDescription audioFormat;
	
	id<AudioOutputUnitDelegate> delegate;
	
	BOOL allowInput;
	
	
}
@property AudioComponentInstance audioUnit;
@property BOOL allowInput;

@property (nonatomic, assign) id<AudioOutputUnitDelegate> delegate;
@property (nonatomic, readonly) AudioStreamBasicDescription audioFormat;

-(id)initWithDelegate:(id<AudioOutputUnitDelegate>)del;
-(void)start;
-(void)stop;
@end

//Private methods
@interface AudioOutputUnit ()
-(void)setupAudioOutputUnit;
@end
