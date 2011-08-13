//
//  CameraCapturer.h
//  ntpA
//
//  Created by Chris Laan on 8/12/11.
//  Copyright 2011 Ramsay Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LLOrientationDetector.h"

@interface CameraCapturer : NSObject {
	
	// new Camera stuff:
	AVCaptureSession * vidCaptureSession;
	AVCaptureVideoDataOutput * videoOutput;
	AVCaptureDeviceInput *videoInput;
	
	AVCaptureVideoPreviewLayer * previewLayer;
	
	UIImage * capturedImage;
	
	LLOrientationDetector * orientationDetector;	
	UIDeviceOrientation currentDeviceOrientation;
	
}

@property (nonatomic, retain) AVCaptureVideoPreviewLayer * previewLayer;
@property (readwrite) BOOL waitingForCapture;
@property (retain) UIImage * capturedImage;

-(void) beginCapturingCamera;
-(void) stopCapturingCamera;

-(void) capturePhoto;

@end
