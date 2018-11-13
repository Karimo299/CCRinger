@class CCUICAPackageDescription, CCUISliderModuleBackgroundViewController, UIGestureRecognizer, CCUIModuleSliderView, AVSystemController;
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
- (void)setGlyphPackageDescription:(CCUICAPackageDescription *)arg1;
- (float)value;
- (void)setValue:(float)arg1;
@end

@interface CCUICAPackageDescription : NSObject
+ (id)descriptionForPackageNamed:(id)arg1 inBundle:(id)arg2;
@end

@interface CCUISliderModuleBackgroundViewController : UIViewController
-(void)setGlyphPackageDescription:(id)arg1;
@end

@interface CCUICAPackageView : UIView
-(void)setPackageDescription:(CCUICAPackageDescription *)arg1;
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

//Beta
static CCUICAPackageView *packView;
static CCUICAPackageDescription *audPack;
static CCUICAPackageDescription *ringPack;
static NSBundle *ringerBundle = [NSBundle bundleWithURL:[NSURL URLWithString:@"file:///System/Library/ControlCenter/Bundles/MuteModule.bundle"]];

//Loads the Preferences
static void loadPrefs() {
  NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.karimo299.ccringer.plist"];
  enabled = [[prefs valueForKey:@"isEnabled"] boolValue];
  expandOnly = [[prefs valueForKey:@"expandOnly"] boolValue];
}

%hook CCUICAPackageDescription
-(id)initWithPackageName:(id)arg1 inBundle:(id)arg2{
  if ([arg1 isEqual:@"Volume"]) {
      audPack = %orig;
      return audPack;
  } else {
    return %orig;
  }
}
%end

%hook CCUIContentModuleContainerViewController
static BOOL isExpanded;

//This changes the volume slider to show the media volume when the CC is closed
- (void)willResignActive {
  ringerMode = 0;
  [slider setValue:[volCntl getMediaVolume]];
  %orig;
}

// This allows tapGesture on the volume slider when it loads
- (void)viewWillLayoutSubviews {
  loadPrefs();
  if (enabled) {
    if ([MSHookIvar<NSString*>(self,"_moduleIdentifier") isEqual:@"com.apple.control-center.AudioModule"]) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [MSHookIvar<UIView*>(self,"_contentView") addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
  }
  %orig;
}

//handles the tapGesture
//You can either use the [packView setPackageDescription:ringPack/audPack]; or [slider setGlyphPackageDescription:ringPack/audPack];
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
            [slider setValue:[volCntl volume]];
          }
          ringPack = [%c(CCUICAPackageDescription) descriptionForPackageNamed:@"Mute" inBundle:ringerBundle];
          [packView setPackageDescription:ringPack];
          [slider setGlyphPackageDescription:nil];
          [slider setValue:ringVol];
      } else {
        if (!audVol) {
          [avSys setVolumeTo:[volCntl getMediaVolume] forCategory:@"Audio/Video"];
          [slider setValue:[volCntl getMediaVolume]];
        }
        [packView setPackageDescription:audPack];
        [slider setGlyphPackageDescription:nil];
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
-(void)_configureGlyphPackageView:(id)arg1 {
  arg1 = packView;
  %orig;
}
-(id)_newGlyphPackageView {
  if ([self isKindOfClass:%c(CCUIVolumeSliderView)]) {
  packView = %orig;
  return packView;
} else {
  return %orig;
}
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
