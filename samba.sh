#!/bin/bash

# Проверка выполнения от имени root
if [ "$EUID" -ne 0 ]; then
    echo "Запустите скрипт от имени root."
    exit 1
fi

# 1. Установка пакета Samba
echo "\nУстановка пакета Samba..."
apt update && apt install -y samba
if [ $? -ne 0 ]; then
    echo "Ошибка установки Samba."
    exit 1
fi

# 2. Настройка конфигурационного файла
CONFIG_FILE="/etc/samba/smb.conf"
BACKUP_FILE="/etc/samba/smb.conf.backup"

# Резервное копирование текущего конфигурационного файла
if [ -f "$CONFIG_FILE" ]; then
    echo "\nСоздание резервной копии $CONFIG_FILE..."
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Резервная копия создана: $BACKUP_FILE"
fi

# Создание новой конфигурации
SHARED_FOLDER="/srv/samba/shared"
GROUP_NAME="smbusers"

mkdir -p "$SHARED_FOLDER"
groupadd -f "$GROUP_NAME"
chown -R root:"$GROUP_NAME" "$SHARED_FOLDER"
chmod -R 0770 "$SHARED_FOLDER"

cat > "$CONFIG_FILE" <<EOL
[global]
   workgroup = WORKGROUP
   security = user
   map to guest = bad user

[shared]
   comment = Shared Folder
   path = $SHARED_FOLDER
   browseable = yes
   read only = no
   guest ok = no
   valid users = @$GROUP_NAME
   create mask = 0660
   directory mask = 0770
EOL

echo "\nКонфигурационный файл $CONFIG_FILE обновлен."

# 3. Создание пользователя Samba
read -p "Введите имя пользователя для Samba: " SMB_USER
if id "$SMB_USER" &>/dev/null; then
    echo "Пользователь $SMB_USER уже существует."
else
    adduser "$SMB_USER" --disabled-password
    echo "Пользователь $SMB_USER создан."
fi

usermod -aG "$GROUP_NAME" "$SMB_USER"
echo -e "\nУстановка пароля для Samba-пользователя $SMB_USER..."
smbpasswd -a "$SMB_USER"
smbpasswd -e "$SMB_USER"

# 4. Перезапуск службы Samba
echo "\nПерезапуск службы Samba..."
systemctl restart smbd
if [ $? -ne 0 ]; then
    echo "Ошибка запуска Samba."
    exit 1
fi

# Проверка статуса службы
systemctl status smbd | grep Active

# Завершение
echo "\nНастройка Samba завершена. Общая папка доступна по адресу: \\\<IP-адрес-сервера>\\shared"
echo "\nУбедитесь, что Samba работает и устройство в сети может получить доступ к папке."
