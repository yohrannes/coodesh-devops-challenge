#!/bin/bash
## Fazer backup do tfstate dentro do bucket****
zip_file="/backup/log_backup_$(date +%F).zip"
zip -r "$zip_file" /root
if [ 5 -gt 0 ]; then
  find /backup -type f -mtime +5 -exec rm {} \;
fi
