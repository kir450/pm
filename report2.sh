#!/bin/bash

# Системная переменная с текущей датой
data=$(date +%d.%m.%Y-%H:%M:%S)

# Создание директории с текущей датой/временем
mkdir /var/backup/$data

# Копирование настроек frr
cp -r /etc/frr /var/backup/$data

# Копирование настроек nftables
cp -r /etc/nftables /var/backup/$data

# Копирование настроек сетевых интерфейсов
cp -r /etc/NetworkManager/system-connections /var/backup/$data

#Копирование настроек DHCP
cp -r /etc/dhcp /var/backup/$data

#Переход в директорию
cd /var/backup

# Архивируем
tar czfv "./$data.tar.gz" ./$data

# Удаляем временную директорию
rm -r /var/backup/$data
