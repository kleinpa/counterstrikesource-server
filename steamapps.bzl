load("@rules_steam//:steam.bzl", "steam_app")

BUILD_counterstrikesource_dedicated = "17399407"

def repos(ctx):
    steam_app(
        name = "counterstrikesource_dedicated",
        depots = [
            {"app": "232330", "depot": "232330", "manifest": "8012076251401872268"},
            {"app": "232330", "depot": "232336", "manifest": "4365247718224700910"},
        ],
    )

steamapps_bzlmod = module_extension(implementation = repos)
