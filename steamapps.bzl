load("@rules_steam//:steam.bzl", "steam_app")

BUILD_counterstrikesource_dedicated = "24661315"

def repos(ctx):
    steam_app(
        name = "counterstrikesource_dedicated",
        depots = [
            {"app": "232330", "depot": "232330", "manifest": "922992753953080751"},
            {"app": "232330", "depot": "232336", "manifest": "7062464828702125286"},
        ],
    )

steamapps_bzlmod = module_extension(implementation = repos)
