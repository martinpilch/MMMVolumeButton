/*
 * Copyright (c) 2010, Tapmates s.r.o. (www.tapmates.com).
 *
 * All rights reserved. This source code can be used only for purposes specified 
 * by the given license contract signed by the rightful deputy of Tapmates s.r.o. 
 * This source code can be used only by the owner of the license.
 * 
 * Any disputes arising in respect of this agreement (license) shall be brought
 * before the Municipal Court of Prague.
 *
 */

#import "MMMVolumeButton.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MMMVolumeButton()

- (void)initializeVolumeButtonStealer;
- (void)volumeDown;
- (void)volumeUp;
- (void)applicationCameBack;
- (void)applicationWentAway;

@end

@implementation MMMVolumeButton

@synthesize upBlock;
@synthesize downBlock;

+ (MMMVolumeButton *)sharedInstance {
	static dispatch_once_t pred;
	static MMMVolumeButton *instance = nil;
	
	dispatch_once(&pred, ^{ instance = [[self alloc] init]; });
	return instance;
}

void volumeListenerCallback (
                             void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             );
void volumeListenerCallback (
                             void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             ){
  const float *volumePointer = inData;
  float volume = *volumePointer;
  
  if( volume > [(__bridge MMMVolumeButton*)inClientData previousVolumeLevel] || volume == 1.0f ) {
    [(__bridge MMMVolumeButton*)inClientData volumeUp];
  } else if( volume < [(__bridge MMMVolumeButton*)inClientData previousVolumeLevel] || volume == 0.0f  ) {
    [(__bridge MMMVolumeButton*)inClientData volumeDown];
  }
  
  ((__bridge MMMVolumeButton*)inClientData).previousVolumeLevel = volume;
}

- (void)setVolumeDetectionEnabled:(BOOL)volumeDetectionEnabled {
  
  if ( _volumeDetectionEnabled == volumeDetectionEnabled ) {
    return;
  }
  
  _volumeDetectionEnabled = volumeDetectionEnabled;
  
  if ( volumeDetectionEnabled ) {
    _volumeView = nil;
    
    CGRect frame = CGRectMake(0, -100, 10, 0);
    _volumeView = [[MPVolumeView alloc] initWithFrame:frame];
    [_volumeView sizeToFit];
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:_volumeView];
  } else {
    
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void*)self);
    
    [_volumeView removeFromSuperview];
    _volumeView = nil;
  }
  
}

- (void)handlePlaybackStateChanged:(id)notification {
  
  [self applicationCameBack];
}

- (void)handleExternalVolumeChanged:(id)notification {
  
  //handle volume buttons when Music.app plays music
  CGFloat volume = _ipodPlayer.volume;
  if ( volume > _previousVolumeLevel || volume == 1.0f ) {
    if ( self.upBlock && self.volumeDetectionEnabled ) {
      self.upBlock();
    }
  } else if ( volume < _previousVolumeLevel || volume == 0.0f ) {
    if ( self.downBlock && self.volumeDetectionEnabled ) {
      self.downBlock();
    }
  }
  
  if ( volume != _previousVolumeLevel && volume < 1.0f && self.volumeDetectionEnabled ) {
    _ipodPlayer.volume = _previousVolumeLevel;
  }
}

- (void)volumeDown {
  
  AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void*)self);
  
  if( self.downBlock && self.volumeDetectionEnabled ) {
    self.downBlock();
  }
  
  [self performSelector:@selector(initializeVolumeButtonStealer) withObject:self afterDelay:0.1];
}

- (void)volumeUp {
  
  AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void*)self);
  
  if( self.upBlock && self.volumeDetectionEnabled ) {
    self.upBlock();
  }
  
  [self performSelector:@selector(initializeVolumeButtonStealer) withObject:self afterDelay:0.1];
  
}

- (id)init {
  
  self = [super init];
  if( self ) {
    
    _ipodPlayer = [MPMusicPlayerController iPodMusicPlayer];
    [_ipodPlayer beginGeneratingPlaybackNotifications];
    _previousVolumeLevel = _ipodPlayer.volume;
    
    if ( _ipodPlayer.playbackState != MPMusicPlaybackStatePlaying ) {
      AudioSessionInitialize(NULL, NULL, NULL, NULL);
      AudioSessionSetActive(YES);
    }
    
    _justEnteredForeground = NO;
    
    [self initializeVolumeButtonStealer];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
      [self applicationWentAway];
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
      if( !_justEnteredForeground ) {
        [self applicationCameBack];
      }
      _justEnteredForeground = NO;
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
      
      _justEnteredForeground = YES;
      [self applicationCameBack];
      
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (handlePlaybackStateChanged:)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:_ipodPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleExternalVolumeChanged:)
                                                 name:MPMusicPlayerControllerVolumeDidChangeNotification
                                               object:_ipodPlayer];
  }
  return self;
}

- (void)applicationCameBack {
  
  if ( _ipodPlayer.playbackState != MPMusicPlaybackStatePlaying ) {
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionSetActive(YES);
    [_ipodPlayer endGeneratingPlaybackNotifications];
  } else {
    AudioSessionSetActive(NO);
    [_ipodPlayer beginGeneratingPlaybackNotifications];
  }
  
  _previousVolumeLevel = _ipodPlayer.volume;
  
  [self initializeVolumeButtonStealer];
  
}

- (void)applicationWentAway {
  
  AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void*)self);
}

- (void)dealloc {
  
  [_ipodPlayer endGeneratingPlaybackNotifications];
  
  AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void*)self);
  AudioSessionSetActive(NO);
}

- (void)initializeVolumeButtonStealer {
  
  AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, (__bridge void*)self);
}

@end
