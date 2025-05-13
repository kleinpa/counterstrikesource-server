load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def repos(ctx):
    """Fetches repositories"""

    #
    # Server Dependencies
    #

    http_file(
        name = "auth_by_steam_group",
        downloaded_file_path = "auth_by_steam_group.tar.gz",
        sha256 = "95cb0dd02c46e81594d08edd6456ca2d929b3768235deedf8b8397aa05c1ee1f",
        urls = ["https://github.com/lanofdoom/auth-by-steam-group/releases/download/v2.3.0/auth_by_steam_group.tar.gz"],
    )

    http_file(
        name = "disable_buyzones",
        downloaded_file_path = "disable_buyzones.tar.gz",
        sha256 = "20a376c6e1acc54f646fa9f551f130e1cd18e8d4b2183e9ba21acabb88c38721",
        urls = ["https://github.com/lanofdoom/counterstrikesource-disable-buyzones/releases/download/v1.0.0/lan_of_doom_disable_buyzones.tar.gz"],
    )

    http_file(
        name = "disable_radar",
        downloaded_file_path = "disable_radar.tar.gz",
        sha256 = "2e84c3d37e8f44a9e562d4d94d43459c1c41c43ec776542a4cc7558a0487b6b8",
        urls = ["https://github.com/lanofdoom/counterstrikesource-disable-radar/releases/download/v1.0.0/lan_of_doom_disable_radar.tar.gz"],
    )

    http_file(
        name = "disable_round_timer",
        downloaded_file_path = "disable_round_timer.tar.gz",
        sha256 = "9655ab21ac776ce87f2e8540fbe520a7ed093ecf8cb51fb99a081d8284eabb03",
        urls = ["https://github.com/lanofdoom/counterstrikesource-disable-round-timer/releases/download/v1.0.1/lan_of_doom_disable_round_timer.tar.gz"],
    )

    http_file(
        name = "ffa_spawns",
        downloaded_file_path = "ffa_spawns.tar.gz",
        sha256 = "707056ff3b7aabbcca0bcae62eca55a4969dc8df0c1f7bae817567c0fe73e6b0",
        urls = ["https://github.com/lanofdoom/counterstrikesource-ffa-spawns/releases/download/v1.0.1/lan_of_doom_ffa_spawns.tar.gz"],
    )

    http_file(
        name = "free_for_all",
        downloaded_file_path = "free_for_all.tar.gz",
        sha256 = "22f9f842d6a47af06b769368b46478b6a96e9624e3d06cfb41c3d0786752a4b0",
        urls = ["https://github.com/lanofdoom/counterstrikesource-free-for-all/releases/download/v1.0.0/lan_of_doom_ffa.tar.gz"],
    )

    http_file(
        name = "gungame",
        downloaded_file_path = "lan_of_doom_gungame.tar.gz",
        sha256 = "6d58de8f681424b2b70b2c896912087a2fe84901a6026cea86fa27948dcdda11",
        urls = ["https://github.com/lanofdoom/counterstrikesource-gungame/releases/download/v1.0.2/lan_of_doom_gungame.tar.gz"],
    )

    http_file(
        name = "maps",
        downloaded_file_path = "maps.tar.gz",
        sha256 = "d46c07b3e3ad4177cb7c387d2b52b270ba4c4a677df1f937037e2363230f6965",
        urls = ["https://github.com/lanofdoom/counterstrikesource-maps/releases/download/v6.1.0/maps.tar.gz"],
    )

    http_file(
        name = "map_settings",
        downloaded_file_path = "map_settings.tar.gz",
        sha256 = "1e16ed149806bdda69d618cacd3c2cea3d60bd99fd856173d6f9b061a68c3892",
        urls = ["https://github.com/lanofdoom/counterstrikesource-map-settings/releases/download/v1.7.0/lan_of_doom_map_settings.tar.gz"],
    )

    http_file(
        name = "max_cash",
        downloaded_file_path = "max_cash.tar.gz",
        sha256 = "98a9f6fec86928e29ce9dd4eff715a69efb9adbc75df26f2b2ccae7b3bc387ae",
        urls = ["https://github.com/lanofdoom/counterstrikesource-max-cash/releases/download/v1.0.0/lan_of_doom_max_cash.tar.gz"],
    )

    http_file(
        name = "metamod",
        downloaded_file_path = "metamod.tar.gz",
        sha256 = "b7fc903755bb3f273afd797b36e94844b828e721d291d2a7519eecad3fa8486c",
        urls = ["https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1145-linux.tar.gz"],
    )

    http_file(
        name = "paintball",
        downloaded_file_path = "paintball.tar.gz",
        sha256 = "cd5d0d9debe0aa2724dfeffa193d27dff69f880493d56bf67146ee2cf65fd682",
        urls = ["https://github.com/lanofdoom/counterstrikesource-paintball/releases/download/v0.9.0/lan_of_doom_paintball.tar.gz"],
    )

    http_file(
        name = "remove_objectives",
        downloaded_file_path = "remove_objectives.tar.gz",
        sha256 = "5f6c84e6b4e5da1f07d256edef1ec7ad8a1db92247c12e74d6d22d6fd1186254",
        urls = ["https://github.com/lanofdoom/counterstrikesource-remove-objectives/releases/download/v1.0.0/lan_of_doom_remove_objectives.tar.gz"],
    )

    http_file(
        name = "respawn",
        downloaded_file_path = "respawn.tar.gz",
        sha256 = "194b158a9b9cdbd790021ceec1f5d5ece3edd5a1cee34e76d5e198abc93ab797",
        urls = ["https://github.com/lanofdoom/counterstrikesource-respawn/releases/download/v1.0.0/lan_of_doom_respawn.tar.gz"],
    )

    http_file(
        name = "spawn_protection",
        downloaded_file_path = "spawn_protection.tar.gz",
        sha256 = "ae1a845ccd579832f7a3af44c9821957d01816cedbcdf7a8cb26c4e16f3ed5f5",
        urls = ["https://github.com/lanofdoom/counterstrikesource-spawn-protection/releases/download/v1.0.0/lan_of_doom_spawn_protection.tar.gz"],
    )

    http_file(
        name = "sourcemod",
        downloaded_file_path = "sourcemod.tar.gz",
        sha256 = "9f59ddf32a649695e4c7dac0dfebdc382590486e60ff6473d7b87a31b6bfa01b",
        urls = ["https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6529-linux.tar.gz"],
    )

repos_bzlmod = module_extension(implementation = repos)
