load("@rules_steam//:steam.bzl", "steam_app")

BUILD_counterstrikesource_dedicated = "6953255"

def repos(ctx):
    steam_app(
        name = "counterstrikesource_dedicated",
        depots = [
            {"app": "232330", "depot": "232330", "manifest": "2613653526845220043"},
            {"app": "232330", "depot": "232336", "manifest": "2107924716899862244"},
        ],
    )

steamapps_bzlmod = module_extension(implementation = repos)
