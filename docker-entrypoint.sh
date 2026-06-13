#!/bin/sh
# Generates /srv/config.lua from config.lua.dist + environment variables on
# every container start, then imports schema.sql into MySQL on first run.
# See DEPLOY.md for the full list of environment variables.
set -e

cd /srv

cp config.lua.dist config.lua

cat >> config.lua <<EOF

-- ---------------------------------------------------------------------
-- Environment overrides (docker-entrypoint.sh). Lua re-assignment wins,
-- so these replace the defaults copied from config.lua.dist above.
-- ---------------------------------------------------------------------
mysqlHost = "${MYSQL_HOST:-127.0.0.1}"
mysqlUser = "${MYSQL_USER:-forgottenserver}"
mysqlPass = "${MYSQL_PASSWORD:-}"
mysqlDatabase = "${MYSQL_DATABASE:-forgottenserver}"
mysqlPort = ${MYSQL_PORT:-3306}
ip = "${SERVER_IP:-127.0.0.1}"
bindOnlyGlobalAddress = false
serverName = "${SERVER_NAME:-OldSchool Campaign}"
worldType = "${WORLD_TYPE:-pvp}"
EOF

MYSQL_ARGS="-h ${MYSQL_HOST:-127.0.0.1} -P ${MYSQL_PORT:-3306} -u ${MYSQL_USER:-forgottenserver}"
if [ -n "$MYSQL_PASSWORD" ]; then
	MYSQL_ARGS="$MYSQL_ARGS -p$MYSQL_PASSWORD"
fi

if ! mysql $MYSQL_ARGS "${MYSQL_DATABASE:-forgottenserver}" -e "SELECT 1 FROM server_config LIMIT 1" >/dev/null 2>&1; then
	echo "[docker-entrypoint] Empty database detected, importing schema.sql..."
	mysql $MYSQL_ARGS "${MYSQL_DATABASE:-forgottenserver}" < schema.sql
fi

exec /bin/tfs
