#!/bin/bash

# Переменные
SHARE_NAME="share"
SHARE_PATH="/srv/samba/$SHARE_NAME"
GROUP_NAME="smbgroup"
USERS=("user1" "user2")

# Установка Samba
echo "Устанавливаем Samba..."
sudo apt update
sudo apt install -y samba 

# Создание группы
echo "Создаем группу $GROUP_NAME..."
sudo groupadd $GROUP_NAME

# Создание пользователей и добавление в группу
for USER in "${USERS[@]}"; do
    echo "Создаем пользователя $USER..."
    sudo useradd $USER -m -G $GROUP_NAME
    echo "Устанавливаем пароль для $USER..."
    echo "$USER:password" | sudo chpasswd
    echo "Добавляем пользователя $USER в Samba..."
    sudo smbpasswd -a $USER
    sudo smbpasswd -e $USER
done

# Создание папки для шары
echo "Создаем папку для шары $SHARE_PATH..."
sudo mkdir -p $SHARE_PATH

# Настройка разрешений для папки (только чтение)
echo "Настроим разрешения на папку..."
sudo chown root:$GROUP_NAME $SHARE_PATH
sudo chmod 550 $SHARE_PATH

# Настройка Samba
echo "Настроим Samba для расшаривания папки..."
sudo bash -c "cat >> /etc/samba/smb.conf <<EOL

[$SHARE_NAME]
   path = $SHARE_PATH
   valid users = @$GROUP_NAME
   read only = yes
   browsable = yes
   guest ok = no
EOL"

# Перезапуск Samba для применения изменений
echo "Перезапускаем Samba..."
sudo systemctl restart smbd

# Завершение
echo "Все настроено."
