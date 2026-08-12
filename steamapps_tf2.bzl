load("@rules_steam//:steam.bzl", "steam_app")

BUILD_tf2_dedicated = "26334371"

def repos(ctx):
    steam_app(
        name = "tf2_dedicated",
        depots = [
            {"app": "232250", "depot": "232250", "manifest": "5757605357257765879", "files": ["regex:^srcds_linux64$", "regex:^bin/linux64/libsteam_api\\.so$"]},
            {"app": "232250", "depot": "232256", "manifest": "8265263630080743034", "files": ["regex:^srcds_linux64$", "regex:^bin/linux64/libsteam_api\\.so$"]},
            {"app": "232250", "depot": "232257", "manifest": "4797708003880603728", "files": ["regex:^srcds_linux64$", "regex:^bin/linux64/libsteam_api\\.so$"]},
        ],
    )

steamapps_bzlmod = module_extension(implementation = repos)
