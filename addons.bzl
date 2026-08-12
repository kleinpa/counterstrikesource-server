"""Fetches and compiles the lanofdoom SourceMod extensions and CSS plugins.

None of these repositories have BUILD files upstream yet, so a minimal one
compiling with rules_sourcemod is injected into each. Entries go away as their
repositories become Bazel modules, as auth_by_steam_group and empty_team_bots
already have.

Each entry is pinned by the commit SHA of a release tag.
"""

# override_tickrate hooks IServerGameDLL::GetTickInterval through SourceHook, so
# it is built for the CSS engine branch. No plugin requires it, so without the
# autoload file SourceMod would never load it.
_OVERRIDE_TICKRATE_BUILD = """\
load("@rules_sourcemod//:defs.bzl", "sourcemod_extension")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # GPL-3.0

sourcemod_extension(
    name = "extension",
    srcs = ["extension/extension.cpp"],
    hdrs = [
        "extension/extension.h",
        "extension/smsdk_config.h",
    ],
    autoload = True,
    branch = "css",
    extension_name = "override_tickrate",
    includes = ["extension"],
)
"""

_EXTENSIONS = {
    "override_tickrate": {
        "github_repo": "override-tickrate",
        "commit": "74c5bb61e8a3a612feefb471e763a1a6b703e4dc",  # v1.0.1
        "sha256": "96c58b65aafaadf14e9cb32f68739ef8b99ba566fdf6091cc5aefc99e6369056",
        "build_content": _OVERRIDE_TICKRATE_BUILD,
    },
}

# plugin_name is set explicitly so the compiled .smx keeps the same filename
# the old prebuilt tarballs shipped, since that name is what shows up in `sm
# plugins list` and in addons/sourcemod/plugins/.
#
# `data` globs files the plugin needs at runtime, laid out relative to cstrike/.
_CSS_PLUGINS = {
    "disable_buyzones": {
        "github_repo": "counterstrikesource-disable-buyzones",
        "commit": "e8175f3a51a16698bbed35be9b4872c48469f32a",  # v1.0.0
        "sha256": "d8b763e4bd09afafa01de485aab2cb0a01aa7a0ca81e4b2f834f412a920f00f8",
        "sp": "lan_of_doom_disable_buyzones.sp",
    },
    "disable_radar": {
        "github_repo": "counterstrikesource-disable-radar",
        "commit": "e5b484c59d47e42cb733829aa741ad2ed2c61647",  # v1.0.0
        "sha256": "e0e4e526505b6fa9ac9a95599cd44eee11e867f7d7d13ecef58c10b8d0452cb3",
        "sp": "lan_of_doom_disable_radar.sp",
    },
    "disable_round_timer": {
        "github_repo": "counterstrikesource-disable-round-timer",
        "commit": "b87075169587ac98efd18f354efd4c4e78588d0c",  # v1.0.1
        "sha256": "cef16ce0ddf1fc3ed10a1ddc8f2f87a79771e3fb671ee1ef681ae6cc0b64c4b7",
        "sp": "lan_of_doom_disable_round_timer.sp",
    },
    "ffa_spawns": {
        "github_repo": "counterstrikesource-ffa-spawns",
        "commit": "96d7538efc3a841bcaf9de488a6e17c68f41fcdc",  # v1.0.1
        "sha256": "1f5544ea7961b1b2f3315cf306095a9c0eba6ee1a442cc5df92a0b1bd9110698",
        "sp": "lan_of_doom_ffa_spawns.sp",
    },
    "free_for_all": {
        "github_repo": "counterstrikesource-free-for-all",
        "commit": "d6c2a6acfb03cf74013ad94033626e92a788fbcf",  # v1.0.0
        "sha256": "4602915899874b27a8fcbe4bd48b61eb521af9b91344d903b016a8d67b75862b",
        "sp": "lan_of_doom_ffa.sp",
    },
    "gungame": {
        "github_repo": "counterstrikesource-gungame",
        "commit": "56904e52549139d1e95467c888c0fc07af1702aa",  # v1.0.2
        "sha256": "2be519d685859903dc34d9c12cd28e276183929fe4d088c0ddc537840eb538ae",
        "sp": "lan_of_doom_gungame.sp",
    },
    "map_settings": {
        "github_repo": "counterstrikesource-map-settings",
        "commit": "c9e8c20d052c9d63a8f9f43df22ba68765a813d1",  # v1.7.0
        "sha256": "b8be8d5860a696f5ebfcbe0ca11083e79746e1d30fb700984f2135836c5d079c",
        "sp": "lan_of_doom_map_settings.sp",
    },
    "max_cash": {
        "github_repo": "counterstrikesource-max-cash",
        "commit": "49ba2506a6e6eb2a15a65da4571dffdf459c3d27",  # v1.0.0
        "sha256": "056e30909b50f69f6936ccd1b88cce010b26fc9caf30b3817193f9f94728645e",
        "sp": "max_cash.sp",
    },
    "paintball": {
        "github_repo": "counterstrikesource-paintball",
        "commit": "577716460a30286196c50c8e6fff203e5519c843",  # v0.9.0
        "sha256": "36b49efbbe6428011bf7b5bfc18dfc9e76ae241ef4bcbb329c51046ca6e4502b",
        "sp": "lan_of_doom_paintball.sp",
        "data": ["materials/**"],
    },
    "remove_objectives": {
        "github_repo": "counterstrikesource-remove-objectives",
        "commit": "0fe3a8d596eff509831c635188abbf65b0c854d4",  # v1.0.0
        "sha256": "f60b493c16c2d8fc1d012a6d2de83ead3a506a64c24527bf1912881657476772",
        "sp": "lan_of_doom_remove_objectives.sp",
    },
    "respawn": {
        "github_repo": "counterstrikesource-respawn",
        "commit": "71044e90af79ba86d31132afe471453064d61f83",  # v1.0.0
        "sha256": "e4bce93d02516f0ff145d5b545735e51c17dadfa96718e9c4119286470cb2e28",
        "sp": "lan_of_doom_respawn.sp",
    },
    "spawn_protection": {
        "github_repo": "counterstrikesource-spawn-protection",
        "commit": "458d91ce5991dbf9e475cf11516a56c274d0f360",  # v1.0.0
        "sha256": "72a71b0dc97e3b16d5b1e041a1cce51b469bfad2102e33686b3f2e24195f3458",
        "sp": "lan_of_doom_spawn_protection.sp",
    },
}

_CSS_PLUGIN_BUILD_TEMPLATE = """\
load("@rules_pkg//pkg:mappings.bzl", "pkg_filegroup", "pkg_files", "strip_prefix")
load("@rules_sourcemod//:defs.bzl", "sourcemod_plugin")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # MIT / GPL-3.0

sourcemod_plugin(
    name = "smx",
    src = "{sp}",
    plugin_name = "{plugin_name}",
)

pkg_files(
    name = "data",
    srcs = glob({data}, allow_empty = True),
    strip_prefix = strip_prefix.from_pkg(),
)

pkg_filegroup(
    name = "plugin",
    srcs = [
        ":data",
        ":smx",
    ],
)
"""

def _addon_repository_impl(repository_ctx):
    repo = repository_ctx.attr.github_repo
    commit = repository_ctx.attr.commit
    repository_ctx.download_and_extract(
        url = "https://github.com/lanofdoom/{}/archive/{}.tar.gz".format(repo, commit),
        sha256 = repository_ctx.attr.sha256,
        stripPrefix = "{}-{}".format(repo, commit),
    )
    repository_ctx.file(
        "BUILD.bazel",
        repository_ctx.attr.build_content,
        executable = False,
    )

_addon_repository = repository_rule(
    implementation = _addon_repository_impl,
    attrs = {
        "build_content": attr.string(mandatory = True),
        "commit": attr.string(mandatory = True),
        "github_repo": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
    },
)

def _addons_impl(_module_ctx):
    for name, info in _EXTENSIONS.items():
        _addon_repository(name = name, **info)

    for name, info in _CSS_PLUGINS.items():
        _addon_repository(
            name = name,
            build_content = _CSS_PLUGIN_BUILD_TEMPLATE.format(
                data = info.get("data", []),
                plugin_name = info["sp"].removesuffix(".sp"),
                sp = info["sp"],
            ),
            commit = info["commit"],
            github_repo = info["github_repo"],
            sha256 = info["sha256"],
        )

addons = module_extension(
    implementation = _addons_impl,
    doc = "Fetches and compiles the lanofdoom SourceMod extensions and plugins from source.",
)
