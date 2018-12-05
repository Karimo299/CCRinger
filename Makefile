include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CCRinger
CCRinger_FILES = Tweak.xm
CCRinger_EXTRA_FRAMEWORKS += Cephei


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += ccringer
include $(THEOS_MAKE_PATH)/aggregate.mk
