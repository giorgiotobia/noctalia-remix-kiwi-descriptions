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

echo "$UMBRIEL_OUTPUTS" > /home/liveuser/.config/umbriel/outputs.toml

# Delete comments after files list, otherwise the script that apply theme for umbriel doesn't work
sed -i -r -e "s/(files = \[.*\]) *#.*$/\1/" /home/liveuser/.config/umbriel/config.toml
sed -i -r -e "s/(spawn:)kitty/\1foot/" /home/liveuser/.config/umbriel/config.toml
# add current output to liveuser configuration
sed -i -r -e "/\[include\]$/,/^$/ s/(files = \[)\]/\1\"outputs.toml\"\]/" /home/liveuser/.config/umbriel/config.toml

IS_VIRTUAL=$(systemd-detect-virt)

if [ "$IS_VIRTUAL" == "kvm" ]; then
sed -i -r -e "s/(hardware_cursor =).*/\1 false/" \
    -e '/\[appearance.blur\]/,/^$/ s/(enabled =).*/\1 false/' \
    -e '/\[appearance.shadow\]/,/^$/ s/(enabled =).*/\1 false/' \
    -e '/\[animation\]/,/^$/ s/(enabled =).*/\1 false/' /home/liveuser/.config/umbriel/config.toml
fi

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
    notify-send "INFO" "Installation is over, please wait, setting:\nWayland default session\nKeyboard default layout\ncopying default configs."
    sudo bash -c 'sed -i -r -e "s|^(command = \"/usr/bin/noctalia-greeter-session)\"$|\1 -- --session '$WM'\"|" /mnt/sysroot/etc/greetd/config.toml'
    fi

    if [ -f /mnt/sysroot/etc/skel/.config/${WM}/config.toml ]; then
    set -a     
    source /mnt/sysroot/etc/vconsole.conf
    sudo bash -c 'sed -i -r -e "/\[input.keyboard\]/,/^$/ s/^(layout = \").*/\1'$KEYMAP'\"/" -e "s/(files = \[.*\]) *#.*$/\1/" /mnt/sysroot/etc/skel/.config/'${WM}'/config.toml'
    set +a
    fi

    if [ -f /mnt/sysroot/etc/xdg/foot/foot.ini ]; then
    sudo cp -r /mnt/sysroot/etc/xdg/foot /mnt/sysroot/etc/skel/.config/
    fi

    FIRSTHOME=$(find /mnt/sysroot/home -maxdepth 1 -mindepth 1 -type d)
    if [ -n "$FIRSTHOME" ]; then
    sudo cp -r /mnt/sysroot/etc/skel/.config/ $FIRSTHOME
    sudo chown -R $(stat -c %u:%g $FIRSTHOME) $FIRSTHOME/.config/
    # add current output to first user configuration
    sudo bash -c 'cat > '$FIRSTHOME'/.config/'${WM}'/outputs.toml <<EOF
'"$UMBRIEL_OUTPUTS"'
EOF'
    sudo bash -c 'sed -i -r -e "/\[include\]$/,/^$/ s/(files = \[)\]/\1\"outputs.toml\"\]/" -e "s/(spawn:)kitty/\1foot/" '$FIRSTHOME'/.config/'${WM}'/config.toml'
    sudo bash -c 'sed -i -r -e "s/^.*(pad=)[0-9]*x[0-9]*(.*)/\15x5\2/" '$FIRSTHOME'/.config/foot/foot.ini'
    fi

    sudo rm -f /mnt/sysroot/usr/local/bin/additional_setup.sh

    notify-send "INFO" "You can reboot now."
    INSTALLED=1

fi
sleep 10

done
