#import "CCRingerModuleContentViewController.h"

extern NSString *const kCAFilterDestOut;

@interface CALayer (Private)
@property(nonatomic, retain) NSString *compositingFilter;
@property(nonatomic, assign) BOOL allowsGroupOpacity;
@property(nonatomic, assign) BOOL allowsGroupBlending;
@end

@interface MTMaterialView : UIView
- (double)_continuousCornerRadius;
@end

@implementation CCRingerModuleContentViewController
- (id)initWithNibName:(id)arg1 bundle:(id)arg2 {
    self = [super initWithNibName:arg1 bundle:arg2];
    if (self) {
        self.sliderView = [CCUIModuleSliderView new];
        self.sliderView.interactiveWhenUnexpanded = YES;
        self.sliderView.value = self.volume;
        self.view = self.sliderView;
        [self.sliderView addTarget:self
                            action:@selector(valueChanged:)
                  forControlEvents:UIControlEventValueChanged];
    }

    return self;
}

- (void)setGlyphPackageDescription:
    (CCUICAPackageDescription *)packageDescription {
    [self loadViewIfNeeded];
    [self.sliderView setGlyphPackageDescription:packageDescription];
}

- (void)setGlyphState:(NSString *)state {
    [self loadViewIfNeeded];
    [self.sliderView setGlyphState:state];
}

- (NSString *)glyphStateForValue:(float)value {

    return (value >= 0.07) ? @"ringtone" : @"silent";
}

- (float)volume {
    float volume = 0.06;
    if ([self.audioController getVolume:&volume forCategory:@"Ringtone"]) {
    }
    return volume;
}

- (void)viewWillAppear:(BOOL)arg1 {
    [super viewWillAppear:arg1];
    [self.volumeController addAlwaysHiddenCategory:@"Ringtone"];
    self.sliderView.value = self.volume;
    [self setGlyphState:[self glyphStateForValue:self.volume]];
}

- (void)viewDidDisappear:(BOOL)arg1{
	    [super viewDidDisappear:arg1];
    [self.volumeController removeAlwaysHiddenCategory:@"Ringtone"];
}

// This is where you add your subviews (this is the first method when
// self.view.bounds.size.width doesn't return 0)
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setSliderCornerRadius];
}

- (double)preferredExpandedContentHeight {

    return UIScreen.mainScreen.bounds.size.height * 0.47;
}

- (double)preferredExpandedContentWidth {

    return 123;
}

// called before transitioning to the expanded content mode
- (void)willTransitionToExpandedContentMode:(BOOL)willTransition {
    [self.sliderView setGlyphVisible:!willTransition];
}

/// Handle Slider
- (void)valueChanged:(CCUIModuleSliderView *)slider {
		    [self.volumeController addAlwaysHiddenCategory:@"Ringtone"];
slider.value=(slider.value>=0.07)? slider.value: 0.06;
    if (![self.audioController setVolumeTo:slider.value
                               forCategory:@"Ringtone"]) {
        NSLog(@"setVolumeForRingtone failed.");
    }
    [self setGlyphState:[self glyphStateForValue:slider.value]];
}

// Volume controllers
- (AVSystemController *)audioController {

    return (AVSystemController *)[AVSystemController sharedAVSystemController];
}

- (VolumeControl *)volumeController {
    return (VolumeControl *)[objc_getClass("VolumeControl")
        sharedVolumeControl];
}

/// SliderCornerFix
- (void)setSliderCornerRadius {

    float newCornerRadius = 0;
    for (UIView *view in self.view.superview.subviews) {
        if ([view isKindOfClass:[objc_getClass("MTMaterialView") class]]) {
            newCornerRadius = [(MTMaterialView *)view _continuousCornerRadius];
            break;
        }
    }

    self.sliderView.continuousSliderCornerRadius = newCornerRadius;
}

////Glyph styling

- (BOOL)isGroupRenderingRequired {

    return self.sliderView.isGroupRenderingRequired;
}
- (CALayer *)punchOutRootLayer {
    return self.sliderView.punchOutRootLayer;
}
@end