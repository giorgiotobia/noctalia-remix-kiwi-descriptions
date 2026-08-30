#!/usr/bin/env bash

WM=umbriel

until [[ $(pgrep noctalia) ]]; do
sleep 5
done

notify-send -t 60000 "INFO" "If you decide to Install do not restart\n immediately after the installation finishes;\n wait for a notification to appear."

until [ -d /home/liveuser/.local/share/slitherer ]; do
sleep 10
done

while [[ $(pgrep liveinst) ]]; do
sleep 5
done

if [ -f /mnt/sysroot/etc/greetd/config.toml ]; then
notify-send "INFO" "Installation is over, please wait, setting:\nWayland default session\nKeyboard default layout\ncopying default configs."
sudo bash -c 'sed -i -r -e "s|^(command = \"/usr/bin/noctalia-greeter-session)\"$|\1 -- --session '$WM'\"|" /mnt/sysroot/etc/greetd/config.toml'
fi

if [ -f /mnt/sysroot/etc/skel/.config/${WM}/config.toml ]; then
set -a     
source /mnt/sysroot/etc/vconsole.conf
sudo bash -c 'sed -i -r -e "/\[input.keyboard\]/,/^$/ s/(layout = \").*/\1'$KEYMAP'\"/" /mnt/sysroot/etc/skel/.config/'${WM}'/config.toml'
set +a
fi

if [ -f /mnt/sysroot/etc/xdg/foot/foot.ini ]; then
sudo cp -r /mnt/sysroot/etc/xdg/foot /mnt/sysroot/etc/skel/.config/
sudo bash -c 'sed -i -r -e "s/^.*(pad=)[0-9]*x[0-9]*(.*)/\15x5\2/" /mnt/sysroot/etc/skel/.config/foot/foot.ini'
fi

FIRSTHOME=$(find /mnt/sysroot/home -maxdepth 1 -mindepth 1 -type d)
if [ -n "$FIRSTHOME" ]; then
sudo cp -r /mnt/sysroot/etc/skel/.config/ $FIRSTHOME
sudo chown -R $(stat -c %u:%g $FIRSTHOME) /mnt/sysroot/etc/skel/.config/foot
fi

sudo rm -f /mnt/sysroot/usr/local/bin/additional_setup.sh

notify-send "INFO" "You can reboot now."
