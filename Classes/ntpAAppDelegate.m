/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ntpAAppDelegate.m                                                                                ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Nov16/10                                                               ║
  ║ Copyright © 2010 Ramsay Consulting. All rights reserved.                                         ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#import "ntpAAppDelegate.h"
#import "ntpAViewController.h"
#import "NetworkClock.h"
#import "TimeServer.h"

@implementation ntpAAppDelegate

@synthesize window;
@synthesize viewController;



- (BOOL) application:(UIApplication *) app didFinishLaunchingWithOptions:(NSDictionary *) options {

    [NetworkClock sharedNetworkClock];                      // gather up the ntp servers ...

    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Create a timer that will fire in ten seconds and then every ten seconds thereafter to ask the   │
  │ network clock what time it is.                                                                   │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    NSTimer * repeatingTimer = [[NSTimer alloc]
                                initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]
                                        interval:.05 target:self selector:@selector(repeatingMethod:)
                                        userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];
    [repeatingTimer release];

    
    
    //start poll timer
    NSTimer * readTimer = [[NSTimer alloc]
                                initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]
                                interval:1.0 target:self selector:@selector(readServerTime:)
                                userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:readTimer forMode:NSDefaultRunLoopMode];
    [readTimer release];
    
    
    return YES;
}

- (void) repeatingMethod:(NSTimer *) theTimer {
    systemTime = [NSDate date];
    networkTime = [[NetworkClock sharedNetworkClock] networkTime];

    sysClockLabel.text = [NSString stringWithFormat:@"%@", systemTime];
    netClockLabel.text = [NSString stringWithFormat:@"%@", networkTime];
    differenceLabel.text = [NSString stringWithFormat:@"%5.3f",
                            [networkTime timeIntervalSinceDate:systemTime]];
    
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

#pragma mark network start -

- (IBAction) postServerTime {
    
    
	TimeServer * req = [[TimeServer alloc] init];
	req.delegate = self;	
	req.onSuccess = @selector(postTimeSuccess:);
	req.onFail = @selector(postTimeFail:);
	
    NSTimeInterval millisecondedDate = ([[[NetworkClock sharedNetworkClock] networkTime] timeIntervalSince1970] * 1000) + 5000;
    
    NSString* formattedMilliseconds = [NSString stringWithFormat:@"%.0f", millisecondedDate];
    
	[req postTime:formattedMilliseconds];
	

    
}

-(void) postTimeSuccess:(id) response 
{

}


-(void) postTimeFail:(id) response 
{

}	


- (IBAction) readServerTime:(NSTimer *) theTimer {
    
    
	TimeServer * req = [[TimeServer alloc] init];
	req.delegate = self;	
	req.onSuccess = @selector(readTimeSuccess:);
	req.onFail = @selector(readTimeFail:);
	

	[req readTime];
	
    
    
}

-(void) readTimeSuccess:(id) response 
{
    
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