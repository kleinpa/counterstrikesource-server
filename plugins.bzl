"""Fetches and compiles the lanofdoom Counter-Strike: Source SourcePawn plugins.

Each entry is pinned by the commit SHA of the release tag previously used to
fetch a prebuilt binary tarball. The upstream trees have no BUILD files (they
build with a shell script that downloads spcomp at runtime); a minimal BUILD
that compiles the plugin with rules_sourcemod's spcomp toolchain is injected
by the repository rule instead. plugin_name is set explicitly so the compiled
.smx keeps the same filename the old prebuilt tarballs shipped, since that
name is what shows up in sm plugins list and in addons/sourcemod/plugins/.
"""

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

_BUILD_TEMPLATE = """\
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
        _BUILD_TEMPLATE.format(sp = sp, plugin_name = sp.removesuffix(".sp")),
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
