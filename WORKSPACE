load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "59536e6ae64359b716ba9c46c39183403b01eabfbd57578e84398b4829ca499a",
    strip_prefix = "rules_docker-0.22.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.22.0/rules_docker-v0.22.0.tar.gz"],
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

#
# Steam Dependencies
#

http_archive(
    name = "com_github_lanofdoom_steamlayer",
    sha256 = "fd5377f2ad33c343eafac4fdc5f29028ed0f7a931979b0d1cc18b0e8c36af9bb",
    strip_prefix = "steamcmd-ea38d3c275122aa16430c166bb03fce383547a0d",
    urls = ["https://github.com/lanofdoom/steamcmd/archive/ea38d3c275122aa16430c166bb03fce383547a0d.zip"],
)

load("@com_github_lanofdoom_steamlayer//:repositories.bzl", "steamlayer_repos")

steamlayer_repos()

load("@com_github_lanofdoom_steamlayer//:deps.bzl", "steamlayer_deps")

steamlayer_deps()

load("@com_github_lanofdoom_steamlayer//:nugets.bzl", "steamlayer_nugets")

steamlayer_nugets()

#
# Server Dependencies
#

http_file(
    name = "auth_by_steam_group",
    downloaded_file_path = "auth_by_steam_group.tar.gz",
    sha256 = "563b4f508373494ab3b26acccc9c9fcbd11b168ed85b7ee7447a5603627350a9",
    urls = ["https://lanofdoom.github.io/auth-by-steam-group/releases/v2.1.2/auth_by_steam_group.tar.gz"],
)

http_file(
    name = "deathmatch",
    downloaded_file_path = "lan_of_doom_deathmatch.tar.gz",
    sha256 = "7a195a24a3691033c565b10dbbba9d4bf017745f41b6ed6fa1e5e94c53a268e0",
    urls = ["https://lanofdoom.github.io/counterstrike-deathmatch/releases/v1.0.0/lan_of_doom_deathmatch.tar.gz"],
)

http_file(
    name = "maps",
    downloaded_file_path = "maps.tar.xz",
    sha256 = "00bafd77b190892fe55480976e51c6dc67507085488ca323dc418655b696826e",
    urls = ["https://lanofdoom.github.io/counterstrikesource-maps/releases/v2.0.0/maps.tar.xz"],
)

http_file(
    name = "map_settings",
    downloaded_file_path = "map_settings.tar.gz",
    sha256 = "783768b9a0f71fd9a1f7f50d10aceae4814c00714595f7d7c0a46a48d05338d4",
    urls = ["https://lanofdoom.github.io/counterstrikesource-map-settings/releases/v1.1.1/lan_of_doom_map_settings.tar.gz"],
)

http_file(
    name = "max_cash",
    downloaded_file_path = "max_cash.tar.gz",
    sha256 = "98a9f6fec86928e29ce9dd4eff715a69efb9adbc75df26f2b2ccae7b3bc387ae",
    urls = ["https://lanofdoom.github.io/counterstrikesource-max-cash/releases/v1.0.1/max_cash.tar.gz"],
)

http_file(
    name = "metamod",
    downloaded_file_path = "metamod.tar.gz",
    sha256 = "2794c0e747b5e751a4335c8be8dce2e87907a1a3aa5313505ae7944c51630884",
    urls = ["https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1143-linux.tar.gz"],
)

http_file(
    name = "sourcemod",
    downloaded_file_path = "sourcemod.tar.gz",
    sha256 = "e8dac72aeb3df8830c46234d7e22c51f92d140251ca72937eb0afed05cd32c66",
    urls = ["https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6502-linux.tar.gz"],
)

#
# Container Base Image
#

load("@io_bazel_rules_docker//contrib:dockerfile_build.bzl", "dockerfile_image")

dockerfile_image(
    name = "server_base_image",
    dockerfile = "//:base.Dockerfile",
)
