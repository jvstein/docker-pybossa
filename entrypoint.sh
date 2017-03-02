#!/bin/sh

# POSTGRES_URL="postgresql://username:password@host/database"
if [ -z "$POSTGRES_URL" ]; then
    echo "One or more required variables are not set (POSTGRES_URL)"
    exit 1
fi

sed -i -e "s|{{POSTGRES_URL}}|$POSTGRES_URL|" \
       -e "s/{{REDIS_SENTINEL}}/$REDIS_SENTINEL/" \
       -e "s/{{REDIS_MASTER}}/$REDIS_MASTER/" /opt/pybossa/settings_local.py
sed -i -e "s|{{POSTGRES_URL}}|$POSTGRES_URL|" /opt/pybossa/alembic.ini

exec "$@"
