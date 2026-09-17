load("@rules_steam//:steam.bzl", "steam_app")

BUILD_counterstrikesource_dedicated = "25338297"

def repos(ctx):
    steam_app(
        name = "counterstrikesource_dedicated",
        depots = [
            {"app": "232330", "depot": "232330", "manifest": "120014569776599625"},
            {"app": "232330", "depot": "232336", "manifest": "943661550915847242"},
        ],
    )

steamapps_bzlmod = module_extension(implementation = repos)
