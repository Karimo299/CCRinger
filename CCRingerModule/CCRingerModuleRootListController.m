#include "CCRingerModuleRootListController.h"

@implementation CCRingerModuleRootListController

- (NSArray *)specifiers
{
	if(!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"CCRingerModuleRootListController" target:self];
	}

	return _specifiers;
}

@end