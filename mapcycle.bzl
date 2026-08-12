"""Builds the server's mapcycle from the maps that are actually installed."""

# Valve's test maps ship with the game but are not playable levels.
_EXCLUDED_MAPS = ["test_hardware", "test_speakers"]

def _mapcycle_file(ctx):
    output_file = ctx.actions.declare_file("{}.txt".format(ctx.label.name))

    # Maps are shipped twice: `foo.bsp` for the server to load and `foo.bsp.bz2`
    # for clients to pull over sv_downloadurl. Anchoring the match on `.bsp$`
    # keeps the compressed copy from producing a second, identical entry.
    #
    # The leading directory before `maps/` is optional: counterstrikesource_maps'
    # archive is rooted at `maps/` itself with nothing ahead of it, while the
    # base game's archive nests it under a directory. Requiring `/maps/`
    # unconditionally would silently drop every entry from the former. The
    # capture still anchors on a `/` or the start of the path rather than a bare
    # substring match, so a directory like `textmaps/` can't masquerade as one.
    ctx.actions.run_shell(
        inputs = ctx.files.map_archives,
        outputs = [output_file],
        command = """
set -euo pipefail
for archive in "$@"; do
    tar tf "$archive"
done |
    sed -n -E 's|^(.*/)?maps/([^/]+)\\.bsp$|\\2|p' |
    grep -vxF -e '{excluded}' |
    sort -u >'{output}'
""".format(
            excluded = "' -e '".join(_EXCLUDED_MAPS),
            output = output_file.path,
        ),
        arguments = [f.path for f in ctx.files.map_archives],
        mnemonic = "MapCycle",
        progress_message = "Generating mapcycle %{label}",
    )
    return [DefaultInfo(files = depset([output_file]))]

mapcycle_file = rule(
    implementation = _mapcycle_file,
    doc = "Writes a mapcycle.txt naming every map found under maps/ in `map_archives`.",
    attrs = {
        "map_archives": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "Tar archives to scan for `maps/*.bsp` entries.",
        ),
    },
)
