//
//  MMMView.m
//  example
//
//  Created by Martin Pilch on 3/28/13.
//  Copyright (c) 2013 Martin Pilch. All rights reserved.
//

#import "MMMView.h"

@implementation MMMView

- (id)init {

  self = [super init];
  if (self) {
    self.backgroundColor = [UIColor whiteColor];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.font = [UIFont boldSystemFontOfSize:40.0f];
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_textLabel];
  }
  return self;
}

- (void)layoutSubviews {
  
  [super layoutSubviews];
  
  CGRect labelRect;
  labelRect.size = [_textLabel.text sizeWithFont:_textLabel.font];
  labelRect.origin = CGPointMake((CGRectGetWidth(self.bounds) - CGRectGetWidth(labelRect)) / 2, (CGRectGetHeight(self.bounds) - CGRectGetHeight(labelRect)) / 2);
  if (!CGRectEqualToRect(_textLabel.frame, labelRect)) {
    _textLabel.frame = labelRect;
  }
}

@end
