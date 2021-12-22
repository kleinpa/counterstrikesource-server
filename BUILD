load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_layer", "container_push")
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_extract")

#
# Build Maps Layer
#

container_image(
    name = "maps_container",
    base = "@ubuntu//image",
    directory = "/opt/game/cstrike",
    tars = [
        "@maps//file",
    ],
)

container_run_and_extract(
    name = "maps",
    commands = [
        "cd /opt/game/cstrike",
        "./make_bz2_files.sh",
        "rm *.sh *.md *license",
        "chown -R nobody:root /opt",
        "tar -czvf /archive.tar.gz /opt",
    ],
    extract_file = "/archive.tar.gz",
    image = ":maps_container.tar",
)

#
# Build Sourcemod Layer
#

container_image(
    name = "sourcemod_container",
    base = "@ubuntu//image",
    directory = "/opt/game/cstrike",
    tars = [
        "@metamod//file",
        "@sourcemod//file",
    ],
)

container_run_and_extract(
    name = "sourcemod",
    commands = [
        "cd /opt/game/cstrike/addons/sourcemod/plugins",
        "mv basevotes.smx disabled/basevotes.smx",
        "mv funcommands.smx disabled/funcommands.smx",
        "mv funvotes.smx disabled/funvotes.smx",
        "mv playercommands.smx disabled/playercommands.smx",
        "mv disabled/mapchooser.smx mapchooser.smx",
        "mv disabled/rockthevote.smx rockthevote.smx",
        "mv disabled/nominations.smx nominations.smx",
        "chown -R nobody:root /opt",
        "tar -czvf /archive.tar.gz /opt",
    ],
    extract_file = "/archive.tar.gz",
    image = ":sourcemod_container.tar",
)

#
# Build LAN of DOOM Plugin and Config Layer
#

container_layer(
    name = "lanofdoom_server_config",
    directory = "/opt/game/cstrike/cfg",
    files = [
        ":server.cfg",
    ],
)

container_layer(
    name = "lanofdoom_server_entrypoint",
    directory = "/opt/game",
    files = [
        ":entrypoint.sh",
    ],
)

container_layer(
    name = "lanofdoom_server_plugins",
    directory = "/opt/game/cstrike",
    tars = [
        "@auth_by_steam_group//file",
        "@map_settings//file",
        "@max_cash//file",
    ],
)

container_image(
    name = "config_container",
    base = "@ubuntu//image",
    layers = [
        ":lanofdoom_server_config",
        ":lanofdoom_server_entrypoint",
        ":lanofdoom_server_plugins",
    ],
)

container_run_and_extract(
    name = "lanofdoom",
    commands = [
        "chown -R nobody:root /opt",
        "tar -czvf /archive.tar.gz /opt",
    ],
    extract_file = "/archive.tar.gz",
    image = ":config_container.tar",
)

#
# Build Final Image
#

container_image(
    name = "server_image",
    base = "@server_base//image",
    entrypoint = ["/opt/game/entrypoint.sh"],
    env = {
        "CSS_ADMIN": "",
        "CSS_HOSTNAME": "",
        "CSS_MAP": "de_dust2",
        "CSS_MOTD": "",
        "CSS_PASSWORD": "",
        "CSS_PORT": "27015",
        "RCON_PASSWORD": "",
        "STEAM_GROUP_ID": "",
        "STEAM_API_KEY": "",
    },
    tars = [
        ":lanofdoom/archive.tar.gz",
        ":maps/archive.tar.gz",
        ":sourcemod/archive.tar.gz",
    ],
    user = "nobody",
)

container_push(
    name = "push_server_image",
    format = "Docker",
    image = ":server_image",
    registry = "ghcr.io",
    repository = "lanofdoom/counterstrikesource-server/counterstrikesource-server",
    tag = "latest",
)
