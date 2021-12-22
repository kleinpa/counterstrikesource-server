#!/bin/bash -ue

[ -z "${CSS_ADMIN}" ] || echo "${CSS_ADMIN} \"99:z\"" > /opt/game/cstrike/addons/sourcemod/configs/admins_simple.ini

[ -z "${CSS_MOTD}" ] || echo "${CSS_MOTD}" > /opt/game/cstrike/motd.txt

# Generate mapcycle here to cut down on image build time and space usage.
ls /opt/game/cstrike/maps/*.bsp | grep -v test | sed -e 's/.*\/\([^\/]*\).bsp/\1/' > /opt/game/cstrike/cfg/mapcycle.txt

# Touch this file to workaround an issue in sourcemod
touch /opt/game/cstrike/addons/sourcemod/configs/maplists.cfg

# Hack to allow spaces in server name
echo "hostname \"$CSS_HOSTNAME\"" >> /opt/game/cstrike/cfg/server.cfg

# Call srcds_linux instead of srcds_run to avoid restart logic.
LD_LIBRARY_PATH="/opt/game:/opt/game/bin:${LD_LIBRARY_PATH:-}" /opt/game/srcds_linux \
    -game cstrike \
    -port "$CSS_PORT" \
    -strictbindport \
    -usercon \
    +ip 0.0.0.0 \
    +map "$CSS_MAP" \
    +hostname "$CSS_HOSTNAME" \
    +rcon_password "$RCON_PASSWORD" \
    +sv_password "$CSS_PASSWORD" \
    +sm_auth_by_steam_group_group_id "$STEAM_GROUP_ID" \
    +sm_auth_by_steam_group_steam_key "$STEAM_API_KEY"
