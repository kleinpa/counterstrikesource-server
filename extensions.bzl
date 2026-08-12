"""Fetches and compiles the lanofdoom native SourceMod extensions.

Each entry is pinned by the commit SHA of the release tag previously used to
fetch a prebuilt binary tarball. Both repos build with AMBuild upstream (which
resolves an HL2SDK manifest and clones SourceMod at HEAD); a minimal BUILD
compiling with rules_sourcemod's cc_library / sourcemod_extension /
sourcemod_plugin rules is injected by the repository rule instead.
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
