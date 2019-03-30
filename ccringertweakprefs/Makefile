include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CCRingerTweakPrefs
CCRingerTweakPrefs_FILES = CCRRootListController.m
CCRingerTweakPrefs_INSTALL_PATH = /Library/PreferenceBundles
CCRingerTweakPrefs_FRAMEWORKS = UIKit
CCRingerTweakPrefs_EXTRA_FRAMEWORKS += KBPreferences
CCRingerTweakPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CCRingerTweakPrefs.plist$(ECHO_END)
