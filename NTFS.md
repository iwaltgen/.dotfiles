# macFuse NTFS

## Prerequisites

[macFuse](https://osxfuse.github.io/)

## Mount

```sh
# x is disk number and y is slice

# sudo umount /dev/diskxsy
sudo umount /dev/disk2s1

# sudo mount -t ntfs -o rw,auto,nobrowse /dev/diskxsy ~/ntfs
sudo mount -t ntfs -o rw,auto,nobrowse /dev/disk2s1 ~/.ntfs
```
