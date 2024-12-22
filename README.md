sudo mkdir -p /backups
sudo chmod 700 /backups

wget https://raw.githubusercontent.com/kir450/pm/main/backup.sh
sudo chmod +x backup.sh

crontab -e
*/10 * * * * /usr/backup.sh


Проверка скрипта вручную: 
sudo /usr/backup.sh

Проверка логов:
cat /backups/backup.log

Проверка работы cron:
crontab -l

