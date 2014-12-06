# Enable the vbox service
systemctl enable vboxservice

# Create the amenthes user
useradd -m -s /bin/bash amenthes

# Setup the lxdm config
echo "session=/usr/bin/startlxde" >> /etc/lxdm/lxdm.conf
echo "autologin=amenthes" >> /etc/lxdm/lxdm.conf
