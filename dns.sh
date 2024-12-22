#!/bin/bash

# Скрипт настройки DNS-сервера BIND на Debian 10

DOMAIN="kraskrit.ru"
IP="178.208.65.26"
ZONE_FILE="/etc/bind/db.$DOMAIN"

# Обновление пакетов и установка BIND
echo "Обновляем пакеты и устанавливаем BIND..."
apt update && apt install -y bind9 bind9utils bind9-doc dnsutils

# Настройка зоны
echo "Настраиваем зону для $DOMAIN..."
cat <<EOL >> /etc/bind/named.conf.local
zone "$DOMAIN" {
    type master;
    file "$ZONE_FILE";
};
EOL

# Создание файла зоны
echo "Создаем файл зоны $ZONE_FILE..."
cat <<EOL > $ZONE_FILE
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN. admin.$DOMAIN. (
                        2023122201 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

; Основные записи
@       IN      NS      ns1.$DOMAIN.

; A-записи
ns1     IN      A       $IP
@       IN      A       $IP

; Прочие записи
www     IN      A       $IP
EOL

# Проверка конфигурации
echo "Проверяем конфигурацию BIND..."
named-checkconf || { echo "Ошибка в конфигурации BIND!"; exit 1; }
named-checkzone $DOMAIN $ZONE_FILE || { echo "Ошибка в зоне $DOMAIN!"; exit 1; }

# Перезапуск службы BIND
echo "Перезапускаем службу BIND..."
systemctl restart bind9
systemctl enable bind9

# Проверка работы DNS
echo "Проверяем DNS-запросы для $DOMAIN..."
dig @localhost $DOMAIN

echo "Настройка завершена. Если команда dig вернула правильный IP ($IP), то сервер работает."
