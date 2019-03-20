@class CCUISliderModuleBackgroundViewController, UIGestureRecognizer, CCUIModuleSliderView, AVSystemController;
//interfaces
@interface VolumeControl : NSObject
+ (id)sharedVolumeControl;
- (void)addAlwaysHiddenCategory:(id)arg1;
- (void)removeAlwaysHiddenCategory:(id)arg1;
- (BOOL)_isMusicPlayingSomewhere;
@end

@interface CCUIContentModuleContainerViewController : NSObject
- (void)handleTapGesture:(UITapGestureRecognizer *)sender;
@end

@interface AVSystemController : NSObject
-(BOOL)getVolume:(float*)arg1 forCategory:(id)arg2 ;
-(BOOL)setVolumeTo:(float)arg1 forCategory:(id)arg2;
+(id)sharedAVSystemController;
@end

@interface CCUIModuleSliderView : UIControl
- (void)setGlyphVisible:(BOOL)arg1;
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
static VolumeControl *volCntl = [%c(VolumeControl) sharedVolumeControl];
static AVSystemController *avSys = [%c(AVSystemController) sharedAVSystemController];

//Loads the Preferences
static void loadPrefs() {
    static NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.karimo299.ccringer"];
		enabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
		expandOnly = [prefs objectForKey:@"expandOnly"] ? [[prefs objectForKey:@"expandOnly"] boolValue] : NO;
}

%hook CCUIModuleSliderView
- (id)initWithFrame:(CGRect)frame {
  if ([self isKindOfClass:%c(CCUIVolumeSliderView)]) slider = %orig;
  return %orig;
}

-(void)layoutSubviews {
  %orig;
  if (ringerMode && !expandOnly) [slider setGlyphVisible:NO];
}

//Prevents the slider value from going under 6% because IOS doesnt allow that
- (void)_continueTrackingWithGestureRecognizer:(id)arg1 {
  [volCntl addAlwaysHiddenCategory:@"Ringtone"];
  %orig;
  if (ringerMode) {
    if ([slider value] <= 0.0625) [slider setValue:0.0625];
    [avSys setVolumeTo:[self value] forCategory:@"Ringtone"];
    ringVol = [self value];
    } else if (audVol) audVol = [self value];
  }
  %end

  %hook VolumeControl
-(void)_changeVolumeBy:(float)arg1 {
  [volCntl removeAlwaysHiddenCategory:@"Ringtone"];
  if (ringerMode && ![volCntl _isMusicPlayingSomewhere]) {
    ringVol += arg1;
    if (ringVol <= 0.0625) ringVol = 0.0625;
    else if (ringVol >= 1) ringVol = 1;
    [slider setValue:ringVol];

    } else if (!ringerMode) %orig;
  }
%end

%hook CCUIContentModuleContainerViewController
static BOOL isExpanded;

//This changes the volume slider to show the media volume when the CC is closed
- (void)willResignActive {
  ringerMode = 0;
  [slider setGlyphVisible:YES];
  [avSys getVolume:&audVol forCategory:@"Audio/Video"];
  [slider setValue:audVol];
  %orig;
}

-(void)setExpanded:(BOOL)arg1 {
  %orig;
  if (expandOnly && !arg1) {
  ringerMode = 0;
  [slider setGlyphVisible:YES];
  [avSys getVolume:&audVol forCategory:@"Audio/Video"];
  [slider setValue:audVol];
  }
}

// This allows tapGesture on the volume slider when it loads
- (void)viewWillLayoutSubviews {
  if (enabled) {
    if ([MSHookIvar<NSString*>(self,"_moduleIdentifier") isEqual:@"com.apple.control-center.AudioModule"] || [MSHookIvar<NSString*>(self,"_moduleIdentifier") isEqual:@"com.jailbreak365.control-center.TinyAudio1131Module"] || [MSHookIvar<NSString*>(self,"_moduleIdentifier") isEqual:@"com.jailbreak365.control-center.TinyAudio1112Module."]) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [MSHookIvar<UIView*>(self,"_contentView") addGestureRecognizer:tapGesture];
    }
  }
  %orig;
}

//handles the tapGesture
 %new
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateRecognized) {
    if ([MSHookIvar<NSString*>(self,"_moduleIdentifier") isEqual:@"com.apple.control-center.AudioModule"] || [MSHookIvar<NSString*>(self,"_moduleIdentifier") isEqual:@"com.jailbreak365.control-center.TinyAudio1131Module"] || [MSHookIvar<NSString*>(self,"_moduleIdentifier") isEqual:@"com.jailbreak365.control-center.TinyAudio1112Module."]) {
      isExpanded = MSHookIvar<BOOL>(self,"_expanded");
      if ((expandOnly && isExpanded) || !expandOnly) {
        ringerMode = !ringerMode;
        if (ringerMode) {
          ringVol  = -1.0;
          [avSys getVolume:&ringVol forCategory:@"Ringtone"];
          [slider setGlyphVisible:NO];
          [slider setValue:ringVol];
      } else {
        audVol  = -1.0;
        [avSys getVolume:&audVol forCategory:@"Audio/Video"];
        [slider setGlyphVisible:YES];
        [slider setValue:audVol];
        }
      }
    }
  }
}
%end


%hook MPVolumeController
-(void)setVolumeValue:(float)arg1 {
  if (!ringerMode) %orig;
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
