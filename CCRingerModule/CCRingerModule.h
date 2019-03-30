#import <ControlCenterUIKit/CCUIContentModule.h>
#import <ControlCenterUIKit/CCUISliderModuleBackgroundViewController.h>
#import <ControlCenterUIKit/CCUIContentModuleContentViewController.h>
#import "CCRingerModuleContentViewController.h"
#import <ControlCenterUI/ControlCenterUI-Structs.h>

@interface CCRingerModule : NSObject <CCUIContentModule>

//This is what controls the view for the default UIElements that will appear before the module is expanded
///@property (nonatomic, retain) UIViewController *contentViewController;

///@property (nonatomic,retain) UIViewController * backgroundViewController;
-(UIViewController*)backgroundViewController;
-(UIViewController*)contentViewController;
-(CCUICAPackageDescription*)ringerPackageDescription;
@end
