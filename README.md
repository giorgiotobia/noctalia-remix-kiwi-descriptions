
# Noctalia Fedora Remix

This is a simple remix of Fedora 44 x86_64, built with fedora kiwi descriptions:
- https://forge.fedoraproject.org/releng/kiwi-descriptions.git

with the addition of Fyra Labs Terra repository:
- https://terrapkg.com

Software is limited to the bare minimum:
- Foot terminal emulator
- Firefox browser
- Thunar file manager
- Gedit text editor

Everything else is standard Fedora core + dependencies

## Features

- Noctalia v5
- Umbriel wayland compositor
- Noctalia-greeter

Noctalia github:
- https://github.com/noctalia-dev

## Installation

It is a live cd so you can install it from live session like a fedora spin.
You find the Install command using "Win+R" keybind or the search icon on Noctalia bar.

## Image build quickstart

This is generally tested and expected to run on the latest stable release of Fedora Linux.
Other distributions may work, but there are no guarantees.

Set up your development environment and run the image build (substitute `<image_type>` and `<image_profile>` for the appropriate settings):

```bash
# Install kiwi
[]$ sudo dnf --assumeyes install kiwi kiwi-systemdeps distribution-gpg-keys
# Run the image build
[]$ sudo ./kiwi-build --kiwi-file=Fedora.kiwi --image-type=iso --image-profile=Noctalia-Live --output-dir ./outdir
```

## Licensing

This is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, under version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
