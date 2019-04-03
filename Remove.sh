#!/bin/sh

clear

osascript -e "tell application \"Terminal\" to set the font size of window 1 to 12"
osascript -e "tell application \"Terminal\" to set background color of window 1 to {1028, 12850, 65535}"
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to {65535, 65535, 65535}"

clear

printf '\n\n*****     Программное удаление поддержки Continuity для макинтош     ******\n'
printf '*****     C обновленным модулем Bluetooth до версии HCI 4.0+ c LE      ******\n'
printf '*****     Которая сделана посредством установки Lilu.kext с плагинами  ******\n'
printf '*****                          Версия 1.11b                            ******\n'

sleep 0.5

printf '\n    !!!   Ваша система '
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


printf '\n    !!!   board-id этого макинтоша = '
printf "$board"
printf '   !!!\n\n'

legal=0
case "$board" in

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
		sleep 3
		clear && printf '\e[3J'
		printf '\n    !!!   board-id этого макинтоша = '
		printf "$board"
		printf '   !!!\n\n'
		echo "Для этого мака патч программа не предназначена" 
		echo "Завершение программы. Выход\n"
		read -p "Для выхода нажмите любую клавишу" -n 1 -r
        clear
        osascript -e 'tell application "Terminal" to close first window' & exit
		exit 1
fi
 
echo "Проверка состояния системной защиты... "
csrset=`csrutil status | awk -F"status: " '{print $2}' | rev | cut -c 2- | rev`

if [[ "$csrset" != "disabled" ]]
	 then 
		clear && printf '\e[3J'
		printf '\n    !!!   Защита целостности системы включена     !!!\n\n'
		echo "    !!!    Продолжение удаления невозможно"
		echo "    !!!    Если защита включена удаление не сработает"
		echo "    !!!    Для отключения защиты загрузитесь в Recovery"
		echo "    !!!    Запустите утилиту терминала и выполните"
		echo "    !!!    команду csrutil disable"
		echo "    !!!    и после перезагрузки запустите программу еще раз"
		echo "    !!!    Завершение работа программы.Выход\n"
		read -p "Для выхода нажмите любую клавишу" -n 1 -r
        clear
        osascript -e 'tell application "Terminal" to close first window' & exit
		exit 1
fi
printf '\n'
printf '    !!! Защита целостности системы выключена\n\n'

sleep 3
printf '\e[3J'

kextset=0
#kextload=0
btframestat=0

#printf '\nПроверяем необходимость установки поддержки Continuity\n'
printf '\nПолучаем информацию о системе\n\n'
printf 'Состояние разрешения сценария Bluetooth для '
printf "$board"
printf ' \n'

if [ $continuity == 1 ]
	then
		btframestat=1
		printf '\n    !!!         Сценарий Continuity разрешен         !!!\n'
	else
		printf '\n    !!! Сценарий Continuity запрещен !!!\n'
fi



liluset=0
arptset=0
bt4leset=0
printf '\nПроверка установленных расширений ядра в /System/Library/Extensions/ \n\n'
if [  -f "/System/Library/Extensions/Lilu.kext/Contents/Info.plist" ]; then liluset=1; fi

#printf '\nВаш liluset = '
#printf "$liluset"
#printf '\n\n'

if [  -f "/System/Library/Extensions/AirportBrcmFixup.kext/Contents/Info.plist" ]; then arptset=1; fi

#printf '\nВаш arptset = '
#printf "$arptset"
#printf '\n\n'

if [  -f "/System/Library/Extensions/BT4LEContiunityFixup.kext/Contents/Info.plist" ]; then bt4leset=1; fi

#printf '\nВаш bt4leset = '
#printf "$bt4leset"
#printf '\n\n'

if [ $liluset == 1 ] || [ $arptset == 1 ] || [ $bt4leset == 1 ]; then kextset=1; fi
if [[ $kextset = 0 ]]; then echo "    !!!   Расширения для поддержки Continuity не установлены"; echo
	else
	echo "    !!!         Расширения  установлены.          !!! "
	echo
	
fi




if [ $kextset == 0 ] && [ $btframestat == 0 ]
	then
		sleep 3
		clear && printf '\e[3J'
		
		printf '   !!!\n\n'
		echo "У вас НЕ установлена поддержка Continuity"
		echo "Продолжение не имеет смысла.Выходим"
		
		sleep 1
		exit 1
fi
		echo "Для продолжения нажмите англ. литеру Y"
		echo "Для завершения любую другую клавишу"
		printf '\n\n'
               

read -p "Желаете продолжить удаление? (y/N) " -n 1 -r

if [[ ! $REPLY =~ ^[yY]$ ]]

then
    
    printf '\n\nМудрый выбор. Завершение  программы. Выход ... !\n'
    sleep 3
    
        clear
        osascript -e 'tell application "Terminal" to close first window' & exit
   
    exit 1

fi

sleep 0.3

printf '\n\n\n*****  Вы точно знаете что делаете!  *****\n\n'
printf '\nДля продолжения введите ваш пароль\n\n'



sudo printf '\n\n'
#printf '\nи сценарий поддержки handoff\n\n'



function ProgressBar {

let _progress=(${1}*100/${2}*100)/100
let _done=(${_progress}*4)/10
let _left=40-$_done

_fill=$(printf "%${_done}s")
_empty=$(printf "%${_left}s")

printf "\rВыполняется: ${_fill// /.}${_empty// / } ${_progress}%%"

}


_start=1

_end=100

cd $(dirname $0)

if [[ $kextset = 1 ]]
	then
	
number=1
ProgressBar ${number} ${_end}

sudo rm -R -f /System/Library/Extensions/Lilu.kext


number=30
ProgressBar ${number} ${_end}

sudo rm -R -f /System/Library/Extensions/AirportBrcmFixup.kext

number=50
ProgressBar ${number} ${_end}

sleep 0.2
#sudo rm -R -f /System/Library/Extensions/NightShiftUnlocker.kext

number=75
ProgressBar ${number} ${_end}

sudo rm -R -f /System/Library/Extensions/BT4LEContiunityFixup.kext

fi


if [[ $btframestat = 1 ]]
	then

number=85
ProgressBar ${number} ${_end}

cp /System/Library/Frameworks/IOBluetooth.framework/Versions/A/Resources/SystemParameters.plist .

number=90
ProgressBar ${number} ${_end}

plutil -replace  $board.ContinuitySupport  -bool NO SystemParameters.plist

number=95
ProgressBar ${number} ${_end}

sudo cp SystemParameters.plist /System/Library/Frameworks/IOBluetooth.framework/Versions/A/Resources/SystemParameters.plist

rm -f SystemParameters.plist

fi

number=100
ProgressBar ${number} ${_end}

printf '\n\n.   !!!    Расширения ядра удалены\n\n'

if [[ $btframestat == 1 ]]
	then
		echo "    !!!    Патч сценария Bluetooth для Continuity отменен\n\n"
fi

sleep 1

 

printf '\nОбновляем системный кэш.\n'
printf '\nВыполняется: \n'

while :;do printf '.\n' ;sleep 7;done &
trap "kill $!" EXIT 
sudo touch /System/Library/Extensions 2>/dev/null
sudo kextcache -u /  2>/dev/null
kill $!
wait $! 2>/dev/null
trap " " EXIT


printf '\n\nСистемный кэш обновлен\n'
sleep 1

printf '\n\nТаймаут для системного урегулирования\n\n'



_start=1

_end=100


for number in $(seq ${_start} ${_end})
do
sleep 0.1
ProgressBar ${number} ${_end}
done

if [[ $btframestat == 0 ]]
	then

printf '\n\nОбновляем кэш системных сценариев. Это занимает несколько минут\n'
sleep 1



printf '\nВыполняется: '
while :;do printf '.';sleep 3;done &
trap "kill $!" EXIT 
 sudo update_dyld_shared_cache -debug -force -root / 2>/dev/null
kill $!
wait $! 2>/dev/null
trap " " EXIT

printf '\n\nКэш системных сценариев обновлен\n\n'



printf '\nВсе операции завершены\n'
sleep 1

printf '\nНеобходимый таймаут перед перезагрузкой операционной системы\n'

printf '\nНажмте CTRL + C для прерывания если не хотите перезагружать сейчас\n\n'
sleep 5


_start=1

_end=100


for number in $(seq ${_start} ${_end})
do
sleep 0.3
ProgressBar ${number} ${_end}
done


sleep 1

fi

printf '\n\nПрограмма завершена. Инициирована перезагрузка. На HDD может занять пару минут.\n\n'


sudo reboot now

exit 1


