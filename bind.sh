#!/bin/bash

# Установка пакета BIND (DNS-сервер)
echo "Устанавливаем BIND..."
sudo apt update
sudo apt install bind9 -y

# Резервная копия текущих конфигурационных файлов
echo "Создаём резервную копию конфигурации..."
sudo cp /etc/bind/named.conf /etc/bind/named.conf.backup
sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup

# Настройка зоны для домена kraskrit.ru
echo "Настраиваем зону для домена kraskrit.ru..."

cat <<EOL | sudo tee -a /etc/bind/named.conf.local
zone "kraskrit.ru" {
    type master;
    file "/etc/bind/db.kraskrit.ru";
};
EOL

# Создание зоны для домена
echo "Создаём зону db.kraskrit.ru..."

sudo cp /etc/bind/db.local /etc/bind/db.kraskrit.ru

sudo cat <<EOL | sudo tee /etc/bind/db.kraskrit.ru
\$TTL    604800
@       IN      SOA     ns.kraskrit.ru. admin.kraskrit.ru. (
                              2         ; Serial
                          604800         ; Refresh
                           86400         ; Retry
                         2419200         ; Expire
                          604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.kraskrit.ru.
@       IN      A       178.208.65.26
ns      IN      A       178.208.65.26
www     IN      A       178.208.65.26
mail    IN      A       178.208.65.26
EOL

# Проверка конфигурации
echo "Проверяем конфигурацию BIND..."
sudo named-checkconf
sudo named-checkzone kraskrit.ru /etc/bind/db.kraskrit.ru

# Перезапуск BIND
echo "Перезапускаем службу BIND..."
sudo systemctl restart bind9
sudo systemctl enable bind9

# Проверка работы DNS
echo "Проверяем работу DNS для kraskrit.ru..."
dig @localhost kraskrit.ru
