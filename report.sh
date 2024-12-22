#!/bin/bash

# Путь к логам или задачам для отчета
LOG_FILE="/var/log/syslog"
REPORT_FILE="/backups/task_report_$(date +'%Y-%m-%d').log"

# Генерация отчета
echo "Отчет по выполненным задачам для $(date)" > $REPORT_FILE
echo "===============================" >> $REPORT_FILE
echo "Вывод системного лога:" >> $REPORT_FILE
tail -n 50 $LOG_FILE >> $REPORT_FILE

# Отправка отчета на email
SUBJECT="Еженедельный отчет по задачам"
EMAIL="your-email@example.com"
mail -s "$SUBJECT" $EMAIL < $REPORT_FILE

# Очистка временного файла отчета
rm $REPORT_FILE
