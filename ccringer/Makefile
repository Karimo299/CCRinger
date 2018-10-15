include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CCRinger
CCRinger_FILES = CCRRootListController.m
CCRinger_INSTALL_PATH = /Library/PreferenceBundles
CCRinger_FRAMEWORKS = UIKit
CCRinger_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CCRinger.plist$(ECHO_END)
