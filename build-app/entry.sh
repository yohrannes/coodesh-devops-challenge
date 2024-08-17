#!/bin/sh
# Rodando aplicação
python3 /root/app.py # &
# Rodar cron jobs caso necessário
/usr/sbin/crond -f -l 8
