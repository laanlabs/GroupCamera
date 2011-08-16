//
//  AudioManager.h
//  ntpA
//
//  Created by Chris Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioOscillator.h"

@class AudioOutputUnit;

// struct to allow holding cpp class without screwing up all files to .mm
struct Opaque;

@interface AudioManager : NSObject {
	
	AudioOutputUnit * outputUnit;
	Float64 outFreq;
	
	
	float *sample_data;
	float *allocated_magnitude_buffer;
	float *allocated_phase_buffer;
	
	struct Opaque * opaque;
	int fftLength;
	
	//AudioGen * audioGen;
	
	double frequency;
	NSMutableArray * oscillators;
	
	NSTimeInterval lastDigitTime;
	int currentDigit;
	int lastDigit;
	float timeDiff;
	
	//int digitHistory[43];
	NSMutableArray * digitHistory;
	int historyLength;
	
	AudioOscillator * mainOscillator;
	
	BOOL pendingClick;
	NSTimeInterval pendingClickTime;
	
}


@property (nonatomic, readwrite) double frequency;
@property (readwrite) BOOL generateSound;
@property (readwrite) BOOL listenForSound;

@property (nonatomic, readwrite) id delegate;

@property (nonatomic, readwrite) int currentDigit;
@property (nonatomic, readwrite) float timeDiff;
@property (nonatomic, readwrite) NSTimeInterval lastDigitTime;

-(void) start;

-(void) setFrequency:(double)_freq;

-(void) makeClickAtTime:(NSTimeInterval) interval;

@end
