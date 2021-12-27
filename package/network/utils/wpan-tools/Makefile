#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wpan-tools
PKG_VERSION:=0.6

PKG_SOURCE_PROTO:=git
# Commit ID corresponds to 0.6 tag, the latest (as of 2021-12-27) is 0.9
PKG_SOURCE_VERSION:=d9dc9737aff2f54e75ec58ec300f9718dda61f57
PKG_SOURCE_URL:=https://github.com/yarisx/wpan-tools.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/wpan-tools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=cfg802154 interface configuration utility
  URL:=http://wpan.cakelab.org/
  DEPENDS:= +libnl
endef

define Build/Configure
	cd $(PKG_BUILD_DIR) && $(CONFIGURE_VARS) ./autogen.sh

	$(call Build/Configure/Default)
endef

define Package/wpan-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/iwpan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wpan-ping/wpan-ping $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/lib/netifd/proto/
	$(CP) ./files/lowpan.sh $(1)/lib/netifd/proto/
endef

$(eval $(call BuildPackage,wpan-tools))
