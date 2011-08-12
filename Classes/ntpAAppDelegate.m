/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ntpAAppDelegate.m                                                                                ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Nov16/10                                                               ║
  ║ Copyright © 2010 Ramsay Consulting. All rights reserved.                                         ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#import "ntpAAppDelegate.h"
#import "ntpAViewController.h"
#import "NetworkClock.h"

@implementation ntpAAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL) application:(UIApplication *) app didFinishLaunchingWithOptions:(NSDictionary *) options {

    [NetworkClock sharedNetworkClock];                      // gather up the ntp servers ...

    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	
	timeToTakePhoto = [NSDate timeIntervalSinceReferenceDate];
	photoCountdownStarted = NO;
	
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Create a timer that will fire in ten seconds and then every ten seconds thereafter to ask the   │
  │ network clock what time it is.                                                                   │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
	
    NSTimer * repeatingTimer = [[NSTimer alloc]
                                initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]
                                        interval:.06 target:self selector:@selector(repeatingMethod:)
                                        userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];
    [repeatingTimer release];

    return YES;
}

- (void) repeatingMethod:(NSTimer *) theTimer {
	
    systemTime = [NSDate date];
    networkTime = [[NetworkClock sharedNetworkClock] networkTime];

    sysClockLabel.text = [NSString stringWithFormat:@"%@", systemTime];
    netClockLabel.text = [NSString stringWithFormat:@"%@", networkTime];
    differenceLabel.text = [NSString stringWithFormat:@"%5.3f", [networkTime timeIntervalSinceDate:systemTime]];
    
	NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
	
	NSTimeInterval diff = timeToTakePhoto - t;
	
	//NSLog(@"Diff: %3.2f" , diff);
	//countdownLabel.text = [NSString stringWithFormat:@"%3.1f",diff];
	
	if ( diff > 0.0 ) {
		
		if ( photoCountdownStarted == NO ) {
			window.backgroundColor = [UIColor grayColor];
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
	
	
	/*
    UInt64 mod = ([networkTime timeIntervalSinceReferenceDate]);
    
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
    
//    NSTimeInterval timePassed_ms = [networkTime timeIntervalSinceNow] * -1000.0;
//    
//    millLabel.text = [NSString stringWithFormat:@"%.3f",timePassed_ms];
//
    
}

-(void) takePhoto {
	
	window.backgroundColor = [UIColor redColor];
	[window performSelector:@selector(setBackgroundColor:) withObject:[UIColor whiteColor] afterDelay:0.3];
	
}

-(IBAction) getFakeTimeFromServer {
	
	timeToTakePhoto = [NSDate timeIntervalSinceReferenceDate] + 6.0;
	
	
}

-(IBAction) snapPhotoClicked {
	
}



- (void)applicationWillTerminate:(UIApplication *)application {

    [[NetworkClock sharedNetworkClock] finishAssociations];   // be nice and let all the servers go ...
}

- (void)dealloc {

    [window release];
    [viewController release];
    [super dealloc];
}

@end