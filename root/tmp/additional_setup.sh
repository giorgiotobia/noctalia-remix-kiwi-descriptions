#!/usr/bin/env bash

WM=umbriel

UMBRIEL_OUTPUTS=$(while read MONITOR RESOLUTION FREQUENCY; do
if [ ${RESOLUTION%x*} -ge 3840 ]; then
SCALE=1.60
elif [ ${RESOLUTION%x*} -ge 2560 ]; then
SCALE=1.25
else
SCALE=1.00
fi
LC_NUMERIC="en_US.UTF-8" printf "\n[output.\"%s\"]\nmode = \"%s@%.0f\"\nscale = %s\n" $MONITOR $RESOLUTION $FREQUENCY $SCALE
done < <(umbriel outputs | awk '{if($0~/^[A-Z][A-Za-z]*-[0-9]/) mon=$1; {if($0~/current/) print mon, $1, $3}}'))

echo "$UMBRIEL_OUTPUTS" >> /home/liveuser/.config/umbriel/config.toml

until [[ $(pgrep noctalia) ]]; do
sleep 5
done

notify-send -t 60000 "INFO" "If you decide to Install do not restart\nimmediately after the installation finishes;\nwait for 'You can reboot now.' notification to appear."

until [[ $(pgrep liveinst) ]]; do
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
sudo bash -c 'echo '"$UMBRIEL_OUTPUTS"' >> /mnt/sysroot/etc/skel/.config/'${WM}'/config.toml'
fi

if [ -f /mnt/sysroot/etc/xdg/foot/foot.ini ]; then
sudo cp -r /mnt/sysroot/etc/xdg/foot /mnt/sysroot/etc/skel/.config/
# sudo bash -c 'sed -i -r -e "s/^.*(pad=)[0-9]*x[0-9]*(.*)/\15x5\2/" /mnt/sysroot/etc/skel/.config/foot/foot.ini'
fi

FIRSTHOME=$(find /mnt/sysroot/home -maxdepth 1 -mindepth 1 -type d)
if [ -n "$FIRSTHOME" ]; then
sudo cp -r /mnt/sysroot/etc/skel/.config/ $FIRSTHOME
sudo chown -R $(stat -c %u:%g $FIRSTHOME) $FIRSTHOME/.config/
fi

sudo rm -f /mnt/sysroot/usr/local/bin/additional_setup.sh

notify-send "INFO" "You can reboot now."
