//
//  CameraCapturer.m
//  ntpA
//
//  Created by Chris Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import "CameraCapturer.h"


@implementation CameraCapturer

@synthesize previewLayer, waitingForCapture, capturedImage;


#pragma mark -
#pragma mark Camera 

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
		[self setupCamera];
		[self addVideoPreviewLayer];
		[self beginCapturingCamera];
		
		currentDeviceOrientation = -1;
		
		orientationDetector = [[LLOrientationDetector alloc] init];
		orientationDetector.delegate = self;
		[orientationDetector startReceivingUpdates];
	
		
		
	}
	return self;
}


-(void) setupCamera {
	
	NSError *error = nil;
	
	videoInput = [[AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error] retain]; 
	
	
	videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	
	
	// init session
	vidCaptureSession = [[AVCaptureSession alloc] init]; 
	
    // config
	[vidCaptureSession beginConfiguration]; 
    
	// set input/output
	[vidCaptureSession addInput:videoInput]; 
	
	[vidCaptureSession addOutput:videoOutput]; 
	
	//[vidCaptureSession setSessionPreset:AVCaptureSessionPresetLow]; //this doesnt affect res on 3G, 
    //[vidCaptureSession setSessionPreset:AVCaptureSessionPresetMedium]; //this doesnt affect res on 3G, 
	
    //[videoOutput setAlwaysDiscardsLateVideoFrames:YES]; 
	
	[videoOutput setMinFrameDuration:CMTimeMake(1, 30)];
	
	
    // set colorspace
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = nil;
	
	BOOL useRGB = YES;
	
	if ( useRGB ) {
		
		value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
		
	}
	
	
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[videoOutput setVideoSettings:videoSettings]; 
	
	// more stable and faster
	dispatch_queue_t cameraDelegateQ = dispatch_queue_create("com.laan.CameraCapturer.frame_queue", NULL);
    
    dispatch_queue_t target = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	//dispatch_queue_t target = dispatch_get_main_queue();
	
    dispatch_set_target_queue(cameraDelegateQ, target);
    
	[videoOutput setSampleBufferDelegate:self queue:cameraDelegateQ];
	
	[vidCaptureSession commitConfiguration]; 
	
}

-(void) beginCapturingCamera {
	
	// turn on video capture
	[vidCaptureSession startRunning]; 
	
}

-(void) stopCapturingCamera {
	
	[vidCaptureSession stopRunning]; 
	
}


-(void) addVideoPreviewLayer {
	
	previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:vidCaptureSession];
	//previewLayer.frame = window.bounds;
	previewLayer.masksToBounds = YES;
	previewLayer.opaque = YES;
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	
	//[window.layer insertSublayer:previewLayer atIndex:0];
	//[window.layer addSublayer:previewLayer];

	
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer  fromConnection:(AVCaptureConnection *)connection
{
	
	if ( self.waitingForCapture ) { 
		
		CGImageRef cgImage = [self imageFromSampleBuffer:sampleBuffer];
		
		UIDeviceOrientation o = [LLOrientationDetector deviceOrientation];
		UIImageOrientation imageOrient = -1;
		
		switch (o) {
			case UIDeviceOrientationPortrait:
				imageOrient = UIImageOrientationRight;
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				imageOrient = UIImageOrientationLeft;
				break;
			case UIDeviceOrientationLandscapeLeft:
				imageOrient = UIImageOrientationUp;
				break;
			case UIDeviceOrientationLandscapeRight:
				imageOrient = UIImageOrientationDown;
				break;
			case UIDeviceOrientationUnknown:
				imageOrient = UIImageOrientationRight;
				break;
			default:
				break;
		}
		
		self.capturedImage = [UIImage imageWithCGImage:cgImage scale:2.0 orientation:imageOrient];
		
		CGImageRelease( cgImage );
		NSLog(@"captured photo");
		self.waitingForCapture = NO;
		
	}
	
}

- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer 
	
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image 
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
    CGContextRelease(newContext); 
	
    CGColorSpaceRelease(colorSpace); 
    CVPixelBufferUnlockBaseAddress(imageBuffer,0); 
    /* CVBufferRelease(imageBuffer); */  // do not call this!
	
    return newImage;
}

-(void) capturePhoto {
	
	self.waitingForCapture = YES;
	self.capturedImage = nil;
	/*
	while (self.waitingForCapture==YES) {
		[NSThread sleepForTimeInterval:0.01];
	}
	
	return self.capturedImage;
	*/
}


#pragma mark -
#pragma mark LLOrientationDetectorDelegate

-(void) deviceOrientationDidChange:(LLOrientationDetector*)detector {
	
	// using interface orientation since it hides face up / face down
	//[self updateOrientationImages:YES];
	
	
}
// dont need both of these vvv ^^^
-(void) interfaceOrientationDidChange:(LLOrientationDetector*)detector {
	
	NSLog(@"Orientation!");
	//[self updateOrientationImages:YES];
	
	
}



@end
