include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WishDia

WishDia_FILES = /mnt/d/codes/wishdia/Tweak.xm
WishDia_FRAMEWORKS = CydiaSubstrate UIKit CoreGraphics QuartzCore
WishDia_PRIVATE_FRAMEWORKS = 
WishDia_LDFLAGS = -Wl,-segalign,4000

export ARCHS = armv7 arm64
WishDia_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
all::
