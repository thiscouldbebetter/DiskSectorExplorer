#!/bin/sh
fasm DiskSectorExplorer.asm
qemu-system-x86_64 -boot a -fda DiskSectorExplorer.bin -hda Disk.img

