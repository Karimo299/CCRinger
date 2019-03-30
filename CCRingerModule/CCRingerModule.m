#import "CCRingerModule.h"

@implementation CCRingerModule
-(UIViewController*)backgroundViewController{
	
	CCUISliderModuleBackgroundViewController*backgroundViewController =[CCUISliderModuleBackgroundViewController new];
	[backgroundViewController setGlyphPackageDescription:self.ringerPackageDescription];
        [backgroundViewController setGlyphState:@"ringer"];

return backgroundViewController;
	
}

-(UIViewController*)contentViewController{
	
CCRingerModuleContentViewController*contentViewController =[CCRingerModuleContentViewController new];
[contentViewController setGlyphPackageDescription:self.ringerPackageDescription];
        [contentViewController setGlyphState:[contentViewController glyphStateForValue:contentViewController.volume]];
return contentViewController;
	
}

-(CCUICAPackageDescription*)ringerPackageDescription{
	
	return [CCUICAPackageDescription
            descriptionForPackageNamed:@"Mute"
                              inBundle:
                                  [NSBundle
                                      bundleWithURL:
                                          [NSURL URLWithString:
                                                     @"file:///System/Library/"
                                                     @"ControlCenter/Bundles/"
                                                     @"MuteModule.bundle"]]];
}

- (CCUILayoutSize)moduleSizeForOrientation:(int)orientation
{
		NSUserDefaults *preferences =
        [[NSUserDefaults alloc] initWithSuiteName:@"com.kaneb.ccringerprefs"];
	CCUILayoutSize size;
	NSNumber *width, *height;

	if(orientation == 0)
	{
		width = [preferences objectForKey:@"PortraitWidth"];
		height = [preferences objectForKey:@"PortraitHeight"];
	}
	else
	{
		width = [preferences objectForKey:@"LandscapeWidth"];
		height = [preferences objectForKey:@"LandscapeHeight"];
	}

	if(height)
	{
		size.height = [height unsignedLongLongValue];
	}
	else
	{
		//Default value
		size.height = 1;
	}

	if(width)
	{
		size.width = [width unsignedLongLongValue];
	}
	else
	{
		//Default value
		size.width = 1;
	}

	return size;
}
@end
