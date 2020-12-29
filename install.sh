#!/bin/bash

echo "Добавляем репозиторий Яндекса и обновляем"

read -p "Нажмите Enter для добавления репозитория Яндекса и обновить его?"

echo "1.добавление репозиториев ФСТЭК с8.1 и обновление системы"
apt-repo rm all
apt-repo add http://mirror.yandex.ru/altlinux/c8.1/branch/
## Добавим репозиторий I586 для Wine
echo "rpm http://mirror.yandex.ru/altlinux c8.1/branch/x86_64-i586 classic" >> /etc/apt/sources.list
apt-get update -y  > /dev/null 2>&1
apt-get upgrade -y  > /dev/null 2>&1

read -p "готово. нажмите Enter если хотите установить Хромиум-гост"

echo "2.Установка Хромиум-Гост и других необходимых пакетов"

apt-get install nano sane xsane git chromium-gost eepm i586-wine winetricks xfce4-default libxml2 libstdc++6 libgcrypt20 libgcrypt-devel libzstd libglade libglade-devel libncurses
jbig-utils libjbig-devel -y > /dev/null 2>&1

read -p "готово. нажмите Enter если хотите установить тему интерфейса"

echo "3.Установка темы интерфейса"

mkdir /root/repack && cd /root/repack 
wget https://ftp.lysator.liu.se/pub/opensuse/ports/aarch64/tumbleweed/repo/oss/noarch/mojave-gtk-theme-20200324-1.1.noarch.rpm > /dev/null 2>&1
epm repack /root/repack/*.rpm > /dev/null 2>&1
apt-get install /root/repack/*.rpm -y > /dev/null 2>&1
rm -rf /root/repack

read -p "готово. нажмите Enter если хотите установить тему иконок"
echo "4.Установка иконпака"
apt-get install icon-theme-Papirus -y > /dev/null 2>&1

echo "5.Добавление пользователя sudo"

read -p "готово. нажмите Enter если хотите установить добавить пользователя в sudoers"
echo "Введите имя пользователя и нажмите Enter для добавления пользователя в sudoers"
read username

echo $username "ALL=(ALL) ALL" >> /etc/sudoers 

read -p "готово. нажмите Enter если хотите изменить имя компьютера"
echo "Введите имя компьютера"
read compname
echo "6.Изменяем имя компьютера. требуется перезагрузка"
touch /etc/hostname
echo $compname > /etc/hostname 

#read -p "готово. теперь можете использовать sudo для своего пользователя. нажмите Enter если хотите установить zsh"
#su $username
#sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#exit

echo "7.Подключаем сетевой диск"

read -p "нажмите Enter если хотите подключить сетевой диск"
echo "Введите IP адрес и каталог сетевого диска, например 10.10.10.10/shares"
read netdisk
echo "Введите имя пользователя для подключения к сетевому диску"
read netuser
echo "Введите пароль пользователя для подключения к сетевому диску"
read netpass
touch /home/$username/.credentials
echo user=$netuser\npassword=$netpass >> /home/$username/.credentials
chown $username:$username /home/$username/.credentials && chmod 0777 /home/$username/.credentials
mkdir /home/$username/share
chown -R $username:$username /home/$username/share
chmod -R 0777 /home/$username/share
mount -t cifs //$netdisk /home/$username/share -o user=$netuser,password=$netpass

echo "//$netdisk/ /home/$username/share cifs credentials=/home/$username/.credentials,iocharset=utf8,file_mode=0777,dir_mode=0777 0 0" >> /etc/fstab

read -p "В домашнем каталоге пользователя создана папка share которая и является сетевым диском. Enter для продолжения"

read -p "Нажмите Enter если желаете настроить VNC"

echo "8.устанавливаем VNC клиент/сервер"

apt-get install x11vnc tigervnc -y > /dev/null 2>&1
echo  "Введите пароль для подключения VNC"
cd ~/
x11vnc -storepasswd /etc/x11vnc.pass

touch /lib/systemd/system/x11vnc.service
echo -e '[Unit]\nDescription=Start x11vnc at startup.\nAfter=multi-user.target\n[Service]\nType=simple\nExecStart=/usr/bin/x11vnc -rfbauth /etc/x11vnc.passwd -many -display :0 -no6 -rfbport 5901 -auth /var/run/lightdm/root/:0\n[Install]\nWantedBy=multi-user.target' >> /lib/systemd/system/x11vnc.service

systemctl daemon-reload
service x11vnc enable 
service x11vnc start

read -p "Нажмите Enter если желаете разрешить использование su и sudo  в доменной учетной записи"
echo "9.Включаем разрешение использовать su/sudo в доменной учетной записи"
control su public

read -p "Нажмите Enter если желаете включить подключение по ssh к данному компьютеру"
echo "10. Включение sshd-демона"
service sshd enable 
service sshd start

read -p "Нажмите Enter если желаете обновить дистрибутив и ядро"
apt-get update && apt-

read -p "Нажмите Enter если желаете установить Консультант Плюс"
echo "Введите сетевой пусть до папки Консультант Плюс. Напимер //10.0.0.10/cons"
mkdir /home/$username/veda
read consdisk
mount -t cifs //$consdisk /home/$username/veda -o user=$netuser,password=$netpass,uid=500,gid=500
echo "//$consdisk /home/$username/veda cifs username=$netuser,passwd=$netpass,uid=500,gid=500 0 0" >> /etc/fstab

echo "Для запуска Консультант Плюс от обычного пользователя выполните команду winetricks corefonts \n Затем выполните команду winecfg и перейдите во вкладку Диски. Добавьте новый диск и укажите на расположение каталога veda в домашней директории \n После чего перейдите cd ~/.wine/dosdevices/k\: (где к буква вашего сетевого диска) и выполните команду wine cons.exe /LINUX \n После этого в свойствах ярлыка на рабочем столе добавьте флаг /LINUX \n продолжение следует"
