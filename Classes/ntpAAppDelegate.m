/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ntpAAppDelegate.m                                                                                ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Nov16/10                                                               ║
  ║ Copyright © 2010 Ramsay Consulting. All rights reserved.                                         ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#import "ntpAAppDelegate.h"
#import "PictureTimeServer.h"

#import "ntpAViewController.h"
#import "NetworkClock.h"

#import "AudioConsts.h"

@implementation ntpAAppDelegate

@synthesize window;
@synthesize viewController;



- (BOOL) application:(UIApplication *) app didFinishLaunchingWithOptions:(NSDictionary *) options {

    [NetworkClock sharedNetworkClock];                      // gather up the ntp servers ...

    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	
	timeToTakePhoto = [NSDate timeIntervalSinceReferenceDate];
	photoCountdownStarted = NO;
	pendingFrameCapture = NO;
	
	beginTime = [NSDate timeIntervalSinceReferenceDate];
	//NSLog(@"BEgin time: %f " , beginTime);
	NTPSearchduration = 5.0;
	isSyncingWithSound = YES;
	
	
	
	
	
	
	audioManager = [[AudioManager alloc] init];
	//[audioManager start];
	audioManager.delegate = self;
	
	audioManager.generateSound = NO;
	audioManager.listenForSound = YES;
	
	talkSwitch.on = audioManager.generateSound;
	listenSwitch.on = audioManager.listenForSound;
	
	
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Create a timer that will fire in ten seconds and then every ten seconds thereafter to ask the   │
  │ network clock what time it is.                                                                   │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
	
	/*
    NSTimer * repeatingTimer = [[NSTimer alloc]
                                initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]
                                        interval:.06 target:self selector:@selector(repeatingMethod:)
                                        userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];
    [repeatingTimer release];
	 */
    
    
    //start poll timer
    /*NSTimer * readTimer = [[NSTimer alloc]
                                initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]
                                interval:1.0 target:self selector:@selector(readServerTime:)
                                userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:readTimer forMode:NSDefaultRunLoopMode];
	
    [readTimer release];
    */
	
	
	[NSTimer scheduledTimerWithTimeInterval:(1.5) target:self selector:@selector(readServerTime:) userInfo:nil repeats:YES];
	
	
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateInterface:)];
	//displayLink.frameInterval = 2;
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	//[NSTimer scheduledTimerWithTimeInterval:(.05) target:self selector:@selector(updateFrequency) userInfo:nil repeats:YES];
    
<<<<<<< HEAD
	// stop syncing time after 10 seconds...
	[self performSelector:@selector(stopNetworkClock) withObject:nil afterDelay:5.0];
	
=======
    

    
    
>>>>>>> 5efd45d5874ab385f0f86eb7f08d7ec7079dd695
    return YES;
}

//- (void) repeatingMethod:(NSTimer *) theTimer {

-(void) checkForPendingPhotoCapture {
	
    /*systemTime = [NSDate date];
	networkTime = [[NetworkClock sharedNetworkClock] networkTime];
    sysClockLabel.text = [NSString stringWithFormat:@"%@", systemTime];
    netClockLabel.text = [NSString stringWithFormat:@"%@", networkTime];
    differenceLabel.text = [NSString stringWithFormat:@"%5.3f", [networkTime timeIntervalSinceDate:systemTime]];
    */
	
	//NSTimeInterval t = [networkTime timeIntervalSinceReferenceDate];
	
	NSTimeInterval t = [self getTheirNetworkInterval];
	
	NSTimeInterval diff = timeToTakePhoto - t;
	
	//if ( diff > (1/60.0) ) {
	if ( diff > 0.0166 ) {
		
		if ( photoCountdownStarted == NO ) {
			//window.backgroundColor = [UIColor grayColor];
			countdownLabel.textColor = [UIColor redColor];
			photoCountdownStarted = YES;
		}
		
		countdownLabel.text = [NSString stringWithFormat:@"%3.1f",diff];
		
	} else {
		
		if ( photoCountdownStarted == YES ) {
			[self takePhoto];
			countdownLabel.text = @"";
			photoCountdownStarted = NO;
		}
		
	}
	
	
}

// 60 fps to update interface..  not needed for actual app

-(void) updateInterface:(CADisplayLink *)sender; {
	
	if ( soundSyncAchieved ) {
		[self checkForPendingPhotoCapture];
	}
	
	/*
	NSTimeInterval myNetworkInterval = [[[NetworkClock sharedNetworkClock] networkTime] timeIntervalSince1970];
	
	NSTimeInterval theirNetworkInterval = myNetworkInterval - differenceBetweenMyNetworkTimeAndTheirs;
	
	//timeLabel.text = [NSString stringWithFormat:@"%.2f , %.2f, D: %.3f" , theirDigit , myDigit , networkDiff ];
	
	timeLabel.text = [NSString stringWithFormat:@"Diff: %.3f " , differenceBetweenMyNetworkTimeAndTheirs ];
	
	double mine = fmod(myNetworkInterval, 100.0);
	myTimeLabel.text = [NSString stringWithFormat:@"%.3f" , mine];
	
	double them = fmod(theirNetworkInterval, 100.0);
	theirTimeLabel.text = [NSString stringWithFormat:@"%.3f" , them];
	theirTimeLabel2.text = [NSString stringWithFormat:@"%.3f" , them];
	
	
	int mod = floor(theirNetworkInterval);
	
	if ( mod % 4 == 0 ) {
        window.backgroundColor = [UIColor yellowColor];
    } else if ( mod % 3 == 0 ) {
        window.backgroundColor = [UIColor blueColor];
    } else if ( mod % 2 == 0 ) {
        window.backgroundColor = [UIColor greenColor];
    } else {
        window.backgroundColor = [UIColor whiteColor];
    }
	*/
	
}

// called when a sync sound signal changes digits from the master phone

-(void) timeChangeCallback {
	
	//NSLog(@"Digit Change" );
	
	// calculate the offset between your time and theirs...
	// even the master will be listening to himself to take delays in
	
	if ( soundSyncAchieved ) return;
	
	NSTimeInterval myNetworkInterval = [[[NetworkClock sharedNetworkClock] networkTime] timeIntervalSince1970];
	
	double myDigit = fmod(myNetworkInterval, 10);
	
	double theirDigit = audioManager.currentDigit;
	
	//NSTimeInterval timeSinceLast = [[NSDate date] timeIntervalSince1970] - audioManager.lastDigitTime;
	//theirDigit += timeSinceLast;
	
	//timeLabel.text = [NSString stringWithFormat:@"%.2f , %.3f" , theirDigit , myDigit ];
	
	double diff = theirDigit - myDigit;
	
	NSTimeInterval theirNetworkInterval = 0.0;
	
	if ( fabs(diff) > 7.0 ) {
		if ( diff >= 0.0 ) {
			theirNetworkInterval = myNetworkInterval - ((10.0+myDigit) - theirDigit);
		} else {
			theirNetworkInterval = myNetworkInterval + ((10.0+theirDigit) - myDigit);
		}
	} else {
		theirNetworkInterval = myNetworkInterval + diff;
	}
	
	// standard diff ?
	//theirNetworkInterval += 0.1;
	
	// only update if still syncing...
	//if ( isSyncingWithSound ) {
	differenceBetweenMyNetworkTimeAndTheirs = myNetworkInterval - theirNetworkInterval;
	//}
	
	//timeLabel.text = [NSString stringWithFormat:@"%.2f , %.3f" , theirDigit , myDigit ];
	
	//timeLabel.text = [NSString stringWithFormat:@"Diff: %.3f, Dig: %i" , differenceBetweenMyNetworkTimeAndTheirs, (int)theirDigit ];
	digitLabel.text = [NSString stringWithFormat:@"Dig: %i" , (int)theirDigit ];
	
	static int sameCount = 0;
	static double lastDiff = -1;
	static int digCount = 0;
	digCount ++;
	
	double diffChange = fabs(lastDiff-differenceBetweenMyNetworkTimeAndTheirs);
	
	
	if ( digCount > 10 && ( diffChange <= 0.01 )) {
		sameCount ++;
	} else {
		sameCount = 0;
	}
	
	if ( sameCount >= 3 ) {
		isSyncingWithSound = NO;
		syncLabel.text = @"Synced!";
		soundSyncAchieved = YES;
		listenSwitch.on = NO;
		audioManager.listenForSound = NO;
		[self performSelectorOnMainThread:@selector(initCamera) withObject:nil waitUntilDone:NO];
	}	
	
	
	lastDiff = differenceBetweenMyNetworkTimeAndTheirs;
	
}




-(void) stopNetworkClock {
	
	[[NetworkClock sharedNetworkClock] finishAssociations];
	countdownLabel.text = @"X";
	
}

#pragma mark photo capture

-(void) initCamera {
	
	cameraCapturer = [[CameraCapturer alloc] init];
	//cameraCapturer.previewLayer;
	[window.layer insertSublayer:cameraCapturer.previewLayer atIndex:1];
	//cameraCapturer.previewLayer.frame = window.bounds;
	cameraCapturer.previewLayer.frame = CGRectMake(0, 90, 320, 480);
	[cameraCapturer beginCapturingCamera];
	
}


-(void) uploadPhoto {
    
	PictureTimeServer * req = [[PictureTimeServer alloc] init];
	req.delegate = self;	
	req.onSuccess = @selector(uploadSuccess:);
	req.onFail = @selector(uploadFail:);
	
 
    UIImage* image = [UIImage imageNamed:@"test_photo.JPG"];
    
	[req postPhoto:image withName:@"the_comp_position.jpg"];
	
    
    
}

-(void) uploadPhotoSuccess:(id) response 
{
    
}


-(void) uploadPhotoFail:(id) response 
{
    
}	


-(void) takePhoto {
	
	window.backgroundColor = [UIColor redColor];
	[window performSelector:@selector(setBackgroundColor:) withObject:[UIColor whiteColor] afterDelay:0.3];
	pendingFrameCapture = YES;
	
	[cameraCapturer capturePhoto];
	
	
	[self performSelector:@selector(checkForImage) withObject:nil afterDelay:0.3];
	
}

-(void) checkForImage {
	
	UIImage * image = cameraCapturer.capturedImage;
	NSLog(@"captured: %f , %f " , image.size.width, image.size.height );
	//UIImageWriteToSavedPhotosAlbum(image, self, @selector(finishedSaving:), NULL);
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:), NULL);  
	
	
}	

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

	if ( error == nil ) {
		NSLog(@"yay");
	}
	
}

-(IBAction) getFakeTimeFromServer {
	
	timeToTakePhoto = [NSDate timeIntervalSinceReferenceDate] + 6.0;
	
	
}

-(IBAction) snapPhotoClicked {
	
    [self postServerTime];
}

#pragma mark Sound -

-(void) getFrequencyCallback {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSTimeInterval myNetworkInterval = [[[NetworkClock sharedNetworkClock] networkTime] timeIntervalSince1970];
	
	static double currentFreq;// = 19000;
	double t2 = floor(myNetworkInterval);
	//double myDigit = fmod(myNetworkInterval, 10);
	
	int digit = ((int)t2 % 10);
	
	static int lastDigit = -1;
	
	if ( lastDigit != digit ) {
		//NSLog(@"freq");
		int newDigit = digitToFreqBinMap[digit];
		//currentFreq = startingFreq + digit*(freqBinSize) + freqBinSize/2 + 5;
		currentFreq = startingFreq + newDigit*(freqBinSize) + freqBinSize/2.0;// - 90;
		//currentFreq = round(currentFreq);
		[audioManager setFrequency:currentFreq];
		
		lastDigit = digit;
		
	}
	
	[pool release];
	
	
}

-(IBAction) freqSliderChanged {
	
	double _freq = 19000 + freqSlider.value*2100;
	freqLabel.text = [NSString stringWithFormat:@"Freq: %3.1f",_freq];
	[audioManager setFrequency:_freq];
	
}

-(IBAction) freqUp {
	audioManager.frequency += 0.1;
	freqLabel.text = [NSString stringWithFormat:@"Freq: %3.1f",audioManager.frequency];
}

-(IBAction) freqDown {
	audioManager.frequency -= 0.1;
	freqLabel.text = [NSString stringWithFormat:@"Freq: %3.1f",audioManager.frequency];
}

-(IBAction) talkSwitched {
	
	audioManager.generateSound = talkSwitch.on;

}

-(IBAction) listenSwitched {
	audioManager.listenForSound = listenSwitch.on;
}

#pragma mark date util
// move this..
-(NSTimeInterval) getTheirNetworkInterval {
	
	NSTimeInterval myNetworkInterval = [[[NetworkClock sharedNetworkClock] networkTime] timeIntervalSince1970];
	
	NSTimeInterval theirNetworkInterval = myNetworkInterval - differenceBetweenMyNetworkTimeAndTheirs;
	
	return theirNetworkInterval;
	
}

#pragma mark network start -

- (IBAction) postServerTime {
    
    
	PictureTimeServer * req = [[PictureTimeServer alloc] init];
	req.delegate = self;	
	req.onSuccess = @selector(postTimeSuccess:);
	req.onFail = @selector(postTimeFail:);
	
    //NSTimeInterval millisecondedDate = ([[[NetworkClock sharedNetworkClock] networkTime] timeIntervalSinceReferenceDate]) + 6.0;
    NSTimeInterval millisecondedDate = [self getTheirNetworkInterval] + 6.0;
	
    NSString* formattedMilliseconds = [NSString stringWithFormat:@"%.8f", millisecondedDate];
    NSLog(@"posting pic time: %f" , millisecondedDate );
	
	[req postTime:formattedMilliseconds];
	
    
    
}

-(void) postTimeSuccess:(id) response 
{
    
}


-(void) postTimeFail:(id) response 
{
    
}	


- (IBAction) readServerTime:(NSTimer *) theTimer {
    
	if ( !soundSyncAchieved ) return;
    
	PictureTimeServer * req = [[PictureTimeServer alloc] init];
	req.delegate = self;	
	req.onSuccess = @selector(readTimeSuccess:);
	req.onFail = @selector(readTimeFail:);
	
    
	[req readTime];
	
    
    
}

-(void) readTimeSuccess:(id) response 
{
    
    
    //timeToTakePhoto = [NSDate timeIntervalSinceReferenceDate] + 6.0;

    //NSLog(@"RESPONSE: %@", response);
    
    timeToTakePhoto = [response doubleValue];
    
}


-(void) readTimeFail:(id) response 
{
    
}	



#pragma mark network end -



- (void)applicationWillTerminate:(UIApplication *)application {

    [[NetworkClock sharedNetworkClock] finishAssociations];   // be nice and let all the servers go ...
}

- (void)dealloc {

    [window release];
    [viewController release];
    [super dealloc];
}

@end