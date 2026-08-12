"""Fetches and compiles the lanofdoom SourceMod extensions and CSS plugins.

Each entry is pinned by the commit SHA of the release tag previously used to
fetch a prebuilt binary tarball. Extensions build with AMBuild upstream
(which resolves an HL2SDK manifest and clones SourceMod at HEAD); plugins
have no BUILD files at all upstream (they build with a shell script that
downloads spcomp at runtime). A minimal BUILD compiling with
rules_sourcemod's cc_library / sourcemod_extension / sourcemod_plugin rules
is injected by the repository rules below instead.
"""

# auth_by_steam_group only touches SourceMod's own IGameHelpers/IPlayerHelpers
# interfaces (see extension/smsdk_config.h's SMEXT_ENABLE_* set), so unlike
# override_tickrate it needs no HL2SDK dependency. It ships a plugin alongside
# the extension: the plugin calls the extension's natives, declared in
# extension/auth_by_steam_group.inc and included from the .sp by relative
# path, so that .inc is pulled in as an extra_srcs rather than a includes dep.
_AUTH_BY_STEAM_GROUP_BUILD = """\
load("@rules_cc//cc:defs.bzl", "cc_library")
load("@rules_sourcemod//:defs.bzl", "sourcemod_extension", "sourcemod_plugin")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # GPL-3.0

cc_library(
    name = "auth_by_steam_group_core",
    srcs = ["extension/extension.cpp"],
    hdrs = [
        "extension/extension.h",
        "extension/smsdk_config.h",
    ],
    includes = ["extension"],
    deps = ["@sourcemod_sdk//:sourcemod_headers"],
    alwayslink = True,
)

sourcemod_extension(
    name = "auth_by_steam_group",
    deps = [":auth_by_steam_group_core"],
)

alias(
    name = "extension",
    actual = ":auth_by_steam_group",
)

sourcemod_plugin(
    name = "plugin",
    src = "plugin/auth_by_steam_group.sp",
    extra_srcs = ["extension/auth_by_steam_group.inc"],
    plugin_name = "auth_by_steam_group",
)
"""

# override_tickrate hooks IServerGameDLL::GetTickInterval through SourceHook,
# so unlike auth_by_steam_group it needs the HL2SDK this module already fetches
# for @hl2sdk_css.
_OVERRIDE_TICKRATE_BUILD = """\
load("@rules_cc//cc:defs.bzl", "cc_library")
load("@rules_sourcemod//:defs.bzl", "sourcemod_extension")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # GPL-3.0

cc_library(
    name = "override_tickrate_core",
    srcs = ["extension/extension.cpp"],
    hdrs = [
        "extension/extension.h",
        "extension/smsdk_config.h",
    ],
    includes = ["extension"],
    deps = [
        "@hl2sdk_css//:hl2sdk",
        "@sourcemod_sdk//:sourcemod_headers",
    ],
    alwayslink = True,
)

sourcemod_extension(
    name = "override_tickrate",
    deps = [":override_tickrate_core"],
)

alias(
    name = "extension",
    actual = ":override_tickrate",
)
"""

_EXTENSIONS = {
    "auth_by_steam_group": {
        "github_repo": "auth-by-steam-group",
        "commit": "53ef7a84814fc3745133e7f8fe4e756c75d34333",  # v3.0.1
        "build_content": _AUTH_BY_STEAM_GROUP_BUILD,
    },
    "override_tickrate": {
        "github_repo": "override-tickrate",
        "commit": "74c5bb61e8a3a612feefb471e763a1a6b703e4dc",  # v1.0.1
        "build_content": _OVERRIDE_TICKRATE_BUILD,
    },
}

def _extension_impl(repository_ctx):
    repo = repository_ctx.attr.github_repo
    commit = repository_ctx.attr.commit
    repository_ctx.download_and_extract(
        url = "https://github.com/lanofdoom/{}/archive/{}.tar.gz".format(repo, commit),
        stripPrefix = "{}-{}".format(repo, commit),
    )
    repository_ctx.file(
        "BUILD.bazel",
        repository_ctx.attr.build_content,
        executable = False,
    )

_extension_repository = repository_rule(
    implementation = _extension_impl,
    attrs = {
        "build_content": attr.string(mandatory = True),
        "commit": attr.string(mandatory = True),
        "github_repo": attr.string(mandatory = True),
    },
)

def _extensions_impl(_module_ctx):
    for name, info in _EXTENSIONS.items():
        _extension_repository(
            name = name,
            github_repo = info["github_repo"],
            commit = info["commit"],
            build_content = info["build_content"],
        )

extensions = module_extension(
    implementation = _extensions_impl,
    doc = "Fetches and compiles the lanofdoom native SourceMod extensions from source.",
)

# plugin_name is set explicitly so the compiled .smx keeps the same filename
# the old prebuilt tarballs shipped, since that name is what shows up in `sm
# plugins list` and in addons/sourcemod/plugins/.
_CSS_PLUGINS = {
    "disable_buyzones": {
        "github_repo": "counterstrikesource-disable-buyzones",
        "commit": "e8175f3a51a16698bbed35be9b4872c48469f32a",  # v1.0.0
        "sp": "lan_of_doom_disable_buyzones.sp",
    },
    "disable_radar": {
        "github_repo": "counterstrikesource-disable-radar",
        "commit": "e5b484c59d47e42cb733829aa741ad2ed2c61647",  # v1.0.0
        "sp": "lan_of_doom_disable_radar.sp",
    },
    "disable_round_timer": {
        "github_repo": "counterstrikesource-disable-round-timer",
        "commit": "b87075169587ac98efd18f354efd4c4e78588d0c",  # v1.0.1
        "sp": "lan_of_doom_disable_round_timer.sp",
    },
    "ffa_spawns": {
        "github_repo": "counterstrikesource-ffa-spawns",
        "commit": "96d7538efc3a841bcaf9de488a6e17c68f41fcdc",  # v1.0.1
        "sp": "lan_of_doom_ffa_spawns.sp",
    },
    "free_for_all": {
        "github_repo": "counterstrikesource-free-for-all",
        "commit": "d6c2a6acfb03cf74013ad94033626e92a788fbcf",  # v1.0.0
        "sp": "lan_of_doom_ffa.sp",
    },
    "gungame": {
        "github_repo": "counterstrikesource-gungame",
        "commit": "56904e52549139d1e95467c888c0fc07af1702aa",  # v1.0.2
        "sp": "lan_of_doom_gungame.sp",
    },
    "map_settings": {
        "github_repo": "counterstrikesource-map-settings",
        "commit": "c9e8c20d052c9d63a8f9f43df22ba68765a813d1",  # v1.7.0
        "sp": "lan_of_doom_map_settings.sp",
    },
    "max_cash": {
        "github_repo": "counterstrikesource-max-cash",
        "commit": "49ba2506a6e6eb2a15a65da4571dffdf459c3d27",  # v1.0.0
        "sp": "max_cash.sp",
    },
    "paintball": {
        "github_repo": "counterstrikesource-paintball",
        "commit": "577716460a30286196c50c8e6fff203e5519c843",  # v0.9.0
        "sp": "lan_of_doom_paintball.sp",
    },
    "remove_objectives": {
        "github_repo": "counterstrikesource-remove-objectives",
        "commit": "0fe3a8d596eff509831c635188abbf65b0c854d4",  # v1.0.0
        "sp": "lan_of_doom_remove_objectives.sp",
    },
    "respawn": {
        "github_repo": "counterstrikesource-respawn",
        "commit": "71044e90af79ba86d31132afe471453064d61f83",  # v1.0.0
        "sp": "lan_of_doom_respawn.sp",
    },
    "spawn_protection": {
        "github_repo": "counterstrikesource-spawn-protection",
        "commit": "458d91ce5991dbf9e475cf11516a56c274d0f360",  # v1.0.0
        "sp": "lan_of_doom_spawn_protection.sp",
    },
}

_CSS_PLUGIN_BUILD_TEMPLATE = """\
load("@rules_sourcemod//:defs.bzl", "sourcemod_plugin")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # MIT / GPL-3.0

sourcemod_plugin(
    name = "plugin",
    src = "{sp}",
    plugin_name = "{plugin_name}",
)
"""

def _css_plugin_impl(repository_ctx):
    repo = repository_ctx.attr.github_repo
    commit = repository_ctx.attr.commit
    repository_ctx.download_and_extract(
        url = "https://github.com/lanofdoom/{}/archive/{}.tar.gz".format(repo, commit),
        stripPrefix = "{}-{}".format(repo, commit),
    )
    sp = repository_ctx.attr.sp_file
    repository_ctx.file(
        "BUILD.bazel",
        _CSS_PLUGIN_BUILD_TEMPLATE.format(sp = sp, plugin_name = sp.removesuffix(".sp")),
        executable = False,
    )

_css_plugin_repository = repository_rule(
    implementation = _css_plugin_impl,
    attrs = {
        "commit": attr.string(mandatory = True),
        "github_repo": attr.string(mandatory = True),
        "sp_file": attr.string(mandatory = True),
    },
)

def _css_plugins_impl(_module_ctx):
    for name, info in _CSS_PLUGINS.items():
        _css_plugin_repository(
            name = name,
            commit = info["commit"],
            github_repo = info["github_repo"],
            sp_file = info["sp"],
        )

css_plugins = module_extension(
    implementation = _css_plugins_impl,
    doc = "Fetches and compiles the lanofdoom CSS SourcePawn plugins from source.",
)
