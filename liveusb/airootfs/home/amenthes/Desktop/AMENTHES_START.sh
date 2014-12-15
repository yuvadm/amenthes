#!/bin/bash

echo '''
###############################################
                            |   |
  _` | __ `__ \   _ \ __ \  __| __ \   _ \  __|
 (   | |   |   |  __/ |   | |   | | |  __/\__ \
\__,_|_|  _|  _|\___|_|  _|\__|_| |_|\___|____/

###############################################



Prepare to enter passphrase for encrypted content...

'''
sudo su
loopdev=$(losetup -f)

losetup ${loopdev} /encrypted
cryptsetup --type luks open ${loopdev} cryptloop
mount /dev/mapper/cryptloop /mnt/decrypted

echo '''


Files decrypted successfully. Opening directory...

'''

sleep 2

pcmanfm /mnt/decrypted &

exit
exit

