# Enable the vbox service
systemctl enable vboxservice

# Create the amenthes user and fix permissions on home dir
useradd -m -G wheel -s /bin/bash amenthes
chown -R amenthes:amenthes /home/amenthes

# Setup the lxdm config
sed -i 's/^# \(autologin=.*\)/\1/' /etc/lxdm/lxdm.conf  # uncomment autlogin conf
sed -i 's/dgod/amenthes/' /etc/lxdm/lxdm.conf  # replace autologin user
sed -i 's/^# \(session=.*\)/\1/' /etc/lxdm/lxdm.conf  # uncomment session conf

# Enable the lxdm service
systemctl enable lxdm

# Uncomment wheel group in sudoers
sed -i 's/^# \(%wheel ALL=(ALL) NOPASSWD: ALL\)/\1/' /etc/sudoers
