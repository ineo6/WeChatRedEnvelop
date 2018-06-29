THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 arm64
TARGET = iphone:latest:7.0

include $(THEOS)/makefiles/common.mk

SRC = $(wildcard src/*.m)

TWEAK_NAME = WeChatRedEnvelop
WeChatRedEnvelop_FILES = $(wildcard src/*.m) src/Tweak.xm
WeChatRedEnvelop_FRAMEWORKS = UIKit

SUBSTRATE ?= yes
instance_USE_SUBSTRATE = $(SUBSTRATE)

#指定版本
_THEOS_TARGET_LDFLAGS += -current_version 1.0
_THEOS_TARGET_LDFLAGS += -compatibility_version 1.0

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
