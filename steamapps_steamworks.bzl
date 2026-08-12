load("@rules_steam//steam:repos.bzl", "steam_app")

BUILD_steamworks_sdk_redist = "25329704"

def repos(ctx):
    steam_app(
        name = "steamworks_sdk_redist",
        depots = [
            {"app": "1007", "depot": "1006", "manifest": "4559160656493359681"},
        ],
    )

steamapps_bzlmod = module_extension(implementation = repos)
