MMMVolumeButton
===============

Detect volume buttons pressing super easily

To use the MMMVolumeButton simply import MMMVolumeButton.h to your project and add AudioToolbox and MediaPlayer frameworks.

Don't forget to turn on volume detection and set blocks for VolumeUp/VolumeDown buttons

```
[MMMVolumeButton sharedInstance].volumeDetectionEnabled = YES;
[MMMVolumeButton sharedInstance].upBlock = ^{
  //do your code when pressing Volume-Up button
};
[MMMVolumeButton sharedInstance].downBlock = ^{
  //do your code when pressing Volume-Down button
};
```