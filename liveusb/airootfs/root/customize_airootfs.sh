# Enable the vbox service
systemctl enable vboxservice

# Create the amenthes user
useradd -m -s /bin/bash amenthes

# Setup the lxdm config
sed -i 's/^# \(autologin=.*\)/\1/' /etc/lxdm/lxdm.conf  # uncomment autlogin conf
sed -i 's/dgod/amenthes/' /etc/lxdm/lxdm.conf  # replace autologin user
sed -i 's/^# \(session=.*\)/\1/' /etc/lxdm/lxdm.conf  # uncomment session conf

# Enable the lxdm service
systemctl enable lxdm
