#!/bin/sh

clear && printf '\e[3J'

printf '\n\n*****   This program enables Continuity support for the Mac   ******\n'
printf '*****   By installing Lilu.kext with plugins            ******\n'
printf '*****   If you have installed the Bluetooth 4.0+ LE USB dongle    ******\n'
printf '*****                        Version 1.4                          ******\n'

sleep 0.5

printf '\n    !!!   Your system '
printf "`sw_vers -productName`"
printf ': '; printf "`sw_vers -productVersion`" 
printf '('
printf "`sw_vers -buildVersion`"
printf ') '
printf '  !!!\n'


board=`ioreg -lp IOService | grep board-id | awk -F"<" '{print $2}' | cut -c 2- | rev | cut -c 3- | rev`

scontinuity=`defaults read /System/Library/Frameworks/IOBluetooth.framework/Versions/A/Resources/SystemParameters.plist | grep -A 1 "$board" | grep ContinuitySupport`

#printf '\nВаш scontinuity = '
#printf "$scontinuity"
#printf '\n\n'

continuity=`echo ${scontinuity//[^0-1]/}`


printf '\n    !!!   This MAC board-id - '
printf "$board"
printf '   !!!\n\n'

legal=0
case "$board" in

"Mac-F22C8AC8" ) legal=1;;
"Mac-4BC72D62AD45599E" ) legal=1;;
"Mac-742912EFDBEE19B3" ) legal=1;;
"Mac-7BA5B2794B2CDB12" ) legal=1;;
"Mac-8ED6AF5B48C039E1" ) legal=1;;
"Mac-942452F5819B1C1B" ) legal=1;;
"Mac-942459F5819B171B" ) legal=1;;
"Mac-94245A3940C91C80" ) legal=1;;
"Mac-94245B3640C91C81" ) legal=1;;
"Mac-942B59F58194171B" ) legal=1;;
"Mac-942B5BF58194151B" ) legal=1;;
"Mac-942C5DF58193131B" ) legal=1;;
"Mac-C08A6BB70A942AC2" ) legal=1;;
"Mac-F2208EC8" ) legal=1;;
"Mac-F2218EA9" ) legal=1;;
"Mac-F2218EC8" ) legal=1;;
"Mac-F2218FA9" ) legal=1;;
"Mac-F2218FC8" ) legal=1;;
"Mac-F221BEC8" ) legal=1;;
"Mac-F221DCC8" ) legal=1;;
"Mac-F222BEC8" ) legal=1;;
"Mac-F2238AC8" ) legal=1;;
"Mac-F2238BAE" ) legal=1;;
"Mac-F22586C8" ) legal=1;;
"Mac-F22587A1" ) legal=1;;
"Mac-F22587C8" ) legal=1;;
"Mac-F22589C8" ) legal=1;;
"Mac-F2268AC8" ) legal=1;;
"Mac-F2268CC8" ) legal=1;;
"Mac-F2268DAE" ) legal=1;;
"Mac-F2268DC8" ) legal=1;;
"Mac-F2268EC8" ) legal=1;;
"Mac-F226BEC8" ) legal=1;;
"Mac-F22788AA" ) legal=1;;
"Mac-F227BEC8" ) legal=1;;
"Mac-F22C86C8" ) legal=1;;
"Mac-F22C89C8" ) legal=1;;
"Mac-F22C8AC8" ) legal=1;;
"Mac-F42C86C8" ) legal=1;;
"Mac-F42C89C8" ) legal=1;;
"Mac-F42C8CC8" ) legal=1;;
"Mac-F42D86A9" ) legal=1;;
"Mac-F42D86C8" ) legal=1;;
"Mac-F42D88C8" ) legal=1;;
"Mac-F42D89A9" ) legal=1;;
"Mac-F42D89C8" ) legal=1;;

esac

if [[ $legal = 0 ]] 
	then 
		echo
		echo "For this mac the patch is impossible or not required." 
		echo "End of program. Exit"
		echo
		echo
		sleep 1
		exit 1
fi
 
echo "Checking the status of system protection "
csrset=`csrutil status | awk -F"status: " '{print $2}' | rev | cut -c 2- | rev`

if [[ "$csrset" != "disabled" ]]
	 then 
		printf '\n    !!!   System Integrity Protection enabled     !!!\n\n'
		echo "    !!!    Cannot continue installation"
		echo "    !!!    If protection is enabled the patch will not work."
		echo "    !!!    To disable protection, boot into Recovery"
        echo "    !!!    Or from installation media"
		echo "    !!!    Run the terminal utility and execute"
		echo "    !!!    csrutil disable command"
		echo "    !!!    and after reboot, run this program again"
		echo "    !!!    End of program. Exit"
		printf '\n\n\n\n'
		exit 1
fi
printf '\n'
printf '    !!! System Integrity Protection Off - OK !!!\n\n'

kextset=0
#kextload=0
btframestat=0

#printf '\nПроверяем необходимость установки поддержки Continuity\n'
printf '\nGet information about the system\n\n'
printf 'Bluetooth framework whitelist status '
printf "$board"
printf ' \n'

if [ $continuity == 1 ]
	then
		btframestat=1
		printf '\n    !!!         Continuity support enabled         !!!\n'
	else
		printf '\n    !!! Continuity support disabled, patch required !!!\n'
fi



liluset=0
arptset=0
#bt4leset=0
printf '\nCheck for installed kernel extensions in /System/Library/Extensions/ \n\n'
if [  -f "/System/Library/Extensions/Lilu.kext/Contents/Info.plist" ]; then liluset=1; fi

#printf '\nВаш liluset = '
#printf "$liluset"
#printf '\n\n'

if [  -f "/System/Library/Extensions/AirportBrcmFixup.kext/Contents/Info.plist" ]; then arptset=1; fi

#printf '\nВаш arptset = '
#printf "$arptset"
#printf '\n\n'

#if [  -f "/System/Library/Extensions/BT4LEContiunityFixup.kext/Contents/Info.plist" ]; then bt4leset=1; fi

#printf '\nВаш bt4leset = '
#printf "$bt4leset"
#printf '\n\n'

if [ $liluset == 1 ] && [ $arptset == 1 ]; then kextset=1; fi
if [[ $kextset = 0 ]]; then echo "    !!!   Kernel extensions to support Continuity not installed"; echo
	else
	echo "    !!!         Kernel extensions to support Continuity installed          !!! "
	echo
	echo "Check for kernel extension versions ..."

	sliluver=`plutil -p /System/Library/Extensions/Lilu.kext/Contents/Info.plist | grep CFBundleVersion | awk -F"=> " '{print $2}' | cut -c 2- | rev | cut -c 2- | rev`
	sairportver=`plutil -p /System/Library/Extensions/AirportBrcmFixup.kext/Contents/Info.plist | grep CFBundleVersion | awk -F"=> " '{print $2}' | cut -c 2- | rev | cut -c 2- | rev`
#	sbt4lever=`plutil -p /System/Library/Extensions/BT4LEContiunityFixup.kext/Contents/Info.plist | grep CFBundleVersion | awk -F"=> " '{print $2}' | cut -c 2- | rev | cut -c 2- | rev`

cd $(dirname $0)
	gliluver=`plutil -p Other/Lilu.kext/Contents/Info.plist | grep CFBundleVersion | awk -F"=> " '{print $2}' | cut -c 2- | rev | cut -c 2- | rev`
	gairportver=`plutil -p Other/AirportBrcmFixup.kext/Contents/Info.plist | grep CFBundleVersion | awk -F"=> " '{print $2}' | cut -c 2- | rev | cut -c 2- | rev`
#	gbt4lever=`plutil -p Other/BT4LEContiunityFixup.kext/Contents/Info.plist | grep CFBundleVersion | awk -F"=> " '{print $2}' | cut -c 2- | rev | cut -c 2- | rev`

printf '\n !!! installed Lilu.kext - '
printf "$sliluver"
printf ' , is being installed - '
printf "$gliluver"
printf '\n'


printf ' !!! installed AirportBrcmFixup.kext - '
printf "$sairportver"
printf ' , is being installed - '
printf "$gairportver"
printf '\n'

#printf ' !!! Установлен BT4LEContiunityFixup.kext - '
#printf "$sbt4lever"
#printf ' , устанавливается - '
#printf "$gbt4lever"
#printf '\n\n'


fi



#liluver=0
#arptver=0
#bt4lever=0

#printf '\nПроверка загружены ли расширения ядра в память  \n\n'
#liluver=`kextstat | grep as.vit9696.Lilu | awk -F"as.vit9696.Lilu " '{print $2}' | cut -c 2- | rev | awk -F ")" '{print $2}' | rev`
#arptver=`kextstat | grep as.lvs1974.BT4LEContiunityFixup  | awk -F"as.lvs1974.BT4LEContiunityFixup " '{print $2}' | cut -c 2- | rev | awk -F ")" '{print $2}' | rev`
#bt4lever=`kextstat | grep as.lvs1974.AirportBrcmFixup  | awk -F"as.lvs1974.AirportBrcmFixup " '{print $2}' | cut -c 2- | rev | awk -F ")" '{print $2}' | rev`

printf '\n'

if [ $kextset == 1 ] && [ $btframestat == 1 ]
	then
		echo "It seems you already have Continuity support installed"
		echo "Continue if you want to upgrade or reinstall the kernel extensions"
fi
		echo "To continue, press the English letter Y"
		echo "To end the program any other key"
		printf '\n\n'
               

read -p "Would you like to continue the installation? (y/N) " -n 1 -r

if [[ ! $REPLY =~ ^[yY]$ ]]

then
    
    printf '\n\nWise choice. The End of the program. Exit ... !\n'
    sleep 2
   
    exit 1

fi

sleep 0.3

printf '\n\n\n*****  You know exactly what you are doing!  *****\n\n'
printf '\nEnter your password to continue\n\n'



sudo printf '\n\n'
#printf '\nи сценарий поддержки handoff\n\n'



function ProgressBar {

let _progress=(${1}*100/${2}*100)/100
let _done=(${_progress}*4)/10
let _left=40-$_done

_fill=$(printf "%${_done}s")
_empty=$(printf "%${_left}s")

printf "\rRunning: ${_fill// /.}${_empty// / } ${_progress}%%"

}


_start=1

_end=100

cd $(dirname $0)

if [[ $kextset = 1 ]]
	then
	
number=1
ProgressBar ${number} ${_end}

sudo rm -R -f /System/Library/Extensions/Lilu.kext


number=5
ProgressBar ${number} ${_end}

sudo rm -R -f /System/Library/Extensions/AirportBrcmFixup.kext

number=10
ProgressBar ${number} ${_end}

#sudo rm -R -f /System/Library/Extensions/NightShiftUnlocker.kext

number=14
ProgressBar ${number} ${_end}

#sudo rm -R -f /System/Library/Extensions/BT4LEContiunityFixup.kext
sleep 0.1

fi

number=18
ProgressBar ${number} ${_end}
sudo cp -R Other/Lilu.kext /System/Library/Extensions/

number=21
ProgressBar ${number} ${_end}

sudo chown -R 0:0 /System/Library/Extensions/Lilu.kext

number=25
ProgressBar ${number} ${_end}

sudo chmod -R 755 /System/Library/Extensions/Lilu.kext

number=30
ProgressBar ${number} ${_end}


#sudo cp -R Other/NightShiftUnlocker.kext /System/Library/Extensions/

number=35
ProgressBar ${number} ${_end}

#sudo chown -R 0:0 /System/Library/Extensions/NightShiftUnlocker.kext

number=40
ProgressBar ${number} ${_end}

#sudo chmod -R 755  /System/Library/Extensions/NightShiftUnlocker.kext

number=45
ProgressBar ${number} ${_end}

#sudo cp -R Other/BT4LEContiunityFixup.kext /System/Library/Extensions/
sleep 0.1

number=50
ProgressBar ${number} ${_end}

#sudo chown -R 0:0 /System/Library/Extensions/BT4LEContiunityFixup.kext
sleep 0.1

number=55
ProgressBar ${number} ${_end}

#sudo chmod -R 755 /System/Library/Extensions/BT4LEContiunityFixup.kext
sleep 0.1

number=60
ProgressBar ${number} ${_end}

sleep 0.2

number=65
ProgressBar ${number} ${_end}

sleep 0.2

number=70
ProgressBar ${number} ${_end}

sudo cp -R Other/AirportBrcmFixup.kext /System/Library/Extensions/

number=75
ProgressBar ${number} ${_end}

sudo chown -R 0:0 /System/Library/Extensions/AirportBrcmFixup.kext

number=80
ProgressBar ${number} ${_end}

sudo chmod -R 755 /System/Library/Extensions/AirportBrcmFixup.kext

if [[ $btframestat == 0 ]]
	then

number=85
ProgressBar ${number} ${_end}

cp /System/Library/Frameworks/IOBluetooth.framework/Versions/A/Resources/SystemParameters.plist .

number=90
ProgressBar ${number} ${_end}

plutil -replace  $board.ContinuitySupport  -bool YES SystemParameters.plist

number=95
ProgressBar ${number} ${_end}

sudo cp SystemParameters.plist /System/Library/Frameworks/IOBluetooth.framework/Versions/A/Resources/SystemParameters.plist

rm -f SystemParameters.plist

fi

number=100
ProgressBar ${number} ${_end}

printf '\n\n.   !!!    Kernel Extensions Installed or Updated\n\n'

if [[ $btframestat == 0 ]]
	then
		echo "    !!!    Bluetooth whitelist patch for Continuity is made"
fi

sleep 1



printf '\nWe update the system cache.\n'
printf '\nProcessing: \n'

while :;do printf '.\n' ;sleep 7;done &
trap "kill $!" EXIT 
sudo touch /System/Library/Extensions 2>/dev/null
sudo kextcache -u /  2>/dev/null
kill $!
wait $! 2>/dev/null
trap " " EXIT


printf '\n\nKernel kexts cache updated\n'
sleep 1

printf '\n\nTimeout for system setting\n\n'



_start=1

_end=100


for number in $(seq ${_start} ${_end})
do
sleep 0.1
ProgressBar ${number} ${_end}
done

if [[ $btframestat == 0 ]]
	then

printf '\n\nupdate the system frameworks cache. It takes a few minutes\n'
sleep 1



printf '\nProcessing: '
while :;do printf '.';sleep 3;done &
trap "kill $!" EXIT 
 sudo update_dyld_shared_cache -debug -force -root / 2>/dev/null
kill $!
wait $! 2>/dev/null
trap " " EXIT

printf '\n\nSystem Frameworks Cache Updated\n\n'



printf '\nAll operations completed\n'
sleep 1

printf '\nRequired timeout before rebooting the operating system\n'

printf '\nPress CTRL + C to brake if you do not want to restart now\n\n'
sleep 1


_start=1

_end=100


for number in $(seq ${_start} ${_end})
do
sleep 0.3
ProgressBar ${number} ${_end}
done


sleep 1

fi

printf '\n\nThe program is complete. Initiated reboot. It may takes a couple of minutes.\n\n'


sudo reboot now

exit 1


