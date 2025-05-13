def _maplist_file(ctx):
    output_file = ctx.actions.declare_file("{}.txt".format(ctx.label.name))
    ctx.actions.run_shell(
        inputs = [ctx.file.map_archive],
        outputs = [output_file],
        command = "tar tvf '%s' | grep '\\.bsp' | sed -E 's|.*/([^/]+)\\.bsp(\\.bz2)?|\\1|' > '%s'" %
                  (ctx.file.map_archive.path, output_file.path),
    )
    return [DefaultInfo(files = depset([output_file]))]

maplist_file = rule(
    implementation = _maplist_file,
    attrs = {
        "map_archive": attr.label(allow_single_file = True),
    },
)
