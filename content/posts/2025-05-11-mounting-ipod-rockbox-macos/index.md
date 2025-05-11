---
title: "Mounting an iPod with Rockbox on macOS"
slug: "mounting-ipod-rockbox-macos"
date: 2025-05-11T10:00:00+03:00
draft: false
tags: ["macOS", "Rockbox", "iPod", "mounting", "tutorial", "english"]
draft: false
author: "Arda Kılıçdağı"
featuredImage: "posts/mounting-ipod-rockbox-macos/images/cover.webp"
---

Running Rockbox on an old iPod is great for extending battery life and adding features — but sometimes macOS refuses to mount the device automatically. If you’ve installed Rockbox and find your iPod visible in Disk Utility but not in Finder, here’s a quick workaround that gets you back to syncing in no time.

## 1. Confirm the device in Disk Utility

First, check that macOS sees your iPod at the block level. Open Terminal and list all disks:

```bash
diskutil list
```

You should see something like:

```bash
...

/dev/disk4 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *12.0 TB    disk4
   1:                        EFI EFI                     209.7 MB   disk4s1
   2:                  Apple_HFS disk1                   12.0 TB    disk4s2

/dev/disk5 (external, physical):
   #:     FDisk_partition_scheme                        *2.1 TB     disk5
   1:    Windows_FAT_32 IPOD                            2.1 TB     disk5s1
```

> In this example, the iPod appears as `/dev/disk5`, with the FAT32 partition on `/dev/disk5s1`.

If you don't see the drive, try [rebooting the iPod in disk mode](https://discussions.apple.com/thread/251296705).

## 2. Create a mount point

macOS sometimes won’t mount FAT32 volumes with third‑party firmware by default, but you can manually mount the partition. First, create a directory under `/Volumes`:

```bash
sudo mkdir -p /Volumes/arpod
```

You can name the directory whatever you like (`arpod` stands for “Arda's iPod”, so feel free to use any string).

## 3. Mount the FAT32 partition

Next, mount the iPod’s FAT32 slice using the built‑in `msdosfs` driver:

```bash
sudo mount -t msdos /dev/disk5s1 /Volumes/arpod
```

You may see output like:

```
Executing: /usr/bin/kmutil load -p /System/Library/Extensions/msdosfs.kext
```

This indicates that macOS is loading the FAT32 kernel extension to handle the filesystem.

## 4. Access your iPod

Once mounted, you can browse the contents of your iPod at `/Volumes/arpod`:

```bash
ls /Volumes/arpod
```

Sync music or copy files just like any other external volume.

## 5. Unmount when finished

When you’re done, unmount safely so as not to corrupt your device:

```bash
sudo umount /Volumes/arpod
# or
diskutil unmount /Volumes/arpod
```