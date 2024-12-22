#!/bin/bash

# Обновление системы и установка Samba
echo "Обновляем систему и устанавливаем Samba..."
sudo apt update
sudo apt install samba -y

# Создание резервной копии текущего конфигурационного файла
echo "Создаём резервную копию конфигурационного файла..."
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Настройка нового конфигурационного файла
echo "Настраиваем новый конфигурационный файл Samba..."
cat <<EOL | sudo tee /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   security = user

[Shared]
   path = /srv/samba/shared
   browseable = yes
   writable = yes
   guest ok = no
   create mask = 0775
   directory mask = 0775
EOL

# Создание директории для общего доступа
echo "Создаём директорию для общего доступа..."
sudo mkdir -p /srv/samba/shared
sudo chmod 775 /srv/samba/shared
sudo chown nobody:nogroup /srv/samba/shared

# Создание пользователя Samba
echo "Введите имя пользователя для Samba:"
read samba_user
sudo adduser --no-create-home --shell /bin/false "$samba_user"

echo "Установите пароль для Samba-пользователя $samba_user:"
sudo smbpasswd -a "$samba_user"

# Перезапуск службы Samba
echo "Перезапускаем службу Samba..."
sudo systemctl restart smbd
sudo systemctl enable smbd

# Проверка статуса службы Samba
echo "Проверка статуса службы Samba..."
sudo systemctl status smbd

echo "Настройка завершена! Папка '/srv/samba/shared' доступна для пользователя $samba_user."
