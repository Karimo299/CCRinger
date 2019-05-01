#import <ControlCenterUIKit/CCUIAudioModuleViewController.h>
#import <ControlCenterUIKit/CCUICAPackageDescription.h>
#import <ControlCenterUIKit/CCUIVolumeSliderView.h>
#import <ControlCenterUIKit/CCUISliderModuleBackgroundViewController.h>
#import <ControlCenterUIKit/CCUICAPackageView.h>
#import <SpringBoard/VolumeControl.h>


@interface CCUIModuleSliderView ()
@property (nonatomic, retain) CCUICAPackageView *ringerGlyphImageView;
@end

@interface CALayer (Private)
@property (nonatomic, retain) NSString *compositingFilter;
@property (nonatomic, assign) BOOL allowsGroupOpacity;
@property (nonatomic, assign) BOOL allowsGroupBlending;
@end

@interface AVSystemController : NSObject
-(BOOL)getVolume:(float*)arg1 forCategory:(id)arg2 ;
-(BOOL)setVolumeTo:(float)arg1 forCategory:(id)arg2;
+(id)sharedAVSystemController;
@end


@interface CCRingerController :  NSObject
@property (nonatomic, retain) CCUIAudioModuleViewController *ccVolumeController;
@property (nonatomic, retain) CCUISliderModuleBackgroundViewController *ccVolumeBackController;
@property (nonatomic, assign) BOOL isRinger;
@end

static BOOL enabled = YES;
static BOOL expandOnly = YES;
static BOOL rememberMode = NO;

@implementation CCRingerController
- (void)handleTapGesture {
	if ((enabled && !expandOnly) || (enabled && expandOnly && [[self.ccVolumeController valueForKey:@"_expanded"] boolValue])) {
    self.isRinger = !self.isRinger;
    [self setGlyphs];
    [(CCUIVolumeSliderView *)self.ccVolumeController.view setValue:self.volume];
  }
}

- (NSString *)category {
  return self.isRinger ? @"Ringtone" : @"Audio/Video";
}

- (float)volume {
    float volume = 0.06;
    [self.systemController getVolume:&volume forCategory:self.category];
    return volume;
}

- (void)setGlyphs {
    CCUICAPackageDescription *packageDescription = self.isRinger ? self.ringerPackageDescription : self.audioPackageDescription;
    [self.ccVolumeBackController setGlyphPackageDescription:packageDescription];
    BOOL expanded = [[self.ccVolumeController valueForKey:@"_expanded"] boolValue];
    CCUIVolumeSliderView *volumeSlider = (CCUIVolumeSliderView *)self.ccVolumeController.view;
    [volumeSlider setGlyphVisible:!(self.isRinger || expanded)];
    volumeSlider.ringerGlyphImageView.hidden = (!self.isRinger || expanded);
}

- (CCUICAPackageDescription *)audioPackageDescription {
	return [CCUICAPackageDescription descriptionForPackageNamed:@"Volume" inBundle:[NSBundle bundleWithURL: [NSURL URLWithString: @"file:///System/Library/ControlCenter/Bundles/AudioModule.bundle"]]];
}

- (CCUICAPackageDescription *)ringerPackageDescription {
  return [CCUICAPackageDescription descriptionForPackageNamed:@"Mute" inBundle:[NSBundle bundleWithURL: [NSURL URLWithString: @"file:///System/Library/ControlCenter/Bundles/MuteModule.bundle"]]];
}

- (AVSystemController *)systemController {
	return [%c(AVSystemController) sharedAVSystemController];
}

- (VolumeControl *)volumeController {
	return [%c(VolumeControl) sharedVolumeControl];
}
@end

CCRingerController*ringerController = [CCRingerController new];

static void loadPrefs() {
    static NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.karimo299.ccringer"];
		enabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
		expandOnly = [prefs objectForKey:@"expandOnly"] ? [[prefs objectForKey:@"expandOnly"] boolValue] : NO;
		rememberMode = [prefs objectForKey:@"rememberMode"] ? [[prefs objectForKey:@"rememberMode"] boolValue] : NO;

		if(!enabled){
		[ringerController handleTapGesture];
		}
}

%group CCBundleHooks
%hook CCUIAudioModule
- (UIViewController *)backgroundViewController {
    ringerController.ccVolumeBackController =(CCUISliderModuleBackgroundViewController*) %orig;
    return ringerController.ccVolumeBackController;
}

- (UIViewController *)contentViewController {
    ringerController.ccVolumeController = (CCUIAudioModuleViewController*)%orig;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:ringerController action:@selector(handleTapGesture)];
    [ringerController.ccVolumeController.view addGestureRecognizer:tapGesture];
    return ringerController.ccVolumeController;
}
%end

%hook CCUIAudioModuleViewController
-(void)viewWillDisappear:(BOOL)arg1 {
	if (ringerController.isRinger && !rememberMode) {
 		[ringerController.volumeController removeAlwaysHiddenCategory:@"Ringtone"];
		[ringerController handleTapGesture];
	}
	%orig;
}

-(void)_sliderValueDidChange:(CCUIVolumeSliderView*)slider {
	if (ringerController.isRinger){
		[ringerController.volumeController addAlwaysHiddenCategory:@"Ringtone"];
		slider.value = (slider.value>=0.07) ? slider.value: 0.06;
		[ringerController.systemController setVolumeTo:slider.value forCategory:@"Ringtone"];
	} else {
		%orig;
	}
}

-(void)volumeController:(id)arg1 volumeValueDidChange:(float)arg2 {
	if (!ringerController.isRinger) {
		%orig;
	}
}

- (void)willTransitionToExpandedContentMode:(BOOL)willTransition {
	if (ringerController.isRinger && !willTransition && expandOnly) {
		[ringerController handleTapGesture];
	}
	%orig;
	[ringerController setGlyphs];
}
%end

extern NSString* const kCAFilterDestOut;

%hook CCUIVolumeSliderView
%property (nonatomic, retain) CCUICAPackageView *ringerGlyphImageView;

- (id)initWithFrame:(CGRect)frame {
	CCUIVolumeSliderView *orig = %orig;
	orig.ringerGlyphImageView = [self _newGlyphPackageView];
	orig.ringerGlyphImageView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
	[orig addSubview:orig.ringerGlyphImageView];
	orig.ringerGlyphImageView.layer.allowsGroupBlending = NO;
	orig.ringerGlyphImageView.layer.allowsGroupOpacity = YES;
	orig.ringerGlyphImageView.layer.compositingFilter = kCAFilterDestOut;
	[orig.ringerGlyphImageView setPackageDescription:ringerController.ringerPackageDescription];
	orig.ringerGlyphImageView.hidden = YES;
	return orig;
}

- (void)layoutSubviews {
	%orig;
	if ([self valueForKey:@"_glyphPackageView"]) {
		UIView *glyphView = (UIView *)[self valueForKey:@"_glyphPackageView"];
		if (self.ringerGlyphImageView) {
			self.ringerGlyphImageView.layer.allowsGroupBlending = NO;
			self.ringerGlyphImageView.layer.allowsGroupOpacity = YES;
			self.ringerGlyphImageView.layer.compositingFilter = kCAFilterDestOut;
			self.ringerGlyphImageView.frame = glyphView.frame;
		}
	}
}
%end

%end


static void bundleWasLoaded(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSBundle *bundle = (__bridge NSBundle *)(object);
    if ([bundle.bundleIdentifier isEqualToString:@"com.apple.control-center.AudioModule"] || [bundle.bundleIdentifier isEqualToString:@"com.jailbreak365.control-center.TinyAudio1131Module"] || [bundle.bundleIdentifier isEqualToString:@"com.jailbreak365.control-center.TinyAudio1112Module."]) {
			%init(CCBundleHooks)
    }
}

%ctor{
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetLocalCenter(), NULL, bundleWasLoaded,
            (CFStringRef)NSBundleDidLoadNotification, NULL,
            CFNotificationSuspensionBehaviorCoalesce);

                CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(), NULL,
		(CFNotificationCallback)loadPrefs,
		CFSTR("com.karimo299.ccringer/prefChanged"), NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
    }
}
