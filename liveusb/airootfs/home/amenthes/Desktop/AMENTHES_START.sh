#!/bin/bash

echo '''
###############################################
                            |   |
  _` | __ `__ \   _ \ __ \  __| __ \   _ \  __|
 (   | |   |   |  __/ |   | |   | | |  __/\__ \
\__,_|_|  _|  _|\___|_|  _|\__|_| |_|\___|____/

###############################################



Decrypting Amenthes payload...

'''
loopdev=$(losetup -f)

sudo losetup ${loopdev} /encrypted
sudo cryptsetup --type luks open ${loopdev} cryptloop
sudo mount /dev/mapper/cryptloop /mnt/decrypted

echo '''


Files decrypted successfully. Opening directory...

'''

sleep 2

pcmanfm /mnt/decrypted &

exit

