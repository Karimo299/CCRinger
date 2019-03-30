#import <ControlCenterUIKit/CCUIContentModuleContentViewController.h>
#import <ControlCenterUIKit/CCUIModuleSliderView.h>
#import <ControlCenterUIKit/CCUICAPackageDescription.h>
#import <ControlCenterUIKit/CCUIGroupRendering.h>
#import <SpringBoard/VolumeControl.h>
#import <Celestial/AVSystemController.h>
#import <objc/runtime.h>

@interface CCRingerModuleContentViewController : UIViewController <CCUIContentModuleContentViewController, CCUIGroupRendering>
@property (nonatomic,retain) CCUIModuleSliderView* sliderView; 

//these are the dimensions of the module once its expanded
@property (nonatomic,readonly) double preferredExpandedContentHeight;
@property (nonatomic,readonly) double preferredExpandedContentWidth;

//not really sure what this is tbh
@property (nonatomic,readonly) BOOL providesOwnPlatter;
-(void)setGlyphPackageDescription:(CCUICAPackageDescription *)packageDescription;
-(void)setGlyphState:(NSString *)state;
-(NSString*)glyphStateForValue:(float)value;
-(float)volume;
@end