.PHONY: all clean help
.PHONY: u-boot kernel kernel-config
.PHONY: linux pack

include chosen_board.mk

SUDO=sudo

CROSS_COMPILE=arm-linux-gnueabihf-
OUTPUT_DIR=$(CURDIR)/output
BUILD_PATH=$(CURDIR)/build
U_O_PATH=$(BUILD_PATH)/$(BOARD)/$(UBOOT_CONFIG)-u-boot
K_O_PATH=$(BUILD_PATH)/$(BOARD)/$(KERNEL_CONFIG)-kernel
U_CONFIG_H=$(U_O_PATH)/include/config.h
K_DOT_CONFIG=$(K_O_PATH)/.config

J=$(shell expr `grep ^processor /proc/cpuinfo  | wc -l` \* 2)

all: bsp

## DK, if u-boot and kernel KBUILD_OUT issue fix, u-boot-clean and kernel-clean
## are no more needed
clean: 
	rm -rf $(BUILD_PATH)
	rm -f chosen_board.mk

## pack
#pack: sunxi-pack
#	$(Q)scripts/mk_pack.sh

# u-boot
$(U_CONFIG_H): BPI-Mainline-uboot/.git
	$(Q)mkdir -p $(U_O_PATH)
	$(Q)$(MAKE) -C u-boot $(UBOOT_CONFIG) O=$(U_O_PATH) CROSS_COMPILE=$(CROSS_COMPILE) -j$J

u-boot: $(U_CONFIG_H)
	$(Q)$(MAKE) -C u-boot all O=$(U_O_PATH) CROSS_COMPILE=$(CROSS_COMPILE) -j$J

## linux
$(K_DOT_CONFIG): kernel
	$(Q)mkdir -p $(K_O_PATH)
	$(Q)$(MAKE) -C kernel O=$(K_O_PATH) ARCH=arm $(KERNEL_CONFIG)

kernel: $(K_DOT_CONFIG)
	$(Q)$(MAKE) -C kernel O=$(K_O_PATH) ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} -j$J dtbs
	$(Q)$(MAKE) -C kernel O=$(K_O_PATH) ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} -j$J INSTALL_MOD_PATH=output LOADADDR=0x40008000 uImage modules
	$(Q)$(MAKE) -C kernel O=$(K_O_PATH) ARCH=arm CROSS_COMPILE=${CROSS_COMPILE} -j$J INSTALL_MOD_PATH=output modules_install

kernel-config: $(K_DOT_CONFIG)
	$(Q)$(MAKE) -C kernel O=$(K_O_PATH) ARCH=arm menuconfig
	cp linux-sunxi/.config linux-sunxi/arch/arm/configs/$(KERNEL_CONFIG)

## bsp
bsp: u-boot kernel

update:
	$(Q)git stash
	$(Q)git pull --rebase
	$(Q)git submodule -q init 
	$(Q)git submodule -q foreach git stash save -q --include-untracked "make update stash"
	-$(Q)git submodule -q foreach git fetch -q
	-$(Q)git submodule -q foreach "git rebase origin HEAD || :"
	-$(Q)git submodule -q foreach "git stash pop -q || :"
	-$(Q)git stash pop -q
	$(Q)git submodule status

%/.git:
	$(Q)git submodule init
	$(Q)git submodule update $*

help:
	@echo ""
	@echo "Usage:"
	@echo "  make bsp             - Default 'make'"
	@echo "  make clean"          - clean obj
	@echo ""
	@echo "Optional targets:"
	@echo "  make kernel          - Builds linux kernel"
	@echo "  make kernel-config   - Menuconfig"
	@echo "  make u-boot          - Builds u-boot"
	@echo ""

