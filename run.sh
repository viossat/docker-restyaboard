#!/bin/bash
set -eu

export DB_HOST=${DB_HOST:-${POSTGRES_PORT_5432_TCP_ADDR:-$DB_HOST}}
export DB_PORT=${DB_PORT:-${POSTGRES_PORT_5432_TCP_PORT:-5432}}
export DB_USER=${DB_USER:-${POSTGRES_ENV_POSTGRES_USER:-$DB_USER}}
export DB_PASSWORD=${DB_PASSWORD:-${POSTGRES_ENV_POSTGRES_PASSWORD:-$DB_USER}}
export DB_NAME=${DB_NAME:-${POSTGRES_ENV_POSTGRES_DB:-restyaboard}}

if [ ! -f /etc/restyaboard/config.inc.php ]; then
  cp /usr/share/nginx/html/server/php/config.inc.php.back /etc/restyaboard/config.inc.php
fi
chmod -R a+w /usr/share/nginx/html/media /usr/share/nginx/html/client/img /usr/share/nginx/html/tmp/cache /etc/restyaboard/config.inc.php
ln -sf /etc/restyaboard/config.inc.php /usr/share/nginx/html/server/php/config.inc.php

sed -i "s/^.*'R_DB_HOST'.*$/define('R_DB_HOST', '${DB_HOST}');/g" /usr/share/nginx/html/server/php/config.inc.php
sed -i "s/^.*'R_DB_PORT'.*$/define('R_DB_PORT', '${DB_PORT}');/g" /usr/share/nginx/html/server/php/config.inc.php
sed -i "s/^.*'R_DB_USER'.*$/define('R_DB_USER', '${DB_USER}');/g" /usr/share/nginx/html/server/php/config.inc.php
sed -i "s/^.*'R_DB_PASSWORD'.*$/define('R_DB_PASSWORD', '${DB_PASSWORD}');/g" /usr/share/nginx/html/server/php/config.inc.php
sed -i "s/^.*'R_DB_NAME'.*$/define('R_DB_NAME', '${DB_NAME}');/g" /usr/share/nginx/html/server/php/config.inc.php

export PGHOST=$DB_HOST
export PGPORT=$DB_PORT
export PGUSER=$DB_USER
export PGPASSWORD=$DB_PASSWORD

set +e
while :
do
  psql -d template1 -c "\q"
  if [ "$?" = 0 ]; then
    break
  fi
  sleep 1
done

create_database() {
  psql -d template1 -c "CREATE DATABASE $DB_NAME ENCODING 'UTF8'"
  psql -d $DB_NAME -f /usr/share/nginx/html/sql/restyaboard_with_empty_data.sql
}

psql -d $DB_NAME -c "\q"
if [ "$?" = 0 ]; then
  N_TABLES=$(psql -d $DB_NAME -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_catalog = '$DB_NAME' AND table_schema = 'public'" -A | sed "2q;d")
  if [ "$N_TABLES" = "0" ]; then
    dropdb $DB_NAME
    create_database
  fi
else
  create_database
fi
set -e

service postfix start
service php5-fpm start
service nginx start
service cron start

chown -R www-data /var/log/nginx && chmod -R u+rw /var/log/nginx
exec tail -F -n 0 /var/log/nginx/access.log /var/log/nginx/error.log 2> /dev/null
