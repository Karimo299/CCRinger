@class UIGestureRecognizer, CCUIModuleSliderView, AVSystemController;

@interface VolumeControl : NSObject
- (float)volume;
- (float)getMediaVolume;
- (void)addAlwaysHiddenCategory:(id)arg1;
- (void)removeAlwaysHiddenCategory:(id)arg1;
- (BOOL)_isMusicPlayingSomewhere;
@end

@interface CCUIContentModuleContainerViewController : NSObject
- (void)handleTapGesture:(UITapGestureRecognizer *)sender;
@end

@interface AVSystemController : NSObject
- (BOOL)setVolumeTo:(float)arg1 forCategory:(id)arg2;
@end

@interface CCUIModuleSliderView : UISlider
- (float)value;
- (void)setValue:(float)arg1;
- (void)setGlyphVisible:(BOOL)arg1;
@end

// Creates a NSDictionary for the values in the Preferences page
NSDictionary *values = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.karimo299.ccringer"];

// Variables I will need
BOOL enabled = [[values valueForKey:@"isEnabled"] isEqual:@1];
BOOL ringerMode;
float ringVol;
float audVol;
CCUIModuleSliderView *slider;
VolumeControl *volCntl;
AVSystemController *avSys;

// This just creates the slider module variable so it can be used later
%hook CCUIModuleSliderView
- (id)initWithFrame:(CGRect)frame {
  if ([[self class]isEqual:%c(CCUIVolumeSliderView)]) {
    slider = %orig;
  }
  return %orig;
}
%end

%hook VolumeControl
// This creates the Volume control variables so it can be used later
- (id)init {
  volCntl = %orig;
  return volCntl;
}

// For some reason IOS control the button input from this class but not AVSystemController
// This updates the slider value if the volume buttons are pressed.
// It also stops the volume buttons from changing the vol if it is on the ringer mode
- (void)_changeVolumeBy:(float)arg1 {
  [volCntl removeAlwaysHiddenCategory:@"Ringtone"];
  if (ringerMode && ![volCntl _isMusicPlayingSomewhere]) {
    ringVol = [slider value] + arg1;
    [slider setValue:ringVol];
  } else {
    if (!ringerMode) {
      %orig;
    }
  }
}
%end

//Hooks into the class that controls the volume when using the slider.
%hook AVSystemController
- (id)init {
  avSys = %orig;
  return avSys;
}

//Specify which mode and changes that volume
- (BOOL)setVolumeTo:(float)arg1 forCategory:(id)arg2 {
  [volCntl addAlwaysHiddenCategory:@"Ringtone"];
    if (ringerMode) {
      arg2 = @"Ringtone";
      ringVol = arg1;
    } else {
      arg2 = @"Audio/Video";
      audVol = arg1;
    }
  return %orig;
}
%end


%hook CCUIContentModuleContainerViewController
// Resets the volume slider to be in audio mode everytime you exit the cc.
- (void)willResignActive {
  ringerMode = 0;
  [slider setGlyphVisible:TRUE];
  [slider setValue:[volCntl getMediaVolume]];
  %orig;
}

// This fixes a bug with hiding the volume logo.
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
  if (enabled) {
    if (ringerMode) {
      [slider setGlyphVisible:FALSE];
  } else {
      [slider setGlyphVisible:TRUE];
    }
  }
  return %orig;
}

// This adds the UITapGestureRecognizer to the audio module.
- (void)viewWillLayoutSubviews {
  if (enabled) {
    if ([MSHookIvar<NSString*>(self,"_moduleIdentifier") isEqual:@"com.apple.control-center.AudioModule"]) {
      UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
      [MSHookIvar<UIView*>(self,"_contentView") addGestureRecognizer:tapGesture];
      [tapGesture release];
    }
  }
  %orig;
}

 %new
 //Changes between ringerMode and normal mode and adjusts the values.
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateRecognized) {
    if ([MSHookIvar<NSString*>(self, "_moduleIdentifier") isEqual:@"com.apple.control-center.AudioModule"]) {
      ringerMode = !ringerMode;
      if (ringerMode) {
        //Fixes value not showing up properly after respring
        if (!ringVol) {
          [avSys setVolumeTo:[volCntl volume] forCategory:@"Ringtone"];
        }
        [slider setGlyphVisible:FALSE];
        [slider setValue:ringVol];
    } else {
        //Fixes value not showing up properly after respring
      if (!audVol) {
        [avSys setVolumeTo:[volCntl getMediaVolume] forCategory:@"Audio/Video"];
      }
      [slider setGlyphVisible:TRUE];
      [slider setValue:audVol];
      }
    }
  }
}
%end
