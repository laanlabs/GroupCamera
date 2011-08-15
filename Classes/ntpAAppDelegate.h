//
//  ntpAAppDelegate.h
//  ntpA
//
//  Created by Gavin Eadie on 10/16/10.
//  Copyright (c) 2010 Ramsay Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CameraCapturer.h"
#import "AudioManager.h"

@class ntpAViewController;

@interface ntpAAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSDate *                        systemTime;
    NSDate *                        networkTime;
    
    IBOutlet UILabel *              sysClockLabel;
    IBOutlet UILabel *              netClockLabel;
    IBOutlet UILabel *              differenceLabel;
    IBOutlet UILabel *              countdownLabel;

	IBOutlet UISwitch * talkSwitch;
	IBOutlet UISwitch * listenSwitch;
	
	IBOutlet UISlider * freqSlider;
	IBOutlet UILabel * freqLabel;
	
	IBOutlet UILabel * timeLabel;
	IBOutlet UILabel * digitLabel;
	
	IBOutlet UILabel * theirTimeLabel;
	IBOutlet UILabel * theirTimeLabel2;
	IBOutlet UILabel * myTimeLabel;
	
	IBOutlet UILabel * syncLabel;
	
    NSTimeInterval timeToTakePhoto;
	BOOL photoCountdownStarted;
	BOOL pendingFrameCapture;
	
	CameraCapturer * cameraCapturer;
	
	AudioManager * audioManager;
	
	NSTimeInterval beginTime;
	NSTimeInterval NTPSearchduration;
	BOOL isSyncingWithSound;
	BOOL soundSyncAchieved;
	
	NSTimeInterval differenceBetweenMyNetworkTimeAndTheirs;
	
	CADisplayLink * displayLink;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *           window;
@property (nonatomic, retain) IBOutlet ntpAViewController * viewController;

- (void) repeatingMethod:(NSTimer*)theTimer;

-(IBAction) snapPhotoClicked;
-(IBAction) getFakeTimeFromServer;

-(IBAction) talkSwitched;
-(IBAction) listenSwitched;

-(IBAction) freqUp;
-(IBAction) freqDown;

-(IBAction) freqSliderChanged;

-(NSTimeInterval) getTheirNetworkInterval;

@end
