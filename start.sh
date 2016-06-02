#!/bin/bash
set -e

if [ ! -f /etc/restyaboard/config.inc.php ]; then
  cp /usr/share/nginx/html/server/php/config.inc.php.back /etc/restyaboard/config.inc.php
fi
chmod -R a+w /usr/share/nginx/html/media /usr/share/nginx/html/client/img /usr/share/nginx/html/tmp/cache /etc/restyaboard/config.inc.php
ln -sf /etc/restyaboard/config.inc.php /usr/share/nginx/html/server/php/config.inc.php

sed -i "s/^.*'R_DB_HOST'.*$/define('R_DB_HOST', '${POSTGRES_PORT_5432_TCP_ADDR}');/g" /usr/share/nginx/html/server/php/config.inc.php
sed -i "s/^.*'R_DB_PORT'.*$/define('R_DB_PORT', '${POSTGRES_PORT_5432_TCP_PORT}');/g" /usr/share/nginx/html/server/php/config.inc.php
sed -i "s/^.*'R_DB_USER'.*$/define('R_DB_USER', '${POSTGRES_ENV_POSTGRES_USER}');/g" /usr/share/nginx/html/server/php/config.inc.php
sed -i "s/^.*'R_DB_PASSWORD'.*$/define('R_DB_PASSWORD', '${POSTGRES_ENV_POSTGRES_PASSWORD}');/g" /usr/share/nginx/html/server/php/config.inc.php
sed -i "s/^.*'R_DB_NAME'.*$/define('R_DB_NAME', 'restyaboard');/g" /usr/share/nginx/html/server/php/config.inc.php

export PGHOST=$POSTGRES_PORT_5432_TCP_ADDR
export PGPORT=$POSTGRES_PORT_5432_TCP_PORT
export PGUSER=$POSTGRES_ENV_POSTGRES_USER
export PGPASSWORD=$POSTGRES_ENV_POSTGRES_PASSWORD
set +e
while :
do
  psql -c "\q"
  if [ "$?" = 0 ]; then
    break
  fi
  sleep 1
done
psql -c "CREATE DATABASE restyaboard ENCODING 'UTF8'"
if [ "$?" = 0 ]; then
  psql -d restyaboard -f /usr/share/nginx/html/sql/restyaboard_with_empty_data.sql
fi
set -e

service postfix start
service php5-fpm start
service nginx start
service cron start

touch /var/log/nginx/access.log /var/log/nginx/error.log
exec tail -f /var/log/nginx/access.log /var/log/nginx/error.log
