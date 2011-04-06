# chroot2Gentoo-0.1.sh -- chroot to Gentoo environment v0.1
# Usage: ./chroot2Gentoo-0.1.sh <device name> <install path>
# Example: ./chroot2Gentoo-0.1.sh /dev/sda7 /mnt/gentoo
# Copyright (C) 2011 Vishwanath Venkataraman (thelinuxguyis@yahoo.co.in)
# This program is relased under GNU GPL Version 3, 29 June 2007
# For conditions of distribution and use, see copyright notice in COPYRIGHT.txt
# This is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


#! /bin/bash
##set -x

clear

if [ ! $# == 2 ]; then
  echo "Usage: ./chroot2Gentoo-0.1.sh <device name> <install path>"
  echo "Example: ./chroot2Gentoo-0.1.sh /dev/sda7 /mnt/gentoo"
  exit
fi

INSTALL_DEVICE=$1
INSTALL_PATH=$2

echo -e "Mounting /proc & /dev...."
mount $INSTALL_DEVICE $INSTALL_PATH

echo -e "Mounting /proc & /dev...."
mount -o bind /proc $INSTALL_PATH/proc ; mount -o bind /dev $INSTALL_PATH/dev ;

sleep 2;

echo "Welcome to GENTOO LINUX chroot environment...."
chroot /mnt/gentoo /bin/env -i TERM=$TERM /bin/bash ;
