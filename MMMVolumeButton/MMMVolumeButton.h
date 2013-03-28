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

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef void (^ButtonBlock)();

@interface MMMVolumeButton : NSObject {
  
  BOOL _justEnteredForeground;
  MPMusicPlayerController *_ipodPlayer;
  CGFloat _previousVolumeLevel;
  MPVolumeView *_volumeView;
}

@property (copy) ButtonBlock upBlock;
@property (copy) ButtonBlock downBlock;
@property (assign) float previousVolumeLevel;
@property (nonatomic, assign) BOOL volumeDetectionEnabled;

+ (MMMVolumeButton *)sharedInstance;

@end
