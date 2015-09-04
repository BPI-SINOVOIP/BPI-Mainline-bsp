# BPI-Mainline-bsp


>  **Build**

  1. Choose a board, Bananapi_M1, Bananapi_M1_Plus, Bananapi_M2 or Bananapi_R1.

     `$ ./configure Bananapi_M1`

  2. Compile
  
      `$ make`


> **Boot**

  1. Partition the sdcard with a 32MB FAT32 boot partition starting at 1MB, and the rest as rootfs partition with ext4 format. You can change the boot partition size as you want.

  2. Create a file boot.cmd on the boot partition.

    --------------------------------------------------------

    `setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait panic=10`

    `load mmc 0:1 0x43000000 bananapi/${fdtfile}`

    `load mmc 0:1 0x42000000 bananapi/uImage`

    `bootm 0x42000000 - 0x43000000`

    ---------------------------------------------------------

  3. Convert boot.cmd to boot.scr

     `$ mkimage -C none -A arm -T script -d boot.cmd boot.scr`

  4. Download u-boot

     `$ sudo dd if=u-boot-sunxi-with-spl.bin of=/dev/sdX bs=1024 seek=8`

  5. Copy uImage and dtb files to ${BOOT_PARTITION}/bananapi/.

  6. Copy your rootfs to rootfs partition and copy kernel modules.

  7. Copy package/bcm_firmware/brcm folder to ${ROOTFS_PARTITION}/lib/firmware/ for BPI-M2 and BPI-M1-Plus WLAN available.
