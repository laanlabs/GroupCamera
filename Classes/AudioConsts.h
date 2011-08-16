/*
 *  AudioConsts.h
 *  ntpA
 *
 *  Created by Chris Laan on 8/13/11.
 *  Copyright 2011 Ramsay Consulting. All rights reserved.
 *
 */

//static double startingFreq = 17054.296875; // 99th bin
static double startingFreq = 17915.625; // 104th bin 
static double freqBinSize = 172.265625 * 2.0;
static int numFreqBins = 10;
// these choose random frequencies to map to ordered time digits 0-9 ... so transitions aren't right next to each other
static int digitToFreqBinMap[10] = {0,6,3,9,1,7,2,5,8,4};
static int freqToDigitMap[10] = {0,4,6,2,9,7,1,5,8,3};

static double freqWidthPerFFTBin;

//static double freqTable[10] = {19000,19400,19800,20200,20600,21000,21400,21800,22000,19000};