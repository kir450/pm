sudo mkdir -p /backups
sudo chmod 700 /backups

wget https://raw.githubusercontent.com/kir450/pm/main/backup.sh
sudo chmod +x backup.sh

Открытие и редактирование crontab
crontab -e
*/10 * * * * /usr/backup.sh


Проверка скрипта вручную: 
sudo /usr/backup.sh

Проверка логов:
cat /backups/backup.log

Проверка работы cron:
crontab -l

Синтаксис записи в crontab:
* * * * * /path/to/command
- - - - -
| | | | |
| | | | +---- День недели (0 - 7) (воскресенье = 0 или 7)
| | | +------ Месяц (1 - 12)
| | +-------- День месяца (1 - 31)
| +---------- Час (0 - 23)
+------------ Минута (0 - 59)

Перезагрузить cron:
sudo systemctl restart cron

Регулярное обновление пакетов:
0 3 * * 1 sudo apt update: Запуск в 3:00 каждое понедельник.
Очистка временных файлов:
0 4 * * * sudo rm -rf /tmp/*: Запуск в 4:00 каждый день.


Проверить логи cron
sudo grep CRON /var/log/syslog
В реальном времени:
sudo tail -f /var/log/syslog | grep CRON
Перенаправить вывод в лог-файл:
0 2 * * * /usr/local/bin/backup.sh >> /backups/backup.log 2>&1

Добавьте строку для выполнения скрипта каждую неделю в понедельник в 8:00 утра:
0 8 * * 1 /usr/report.sh

sudo apt install -y postfix mailutils
Интернет-сайт
example.com
