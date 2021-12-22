load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_layer", "container_push")
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")
load("@io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl", "install_pkgs")
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_extract")

#
# Download Counter-Strike: Source via SteamCMD
#

download_pkgs(
    name = "steamcmd_deps",
    image_tar = "@container_base//image",
    packages = [
        "ca-certificates",
        "lib32gcc1",
    ],
)

install_pkgs(
    name = "steamcmd_deps_installed",
    image_tar = "@container_base//image",
    installables_tar = "steamcmd_deps.tar",
    installation_cleanup_commands = "rm -rf /var/lib/apt/lists/*",
    output_image_name = "steamcmd_deps_installed",
)

container_image(
    name = "steamcmd_base",
    base = ":steamcmd_deps_installed",
    directory = "/opt/steam",
    files = [
        "@steamcmd//file",
    ],
)

container_run_and_extract(
    name = "download_counter_strike_source",
    commands = [
        "tar -xvzf /opt/steam/steamcmd_linux.tar.gz -C /opt/steam",
        "/opt/steam/steamcmd.sh +login anonymous +force_install_dir /opt/game +app_update 232330 validate +quit",
        "rm -rf /opt/game/steamapps",
        "chown -R nobody:root /opt/game",
        "tar -czvf /archive.tar.gz /opt/game/",
    ],
    extract_file = "/archive.tar.gz",
    image = ":steamcmd_base.tar",
)

container_layer(
    name = "counter_strike_source",
    tars = [
        ":download_counter_strike_source/archive.tar.gz",
    ],
)

#
# Build Server Base Image With i386 Enabled
#

container_run_and_extract(
    name = "enable_i386_sources",
    commands = [
        "dpkg --add-architecture i386",
    ],
    extract_file = "/var/lib/dpkg/arch",
    image = "@container_base//image",
)

container_image(
    name = "container_base_with_i386_packages",
    base = "@container_base//image",
    directory = "/var/lib/dpkg",
    files = [
        ":enable_i386_sources/var/lib/dpkg/arch",
    ],
)

#
# Server Image
#

download_pkgs(
    name = "server_deps",
    image_tar = ":container_base_with_i386_packages.tar",
    packages = [
        "ca-certificates:i386",
        "lib32gcc1",
        "libcurl4:i386",
    ],
)

install_pkgs(
    name = "server_base",
    image_tar = ":container_base_with_i386_packages.tar",
    installables_tar = ":server_deps.tar",
    installation_cleanup_commands = "rm -rf /var/lib/apt/lists/*",
    output_image_name = "server_base",
)

#
# Build Maps Layer
#

container_image(
    name = "maps_container",
    base = "@container_base//image",
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
    base = "@container_base//image",
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
    base = "@container_base//image",
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
    base = ":server_base",
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
    layers = [
        ":counter_strike_source",
    ],
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
