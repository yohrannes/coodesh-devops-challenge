#!/bin/sh

# Run aplication
python3 /root/app.py # &
#uwsgi --http-socket :9090 --plugin python --wsgi-file foobar.py
# Run cron jobs
/usr/sbin/crond -f -l 8
