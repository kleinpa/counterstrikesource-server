load("@rules_steam//:steam.bzl", "steam_app")

# Counter-Strike: Source ships a 64-bit engine (bin/linux64, and a 64-bit
# cstrike/bin/linux64/server_srv.so) but Valve never shipped the 64-bit
# launcher for it: depot 232336 contains only a 32-bit srcds_linux. The
# launcher is engine-generic, so it is taken from Team Fortress 2's dedicated
# server, which does ship one, along with the 64-bit libsteam_api.so that CS:S
# also omits.
#
# Team Fortress 2 Dedicated Server, Linux binaries depot. The file filter keeps
# this to a ~100KB download instead of the whole depot.
BUILD_tf2_dedicated = "24245063"

# Steamworks SDK Redist, which is where a 64-bit steamclient.so comes from;
# CS:S only ships a 32-bit one. Four files, so no filter is needed.
BUILD_steamworks_sdk_redist = "20939719"

def repos(ctx):
    steam_app(
        name = "tf2_dedicated",
        depots = [{
            "app": "232250",
            "depot": "232256",
            "manifest": "698669566371320345",
            "files": [
                "regex:^srcds_linux64$",
                "regex:^bin/linux64/libsteam_api\\.so$",
            ],
        }],
    )

    steam_app(
        name = "steamworks_sdk_redist",
        depots = [{
            "app": "1007",
            "depot": "1006",
            "manifest": "6403079453713498174",
        }],
    )

steamapps_launcher_bzlmod = module_extension(implementation = repos)
