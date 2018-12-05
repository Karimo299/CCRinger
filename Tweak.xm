@class CCUICAPackageDescription, CAPackage, CCUISliderModuleBackgroundViewController, UIGestureRecognizer, CCUIModuleSliderView, AVSystemController;
//interfaces
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

@interface CCUIModuleSliderView : UIControl
- (void)setGlyphVisible:(BOOL)arg1;
- (void)setGlyphPackageDescription:(CCUICAPackageDescription *)arg1;
- (float)value;
- (void)setValue:(float)arg1;
@end

// Variables I will need
static BOOL enabled;
static BOOL expandOnly;
static BOOL ringerMode;
static float ringVol;
static float audVol;
static CCUIModuleSliderView *slider;
static VolumeControl *volCntl;
static AVSystemController *avSys;

//Loads the Preferences
static void loadPrefs() {
    static NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.karimo299.ccringer"];
		enabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : NO;
		expandOnly = [prefs objectForKey:@"expandOnly"] ? [[prefs objectForKey:@"expandOnly"] boolValue] : NO;    
}

%hook CCUIContentModuleContainerViewController
static BOOL isExpanded;

//This changes the volume slider to show the media volume when the CC is closed
- (void)willResignActive {
  ringerMode = 0;
  [slider setGlyphVisible:YES];
  [slider setValue:[volCntl getMediaVolume]];
  %orig;
}

// This allows tapGesture on the volume slider when it loads
- (void)viewWillLayoutSubviews {
  if (enabled) {
    if ([MSHookIvar<NSString*>(self,"_moduleIdentifier") isEqual:@"com.apple.control-center.AudioModule"]) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [MSHookIvar<UIView*>(self,"_contentView") addGestureRecognizer:tapGesture];
    }
  }
  %orig;
}

//handles the tapGesture
//You can either use the [packView setPackageDescription:ringDesc/audDesc]; or [slider setGlyphPackageDescription:ringDesc/audDesc];
//packView sets the glyph really dim and slider sets it really white
 %new
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateRecognized) {
    if ([MSHookIvar<NSString*>(self, "_moduleIdentifier") isEqual:@"com.apple.control-center.AudioModule"]) {
      isExpanded = MSHookIvar<BOOL>(self,"_expanded");
      if ((expandOnly && isExpanded) || !expandOnly) {
        ringerMode = !ringerMode;
        if (ringerMode) {
          if (!ringVol) {
            [avSys setVolumeTo:[volCntl volume] forCategory:@"Ringtone"];
            ringVol = [volCntl volume];
          }
          [slider setGlyphVisible:NO];
          [slider setValue:ringVol];
      } else {
        if (!audVol) {
          [avSys setVolumeTo:[volCntl getMediaVolume] forCategory:@"Audio/Video"];
            audVol = [volCntl getMediaVolume];
        }
        [slider setGlyphVisible:YES];
        [slider setValue:audVol];
        }
      }
    }
  }
}
%end

%hook CCUIModuleSliderView
- (id)initWithFrame:(CGRect)frame {
  if ([self isKindOfClass:%c(CCUIVolumeSliderView)]) {
    slider = %orig;
  }
  return %orig;
}

//Prevents the slider value from going under 6% because IOS doesnt allow that
- (void)_continueTrackingWithGestureRecognizer:(id)arg1 {
  %orig;
  if (ringerMode && [slider value] <= 0.0625) {
    [slider setValue:0.0625];
  }
}
%end

%hook VolumeControl
- (id)init {
  volCntl = %orig;
  return volCntl;
}

// updates slider value for the ringer.
- (void)_changeVolumeBy:(float)arg1 {
  [volCntl removeAlwaysHiddenCategory:@"Ringtone"];
  if (ringerMode && ![volCntl _isMusicPlayingSomewhere]) {
    ringVol += arg1;
    if (ringVol <= 0.0625) {
      ringVol = 0.0625;
    }
    [slider setValue:ringVol];
  } else {
    if (!ringerMode) {
      %orig;
    }
  }
}
%end

%hook AVSystemController
- (id)init {
  avSys = %orig;
  return avSys;
}

// finds either Media volume or ringer volume to changes when using the slider.
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

%ctor {
    CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(), NULL,
		(CFNotificationCallback)loadPrefs,
		CFSTR("com.karimo299.ccringer/prefChanged"), NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
}

