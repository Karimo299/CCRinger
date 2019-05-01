ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CCRingerModule
CCRingerModule_BUNDLE_EXTENSION = bundle
CCRingerModule_FILES = CCRingerModule/CCRingerModule.m CCRingerModule/CCRingerModuleContentViewController.m CCRingerModule/CCRingerModuleContentViewController.m CCRingerModule/CCRingerModuleRootListController.m
CCRingerModule_PRIVATE_FRAMEWORKS = ControlCenterUIKit Celestial Preferences
CCRingerModule_EXTRA_FRAMEWORKS += KBPreferences
CCRingerModule_INSTALL_PATH = /Library/ControlCenter/Bundles/
CCRingerModule_CFLAGS = -fobjc-arc


TWEAK_NAME = CCRingerTweak
CCRingerTweak_FILES = CCRingerTweak/CCRingerTweak.xm
CCRingerTweak_PRIVATE_FRAMEWORKS = ControlCenterUIKit Celestial Preferences
CCRingerTweak_CFLAGS = -fobjc-arc

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk
SUBPROJECTS += ccringertweakprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
