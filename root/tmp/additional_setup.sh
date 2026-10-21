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
LC_NUMERIC="en_US.UTF-8" echo "\n[output.\"$MONITOR\"]\nscale\ =\ $SCALE\n"
done < <(umbriel outputs | awk '{if($0~/^[A-Z][A-Za-z]*-[0-9]/) mon=$1; {if($0~/current/) print mon, $1, $3}}'))

sed -i -e '/# Outputs$/a\'"$UMBRIEL_OUTPUTS"'' /home/liveuser/.config/umbriel/config.toml

until [[ $(pgrep noctalia) ]]; do
sleep 5
done

INSTALLED=0
while [ $INSTALLED -ne 1 ]; do

until [[ $(pgrep liveinst) ]]; do
sleep 10
done

notify-send -t 60000 "INFO" "Do not restart\nimmediately after the installation finishes;\nwait for 'You can reboot now.' notification to appear."

while [[ $(pgrep liveinst) ]]; do
sleep 5
done

if [[ $(mount | grep sysroot) ]]; then

    if [ -f /mnt/sysroot/etc/greetd/config.toml ]; then
    notify-send "INFO" "Installation is over, please wait, setting:\nKeyboard default layout\ncopying default configs."
    fi

    if [ -f /mnt/sysroot/etc/skel/.config/${WM}/config.toml ]; then
    set -a     
    source /mnt/sysroot/etc/vconsole.conf
        sudo sed -i -r -e "/\[input.keyboard\]/a\layout = \"$KEYMAP\"" /mnt/sysroot/etc/skel/.config/${WM}/config.toml
    set +a
    fi

    if [ -f /mnt/sysroot/etc/xdg/foot/foot.ini ]; then
    sudo cp -r /mnt/sysroot/etc/xdg/foot /mnt/sysroot/etc/skel/.config/
    fi

    FIRSTHOME=$(find /mnt/sysroot/home -maxdepth 1 -mindepth 1 -type d)
    if [ -n "$FIRSTHOME" ]; then
        sudo cp -r /mnt/sysroot/etc/skel/.config/ $FIRSTHOME        
        sudo sed -i -r -e "s/^.*(pad=)[0-9]*x[0-9]*(.*)/\15x5\2/" $FIRSTHOME/.config/foot/foot.ini
        sudo chown -R $(stat -c %u:%g $FIRSTHOME) $FIRSTHOME/.config/
    fi

    sudo rm -f /mnt/sysroot/usr/local/bin/additional_setup.sh

    notify-send "INFO" "You can reboot now."
    INSTALLED=1

fi
sleep 10

done
