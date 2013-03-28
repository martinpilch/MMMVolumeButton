//
//  MMMViewController.m
//  example
//
//  Created by Martin Pilch on 3/28/13.
//  Copyright (c) 2013 Martin Pilch. All rights reserved.
//

#import "MMMViewController.h"
#import "MMMView.h"
#import "MMMVolumeButton.h"

@interface MMMViewController ()

@property (strong) MMMView *mainView;

@end

@implementation MMMViewController

- (void)loadView {
  
  [super loadView];
  
  self.mainView = [[MMMView alloc] init];
  self.mainView.textLabel.text = @"DOWN";
  
  [MMMVolumeButton sharedInstance].volumeDetectionEnabled = YES;
  [MMMVolumeButton sharedInstance].upBlock = ^{
    self.mainView.textLabel.text = @"UP";
  };
  [MMMVolumeButton sharedInstance].downBlock = ^{
    self.mainView.textLabel.text = @"DOWN";
  };
  
  self.view = self.mainView;
}

@end
