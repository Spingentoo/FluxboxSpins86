# 002-gentoo-install-x86_stage3.sh -- Gentoo Stage 3 configure script v0.1
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



init()
{
	clear;
	echo -e "${boldon}${redf}Starting Gentoo 32-bit System Configuration....${reset}"
	sleep 5;

	echo -e "${yellowf}Initializing Gentoo Environment....${reset}"
	env-update ; source /etc/profile ; export PS1="(chroot) $PS1" ;

	cat resolv.conf  >> /etc/resolv.conf
	cd /etc/init.d;
	ln -s net.lo net.eth0
	rc-update add net.eth0 default
	cd /root
}

web_sync()
{
	emerge bzip2;
	rm /usr/portage/metadata/timestamp.x
	echo -e "${yellowf}Sync running from Web....${reset}"
	emerge-webrsync;
	emerge -va vim

	echo -e "${yellowf}Select Gentoo Default Profile....${reset}"
	eselect profile list ; eselect profile set 1 ;
	sleep 5;
}

kernel_and_genkernel_download()
{
	echo -e "${yellowf}Installing Kernel Source....${reset}"
	emerge gentoo-sources ;
	echo -e "${yellowf}Installing Genkernel....${reset}"
	emerge genkernel ;
	mkdir -p /etc/portage/
	sleep 2;
}


kernel_configure_and_install()
{
	echo -e "${yellowf}Cleaning Linux Kernel Objects....${reset}"

        echo -e "${boldon}${redf}Do you want to configure kernel manually ? [yes or no]: ${reset}"
        read kernel_ans
        case $kernel_ans in
                yes) time genkernel --clean --makeopts="-j5" --mrproper --splash --disklabel --install --menuconfig all; 
			;;
		no) echo -e "${yellowf}Auto configuring Gentoo Kernel....${reset}"
                    time genkernel --clean --makeopts="-j5" --mrproper --splash --disklabel --install all; 
			echo -e "${yellowf}Compiling Linux Kernel....${reset}"
			time genkernel --clean --makeopts="-j5" --no-mrproper --splash --disklabel --install all;
			exit 1;;
	esac

	echo -e "${yellowf}Listing of Compiled Kernel & Ramdisk files....${reset}"
	ls /boot/kernel* /boot/initramfs* ;
	echo -e "${yellowf}Kernel Compiled & Modules installed....${reset}"
        echo -e "${boldon}${yellowf}Edit file: 'grub.conf.gentoo' for changes in Partition/Linux Kernel/initrd/initramfs details !!!)${reset}"
	sleep 5;
}

tools_install()
{
	echo -e "${yellowf}Installing Necessary System Tools....${reset}"
	sleep 5;

	emerge syslog-ng ;rc-update add syslog-ng default;
	emerge vixie-cron ; rc-update add vixie-cron default;
	emerge slocate;
	emerge lafilefixer gentoolkit;
	emerge sys-apps/ifplugd;
sleep 5;
}

grub_install()
{
        echo -e "${yellowf}Installing Grub....${reset}"
        emerge grub

        echo -e "${boldon}${yellowf}Have you made changes to file: 'grub.conf.gentoo' for changes in Partition/Linux Kernel/initrd/initramfs details !!!)${reset}"
        read grub_conf
        case $grub_conf in
                yes);;
		no) echo "Please go back and make changes to grub.conf.gentoo" ; exit 1;;
	esac

        echo -e "${boldon}${redf}Enter the GRUB bootloader install device (default: /dev/sda)${reset}"
        read grub_device

        echo -e "${boldon}${greenf}GRUB bootloader will be installed on $grub_device ${reset}"
        echo -e "${boldon}${redf}Do you want to continue ? [yes or no]: ${reset}"
        read grub_ans
        case $grub_ans in
                yes) echo Proceed with  GRUB...... ;;
		no) echo Exitting from the script.....; exit 1;;
	esac

	cp /root/grub.conf.gentoo /boot/grub/grub.conf
	grep -v rootfs /proc/mounts > /etc/mtab
	grub-install --no-floppy $grub_device
}

splash_install()
{
	echo -e "${yellowf}Installing Splash Themes....${reset}"
	sleep 5;
	#emerge -C splash-themes-gentoo 
	emerge -Duv world 
	python-updater
	revdep-rebuild 
	emerge -1 jpeg 
	emerge splashutils 
	emerge splash-themes-livecd
	emerge splash-themes-gentoo
	#tar -zxvf /root/livecd-10.tar.gz -C /etc/splash/
	splash_geninitramfs  --verbose --res 1024x768 --append /boot/initramfs-genkernel-x86-2.6.36-gentoo-r8  natural_gentoo
	#splash_geninitramfs  --verbose --res 1920x1080 --append /boot/initramfs-genkernel-x86-2.6.36-gentoo-r8  livecd-10

### Handy GRUB and SPLASH commands ###
#grub-install --no-floppy /dev/sda
#genkernel --no-clean --splash=livecd-2007.0  --splash-res=1920x1080 initramfs
#splash_geninitramfs  --verbose --res 1920x1080 --append /boot/initramfs-genkernel-x86-2.6.36-gentoo-r8  livecd-10
#splash_manager -c demo -t  CCux -m s --steps=100
#splash_geninitramfs --verbose --res 1024x768  --append /boot/initramfs-genkernel-x86-2.6.36-gentoo-r8 Linux/
#zcat /boot/initramfs-genkernel-x86-2.6.36-gentoo-r8 | cpio --list | grep Linux
}

xorg_install()
{
	echo -e "${yellowf}Installing Minimal X....${reset}"
	sleep 5;
	emerge xorg-server xterm;
}

fluxbox_install()
{
	echo -e "${yellowf}Installing Window Manager - FLUXBOX....${reset}"
	sleep 5;
	USE="fontconfig truetype jpeg png " emerge gd
	USE="X bzip2 nls zlib doc gif jpeg mmx mp3 png tiff" emerge -av  imlib2
	emerge fluxbox eterm
	echo "exec startfluxbox" > ~/.xinitrc
}

misc_install()
{
	echo -e "${yellowf}Installing Mesa , Cairo, Conky....${reset}"
	sleep 5;

	revdep-rebuild 
	emerge xf86-video-intel mesa libdrm cairo libva
	emerge mesa-progs
	USE="X drm gallilium opengl" emerge  cairo
	USE="X" emerge  pango
	emerge firefox
	USE="X audacious curl hddtemp imlib iostats lua lua-cairo math rss truetype vim-syntax weather-metar weather-soap wifi" emerge
	conky
	emerge lm_sensors
	emerge hddtemp
	emerge feh
	fluxbog-generate_menu -is -dg

#wpsetters=feh fbsetbg /etc/splash/natural_gentoo/images/silent-1920x1200.jpg
}

start_script()
{
clear
echo -e "${boldon}${redf}Do you want to Install/Configure Gentoo ? [yes or no]:${reset}"
read ans
case $ans in  
	yes )
		echo "Agreed" 
		echo -e "${boldon}${redf}WARNING: HIGHLY RECOMMENDED TO TEST THIS SCRIPT ON Vmware/Virtualbox Environment prior to using it on Physical System${reset}"
		menu	
	;;
	no )

		echo "Not agreed, you can't proceed the installation";
		exit 1
 	;;
	*) 	echo "Invalid input"
 	;;
esac
}

menu()
{
while :
do
	echo -e "${boldon}${yellowf}Choose install section:${reset}"
	echo -e "${boldon}${redf}1. ALL (NOTE: Use only for new installs)${reset}"
	echo -e "${boldon}${greenf}2. Initialize Gentoo${reset}"
	echo -e "${boldon}${greenf}3. Sync Portage${reset}"
	echo -e "${boldon}${greenf}4. Download Latest Kernel and Genkernel${reset}"
	echo -e "${boldon}${greenf}5. Configure and Install Kernel${reset}"
	echo -e "${boldon}${greenf}6. Install basic tools${reset}"
	echo -e "${boldon}${redf}7. Install Grub (NOTE: Installs GRUB in /dev/sda , edit file: grub.conf.gentoo to change device !!)${reset}"
	echo -e "${boldon}${greenf}8. Install Splash Themes${reset}"
	echo -e "${boldon}${greenf}9. Install Minimal X${reset}"
	echo -e "${boldon}${greenf}10. Install Fluxbox${reset}"
	echo -e "${boldon}${yellowf}11. Exit${reset}"
echo -e "${boldon}${redf}Please enter option [1 - 11]${reset}"
read opt
case $opt in
        1) configure_gentoo;;
        2) init;;
        3) web_sync;;
        4) kernel_and_genkernel_download;;
        5) kernel_configure_and_install;;
        6) tools_install;;
        7) grub_install;;
        8) splash_install;;
        9) xorg_install;;
        10) fluxbox_install;;
        11) echo "Exit";
                exit 1;;
        *) echo "$opt is an invaild option. Please select option between 1-11 only";
                echo "Press [enter] key to continue. . .";
                read enterKey;;
esac
done
}

configure_gentoo()
{
	init
	web_sync
	kernel_download
	kernel_config
	kernel_install
	tools_install
	grub_install
	splash_install
	xorg_install
	fluxbox_install

echo -e "${redf}DONT FORGET TO CHANGE ROOT PASSWORD AFTER A NEW GENTOO INSTALL!!!"
echo -e "DONT FORGET TO CHANGE ROOT PASSWORD AFTER A NEW GENTOO INSTALL!!!${reset}"
}

start_script
sleep 2;
