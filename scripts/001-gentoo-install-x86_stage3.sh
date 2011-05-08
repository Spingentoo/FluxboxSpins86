# 001-gentoo-install-x86_stage3.sh -- Gentoo Stage 3 install script v0.1
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
#

#! /bin/bash
#set -x

# ANSI Color Snippet Picked up from Wicket Cool Shell Scripts Book
# http://www.intuitive.com/wicked/showscript.cgi?011-colors.sh
# All Credits go to Author - Dave Taylor
# ANSI Color -- use these variables to easily have different color
#    and format output. Make sure to output the reset sequence after 
#    colors (f = foreground, b = background), and use the 'off'
#    feature for anything you turn on.

  esc="\033"

  blackf="${esc}[30m";   redf="${esc}[31m";    greenf="${esc}[32m"
  yellowf="${esc}[33m"   bluef="${esc}[34m";   purplef="${esc}[35m"
  cyanf="${esc}[36m";    whitef="${esc}[37m"
  
  blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
  yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
  cyanb="${esc}[46m";    whiteb="${esc}[47m"

  boldon="${esc}[1m";    boldoff="${esc}[22m"
  italicson="${esc}[3m"; italicsoff="${esc}[23m"
  ulon="${esc}[4m";      uloff="${esc}[24m"
  invon="${esc}[7m";     invoff="${esc}[27m"

  reset="${esc}[0m"

## BASE CONFIG ##

GENTOO_CONF_FILES="gentoo-conf"
INSTALL_PATH="/mnt/gentoo"
PWD=`pwd`
SETUP_DIR=$PWD
clear;

setup_device()
{
	echo -e "${boldon}${redf}Starting Gentoo 32-bit Install for Stage 3....${reset}"
	sleep 5;

        echo -e "${boldon}${redf}Enter the Partition name for Gentoo Install: ${reset}"
        read device_partition
        echo -e "${boldon}${yellowf}You have entered Device: $device_partition ${reset}"
        echo -e "${boldon}${redf}NOTE: ALL DATA in $device_partition will be LOST !!! ${reset}"
        echo -e "${boldon}${greenf}Type [yes or no] to proceed :${reset}"
	read device_ans
        case $device_ans in
                yes) ;;
                no) exit 1; 
			;;
       		*)      echo "Invalid input"; exit 1;
        		;;
	esac

        echo -e "${boldon}${redf}Enter the Partition name for SWAP: ${reset}"
        read swap_partition
        echo -e "${boldon}${yellowf}You have entered Device: $swap_partition ${reset}"
        echo -e "${boldon}${redf}NOTE: ALL DATA in $swap_partition will be LOST !!! ${reset}"
        echo -e "${boldon}${greenf}Type [yes or no] to proceed :${reset}"
	read swap_ans
        case $swap_ans in
                yes) ;;
                no) exit 1; 
			;;
       		*)      echo "Invalid input"; exit 1;
        		;;
	esac

INSTALL_DEVICE=$device_partition
SWAP_DEVICE=$swap_partition
}


start_stage3()
{

	echo -e "${yellowf}Created Gentoo Install Directory....${reset}"
	mkdir -p $INSTALL_PATH;
	sleep 5;

	echo -e "${yellowf}Created ext4 fs for $INSTALL_DEVICE....${reset}"
	sleep 10;
	mke2fs -t ext4 $INSTALL_DEVICE;

	echo -e "${yellowf}Activated SWAP for $SWAP_DEVICE....${reset}"
	sleep  10;
	mkswap $SWAP_DEVICE;

	echo -e "${yellowf}Changing to Gentoo Directory....${reset}"
	mount $INSTALL_DEVICE $INSTALL_PATH/;
}

download_stage3_files()
{
	cd $INSTALL_PATH/;
	echo -e "${yellowf}Downloading Stage3 Files....${reset}"
	wget http://gentoo.osuosl.org/releases/x86/autobuilds/current-stage3/stage3-i686-20110503.tar.bz2;
	wget http://gentoo.osuosl.org/releases/x86/autobuilds/current-stage3/stage3-i686-20110503.tar.bz2.CONTENTS;
	wget http://gentoo.osuosl.org/releases/x86/autobuilds/current-stage3/stage3-i686-20110503.tar.bz2.DIGESTS;
	sleep 2;

	echo -e "${yellowf}Downloading Portage Files....${reset}"
	wget http://gentoo.osuosl.org/snapshots/portage-latest.tar.bz2 ;
	wget http://gentoo.osuosl.org/snapshots/portage-latest.tar.bz2.gpgsig ;
	wget http://gentoo.osuosl.org/snapshots/portage-latest.tar.bz2.md5sum ;
	sleep 2;

	echo -e "${greenf}MD5SUM Completed....${reset}"
	md5sum -c stage3-*.DIGESTS ;
	md5sum -c portage-*.md5sum ;
	sleep 2;

	echo -e "${greenf}Untarring Stage3 files....${reset}"
	tar --numeric-owner -xvjpf stage3-*.tar.bz2
	sleep 2;

	echo -e "${greenf}Untarring Portage Files....${reset}"
	tar xvjf $INSTALL_PATH/portage-latest.tar.bz2 -C $INSTALL_PATH/usr
	sleep 5;
}

finish_stage3()
{
	echo -e "${greenf}Copying Gentoo specific Config files....${reset}"
	cd $SETUP_DIR

	#Default Gentoo Config files
	cp $GENTOO_CONF_FILES/localtime.gentoo $INSTALL_PATH/etc/localtime ;
	cp $GENTOO_CONF_FILES/locale.gen.gentoo $INSTALL_PATH/etc/locale.gen ;
	cp $GENTOO_CONF_FILES/rc.conf.gentoo $INSTALL_PATH/etc/rc.conf ;
	cp $GENTOO_CONF_FILES/keymaps.gentoo $INSTALL_PATH/etc/conf.d/keymaps ;
	cp $GENTOO_CONF_FILES/clock.gentoo $INSTALL_PATH/etc/conf.d/clock ;
	cp $GENTOO_CONF_FILES/wifi.gentoo $INSTALL_PATH/root/wpa_supplicant.conf;
	cp $GENTOO_CONF_FILES/fstab.gentoo $INSTALL_PATH/etc/fstab ;
	cp $GENTOO_CONF_FILES/hostname.gentoo $INSTALL_PATH/etc/conf.d/hostname ;
	cp $GENTOO_CONF_FILES/hosts.gentoo $INSTALL_PATH/etc/hosts ;

	#Custom Gentoo Config files
	cp scripts/002-gentoo-configure-x86_stage3.sh $INSTALL_PATH/root/;

	cp $GENTOO_CONF_FILES/make.conf.gentoo $INSTALL_PATH/etc/make.conf ;
	cp $GENTOO_CONF_FILES/net.gentoo.eth0 $INSTALL_PATH/etc/conf.d/net ;
	cp $GENTOO_CONF_FILES/resolv.conf.gentoo $INSTALL_PATH/etc/resolv.conf ;
	cp $GENTOO_CONF_FILES/resolv.conf.gentoo $INSTALL_PATH/root/resolv.conf ;

	mkdir -p $INSTALL_PATH/etc/portage
	cp $GENTOO_CONF_FILES/package.* $INSTALL_PATH/root/
	cp $GENTOO_CONF_FILES/package.use.gentoo $INSTALL_PATH/etc/portage/package.use
	cp $GENTOO_CONF_FILES/package.license.gentoo $INSTALL_PATH/etc/portage/package.license
	cp $GENTOO_CONF_FILES/grub.conf.gentoo.vm $INSTALL_PATH/root/
	cp $GENTOO_CONF_FILES/grub.conf.gentoo.sda $INSTALL_PATH/root/
	cp $GENTOO_CONF_FILES/fluxbox.startup.gentoo $INSTALL_PATH/root/
	cp $GENTOO_CONF_FILES/conkyrc.gentoo $INSTALL_PATH/root/
	cp $GENTOO_CONF_FILES/grub_buddha_tux.xpm.gz $INSTALL_PATH/root/

	echo -e "${yellowf}Its Time to chroot....${reset}"
	echo -e "${boldon}${redf}Now run ./chroot2Gentoo-0.1.sh to enter Your Gentoo Environment${reset}"
	echo -e "${boldon}${redf}Next:Please run Gentoo Stage 3 Configure script !!! ${reset}"
	sleep 5;
}

setup_device
start_stage3
download_stage3_files
finish_stage3
