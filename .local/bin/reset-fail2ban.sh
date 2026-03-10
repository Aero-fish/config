#!/bin/bash
set -e
[ "${UID}" -eq 0 ] || exec sudo "$0" "$@"

systemctl stop fail2ban
truncate -s 0 /var/log/fail2ban/fail2ban.log
rm /var/lib/fail2ban/fail2ban.sqlite3
systemctl start fail2ban
