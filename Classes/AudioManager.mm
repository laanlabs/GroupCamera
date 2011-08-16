//
//  AudioManager.m
//  ntpA
//
//  Created by Chris Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import "AudioManager.h"
#import "AudioOutputUnit.h"
#import "pkmFFT.h"
#import "AudioConsts.h"

#include <deque>

@interface AudioManager (privates)


-(void) doFFT:(SInt32*)frameBuffer numFrames:(int)numberOfFrames;
-(void) getMostCommonDigit:(int*)digit count:(int*)_count;

@end


@implementation AudioManager

@synthesize listenForSound, generateSound, frequency, timeDiff, currentDigit;

@synthesize delegate, lastDigitTime;

struct Opaque {
	
    pkmFFT *fft;
	std::deque <int> digitHistory;
	
};

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		listenForSound = YES;
		generateSound = YES;
		
		oscillators = [[NSMutableArray alloc] init];
		
		int numOsc = 1;
		double maxVol = 2147483620 / (float)numOsc;
		
		// 20076
		/*for (int i = 0; i < numOsc; i++) {
			AudioOscillator * osc = [AudioOscillator oscillatorWithFrequency:(24000+i*1000)];
			osc.maxAmplitude = maxVol;
			osc.active = YES;
			[oscillators addObject:osc];
		}*/
		
		mainOscillator = [[AudioOscillator oscillatorWithFrequency:0.0] retain];
		mainOscillator.maxAmplitude = maxVol;
		mainOscillator.active = YES;
		
		outputUnit = [[AudioOutputUnit alloc] initWithDelegate:self];
		
		outFreq = 21000;
		
		fftLength = 256;
		
		freqWidthPerFFTBin = 44100.0 / (float)fftLength;
		
		lastDigitTime = -1;
		currentDigit = -1;
		lastDigit = -1;
		digitHistory = [[NSMutableArray alloc] init];
		historyLength = 44100.0 / fftLength;
		
		// be sure to either use malloc or __attribute__ ((aligned (16))
		sample_data = (float *) malloc (sizeof(float) * fftLength);
		allocated_magnitude_buffer =  (float *) malloc (sizeof(float) * fftLength/2);
		allocated_phase_buffer =  (float *) malloc (sizeof(float) * fftLength/2);
		
		//pkmFFT *fft;
		opaque = new Opaque();
		opaque->fft = new pkmFFT(fftLength);
		
		//opaque->fft->forward(0, sample_data, allocated_magnitude_buffer, allocated_phase_buffer);
		//opaque->fft->inverse(0, sample_data, allocated_magnitude_buffer, allocated_phase_buffer);
		//delete opaque->fft;
		
		
		
		[self setupAudioSession];
		
		[outputUnit start];
		
		
	}
	return self;
}

-(void) setFrequency:(double)_freq {
	
	frequency = _freq;
	//AudioOscillator * osc = [oscillators objectAtIndex:0];
	//osc.frequency = _freq;
	mainOscillator.frequency = _freq;
	
}


#pragma mark -
#pragma mark Audio Functions

-(void) setupAudioSession {
	
	NSLog(@"SETUP ENGINE--");
	
	AudioSessionInitialize(NULL, NULL, NULL, NULL);
	
	//UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	//AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	
	//float aBufferLength = 0.05; // In seconds
	
	float aBufferLength = 0.005; // In seconds // 256
	//float aBufferLength = 0.01; // In seconds  // 512
	//float aBufferLength = 0.02; // In seconds  // 1024
	
	AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(aBufferLength), &aBufferLength);
	
	
	
	[self overrideSpeaker];
	
	//[self performSelector:@selector(overrideSpeaker) withObject:nil afterDelay:0.2];
	
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
	
	//SInt32 * micInput = frameBuffer;
	
	SInt32 *data_ptr_dst = frameBuffer;
	SInt32 *data_ptr_dst2 = frameBuffer2;
	
	
	if ( listenForSound ) {
		[self doFFT:frameBuffer numFrames:numberOfFrames];
	}
	
	if ( generateSound ) {
		
		static int cnt = 0;
		cnt ++;
		
		if ( delegate ) {
			// will update the frequency if needed
			[delegate getFrequencyCallback];
		}
		
		memset(data_ptr_dst,0,numberOfFrames*sizeof(SInt32));
		//memset(data_ptr_dst2, 0, numberOfFrames*sizeof(SInt32) );
		
		[self doGenerateSound:frameBuffer numFrames:numberOfFrames];
		
		memcpy(data_ptr_dst2, data_ptr_dst, numberOfFrames*sizeof(SInt32) );
		
	} else {
		
		memset(data_ptr_dst,0,numberOfFrames*sizeof(SInt32));
		//memset(data_ptr_dst2,0,numberOfFrames*sizeof(SInt32));
		
		if ( pendingClick ) {
			
			NSTimeInterval myTime = [NSDate timeIntervalSinceReferenceDate];
			NSTimeInterval howLongUntil = pendingClickTime - myTime;
			if ( howLongUntil <= .005804988662131519 ) {
				// 5.804988662131519
				// since each buffer is 256 samples, then 5ms per buffer
				int dt = 0;
				if ( howLongUntil >= 0.0 ) {
					dt = (howLongUntil/5.804988662131519)*248;
				}
				
				frameBuffer[dt+0] = 2147480647;
				frameBuffer[dt+1] = 2147480647;
				frameBuffer[dt+2] = 2147480647;
				frameBuffer[dt+3] = 0;
				frameBuffer[dt+4] = 0;
				frameBuffer[dt+5] = 0;
				frameBuffer[dt+6] = -2147480647;
				frameBuffer[dt+7] = -2147480647;
				frameBuffer[dt+8] = -2147480647;
				pendingClick = NO;
			}
		}
		
		memcpy(data_ptr_dst2, data_ptr_dst, numberOfFrames*sizeof(SInt32) );
		
	}
	
}

-(void) doGenerateSound:(SInt32*)frameBuffer numFrames:(int)numberOfFrames { 
		
	//for (AudioOscillator * osc in oscillators) {
	//	[osc renderFrames:frameBuffer numFrames:numberOfFrames];
	//}
	
	[mainOscillator renderFrames:frameBuffer numFrames:numberOfFrames];
	
}

-(void) doFFT:(SInt32*)frameBuffer numFrames:(int)numberOfFrames {
	
	uint32_t sigLength = numberOfFrames;
	
	//float * signal = (float*)malloc(sigLength * sizeof(float));
	
	
	 for (int i = 0; i < sigLength; i++) {
	 
		 float sample = frameBuffer[i]; 
		 //sample_data[i] = sample / 32767.0f;
		 sample_data[i] = sample / 2147483647;
		 
		 //  2,147,483,647
	 }
	 
	
	
	//Converts an array of signed 16-bit integers to single-precision floating-point values.
	
	//vDSP_Stride srcStride=1, dstStride=1;
	//vDSP_vflt32((int*)frameBuffer, srcStride, sample_data, dstStride, sigLength);
	
	/*vDSP_vflt16 (
				 sampleBuffer,
				 srcStride,
				 signal,
				 dstStride,
				 sigLength
				 );
	*/
	
	static int cnt = 0;
	cnt ++;
	
	opaque->fft->forward(0, sample_data, allocated_magnitude_buffer, allocated_phase_buffer);
	int len = fftLength/2;
	
	
	float certainty=0;
	int whichDigit = -1;
	
	[self detectFrequencyBins:&whichDigit certainty:&certainty];
	
	int newDigit = freqToDigitMap[whichDigit];
	
	//if ( cnt % 4 == 0 ) 
	{
		//printf("Max Bin: %i , -> %i Diff: %3.2f \n" , whichDigit, newDigit, certainty );
	}
	
	[self processDigit:newDigit certainty:certainty];
	
	return;
	
	
	if ( cnt % 3 == 0 ) 
	{
		printf("Max Bin: %i , -> %i " , whichDigit, newDigit );
		
		for (int i = 2*len/3; i < len; i++) {
			
			float val = allocated_magnitude_buffer[i];
			
			//printf("%.1f " , allocated_magnitude_buffer[i] );
			/*if ( i == maxPeakIndex ) {
				printf("@");
			} else {
				printf("_");
			}*/
			
			if ( val > 2.0 ) {
				printf("@");
			} else if ( val > 1.0 ) {			
				printf("O");
			} else if ( val > 0.7 ) {			
				printf("o");
			} else if ( val > 0.4 ) {			
				printf("-");
			} else if ( val > 0.2 ) {
				printf(",");
			} else if ( val > 0.1 ) {
				printf(".");
			} else  {
				printf("_");
			}
			
		}
		printf("\n");
	}
	
	
	
}

-(void) detectFrequencyBins:(int*)_whichBin certainty:(float*)_certainty {
	
	double averageValue = 0.0;
	
	{
		double totalMag = 0;
		double numSampled = 0;
		int len = fftLength/2;
		
		for (int w = len/3; w < len; w++) {
			totalMag += allocated_magnitude_buffer[w];
			numSampled++;
		}
		
		averageValue = totalMag / numSampled;
	}

	
	
	// float frequency = (peakIndex * 44100) / n;
	float binVals[10];
	memset(binVals, 0, 10*sizeof(float));
	float maxBinVal = -1;
	int maxBinIndex = -1;
	
	
	for (int i = 0; i < numFreqBins; i++) {
		
		double searchFreq = startingFreq + i*freqBinSize;
		
		int rangeStart, rangeEnd;
		
		rangeStart = ceil(fftLength * searchFreq / 44100.0);
		rangeEnd = ceil(fftLength * (searchFreq+freqBinSize) / 44100.0);
		
		float totalMag = 0.0;
		
		for (int r = rangeStart; r < rangeEnd; r++) {
			
			totalMag += allocated_magnitude_buffer[r];
			
		}
		
		binVals[i] = totalMag;
		
		if ( totalMag > maxBinVal ) {
			maxBinVal = totalMag;
			maxBinIndex = i;
		}
		
	}
	
	
	
	*_whichBin = maxBinIndex;
	*_certainty = (maxBinVal - averageValue);
	
	//printf("Avg: %f , maxBin: %f \n " , averageValue, maxBinVal );
	
}

-(void) processDigit:(int) digit certainty:(float)_certainty {
	
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	opaque->digitHistory.push_front(digit);
	
	if ( opaque->digitHistory.size() > historyLength ) {
		opaque->digitHistory.pop_back();
	}
	
	int mostCommonDigit=-1;
	int digCount=-1;
	
	if ( opaque->digitHistory.size() > (historyLength-2) ) {
		
		[self getMostCommonDigit:&mostCommonDigit count:&digCount];
		
		NSTimeInterval timeSinceLast = [[NSDate date] timeIntervalSince1970] - lastDigitTime;
		
		//NSLog(@"Digit: %i Most Common: %i, count: %i , TIME: %f " , digit, mostCommonDigit, digCount , timeSinceLast );
		
		if ( digit != mostCommonDigit && currentDigit != digit ) {
			
			int nextDigit = ((mostCommonDigit==9) ? (0) : (mostCommonDigit+1));
			
			if ( digit == nextDigit && ( timeSinceLast > 0.95 ) ) {
				
				lastDigitTime = [[NSDate date] timeIntervalSince1970];
				currentDigit = digit;
				//NSLog(@"NEW DIGIT: %i , time: %f " , digit, timeSinceLast );
				
				timeDiff = timeSinceLast;
				
				if ( delegate ) {
					[delegate performSelectorOnMainThread:@selector(timeChangeCallback) withObject:nil waitUntilDone:NO];
				}
				
			}
			
		}
		
	}
	
	
	
	/*
	if ( digit != currentDigit ) {
		
		if ( opaque->digitHistory.size() > (historyLength-2) ) {
			
			int numPreviousDigit = 0;
			for (int i = 0; i < opaque->digitHistory.size(); i++) {
				int _dig = opaque->digitHistory[i];
				if ( _dig == currentDigit ) {
					numPreviousDigit++;
				}
			}
			
			int numNewDigit = 0;
			for (int i = 0; i < opaque->digitHistory.size(); i++) {
				int _dig = opaque->digitHistory[i];
				if ( _dig == digit ) {
					numNewDigit++;
				}
			}
			
			if ( numPreviousDigit > (historyLength-8) || numNewDigit > (historyLength-8) ) {
				currentDigit = digit;
				NSLog(@"** new digit: %i " , currentDigit );
			}
			
			
		}
		
	}
	*/
	
	[pool release];
	
	
}

-(void) getMostCommonDigit:(int*)digit count:(int*)_count {
	
	int digitCounts[10];
	memset(digitCounts,0,10*sizeof(int));
	
	for (int i = 0; i < opaque->digitHistory.size(); i++) {
		
		int _dig = opaque->digitHistory[i];
		digitCounts[_dig]++;
		
	}
	
	int maxDigit = -1;
	int maxCount = 0;
	
	for (int i = 0; i < 10; i++) {
		
		if ( digitCounts[i] > maxCount ) {
			maxCount = digitCounts[i];
			maxDigit = i;
		}
		
	}
	
	*digit = maxDigit;
	*_count = maxCount;
	
}


#pragma mark Debug 

-(void) makeClickAtTime:(NSTimeInterval) interval {
	
	pendingClick = YES;
	pendingClickTime = interval;
	
}



@end













