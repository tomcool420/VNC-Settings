export FW_DEVICE_IP=AppleTV.local
export GO_EASY_ON_ME=1
include $(THEOS)/makefiles/common.mk



BUNDLE_NAME = VNCSettings
VNCSettings_FILES =   MLoader.m 
VNCSettings_INSTALL_PATH = /Library/SettingsBundles/
VNCSettings_BUNDLE_EXTENSION = bundle
VNCSettings_LDFLAGS = -undefined dynamic_lookup
VNCSettings_CFLAGS = -I../ATV2Includes
VNCSettings_OBJ_FILES = ../SMFramework/obj/SMFramework

include $(FW_MAKEDIR)/bundle.mk

after-install::
	ssh root@$(FW_DEVICE_IP) killall Lowtide