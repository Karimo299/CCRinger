// This is the implementation file for the settings Preferences
#include "CCRRootListController.h"

// Must include for respring button
#include <spawn.h>
#include <signal.h>

@implementation CCRRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}
	- (void) paypal {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://paypal.me/Karimo299"]];
	}
		//Github source code button
	- (void) git {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/Karimo299/CCringer"]];
	}
		//Twitter button
	- (void) tweet {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://twitter.com/karimo299"]];
	}

	//Respring button
	- (void) respring {
		pid_t pid;
		int status;
		const char *argv[] = {"killall", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
		waitpid(pid, &status, WEXITED);
	}
@end
