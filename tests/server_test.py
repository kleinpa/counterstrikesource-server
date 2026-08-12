"""End-to-end tests for the Counter-Strike: Source server image.

These start the real image in a container and interrogate it over Valve's A2S
query protocol, which is the same thing the Steam server browser does. If these
pass, a client can find and join the server.
"""

import os
import sys
import unittest

from srcds import Server

_RCON_PASSWORD = "hunter2"


class BootTest(unittest.TestCase):
    """The server comes up, loads a map and answers the server browser."""

    def test_default_command_answers_a2s(self):
        """With no arguments the image's own cmd has to produce a live server."""
        with Server() as server:
            info = server.info()
            self.assertEqual(info.map_name, "de_dust2")
            self.assertEqual(info.folder, "cstrike")
            self.assertEqual(info.game, "Counter-Strike: Source")
            self.assertEqual(info.player_count, 0)
            self.assertEqual(info.server_type, "d", "server is not dedicated")
            self.assertEqual(info.platform, "l",
                             "server is not the Linux build")

    def test_args_override_the_default_map(self):
        """A deployment overriding cmd, as a Kubernetes `args:` does."""
        with Server("+map", "de_nuke") as server:
            self.assertEqual(server.info().map_name, "de_nuke")

    def test_boots_on_a_custom_map(self):
        """Custom maps are merged into the image from a separate repo at build
        time, unlike the built-in maps that ship inside the game archive
        itself and are always placed correctly by it. Booting straight onto
        one catches that merge landing the .bsp anywhere other than
        cstrike/maps/, which a built-in map can never catch.
        """
        with Server("+map", "breakfloor") as server:
            self.assertEqual(server.info().map_name, "breakfloor")

    def test_server_cfg_is_executed(self):
        """server.cfg only takes effect if the engine execs it on map load."""
        with Server() as server:
            rules = server.rules()
            self.assertEqual(rules["mp_startmoney"], "16000")
            self.assertEqual(rules["mp_timelimit"], "25")

    def test_console_is_streamed_without_a_tty(self):
        """A line reaches the container log as soon as it is printed.

        Nothing follows the line to push it out of a stdout buffer, so this
        fails if our launcher stops line-buffering stdout.
        """
        with Server("+map", "de_dust2", "+rcon_password",
                    _RCON_PASSWORD) as server:
            server.wait_for_logs("Loaded plugin empty_team_bots.smx")
            server.rcon(_RCON_PASSWORD, "echo console-sentinel")
            server.wait_for_logs("console-sentinel")

    def test_exits_when_signalled(self):
        """Ctrl-C and `docker stop` work, although the server runs as PID 1 and
        the kernel ignores signals that PID 1 does not handle."""
        for signal, exit_code in (("SIGINT", 130), ("SIGTERM", 143)):
            with self.subTest(signal), Server() as server:
                self.assertEqual(server.kill(signal), exit_code)


class AddonTest(unittest.TestCase):
    """Metamod, SourceMod and our plugins all load."""

    def test_metamod_loads_sourcemod(self):
        """Metamod is only interesting here as the thing that loads SourceMod.

        Asserting on "[META] Loaded" alone is not enough: Metamod says "Loaded 0
        plugins" just as happily, and a SourceMod that cannot start is exactly
        what that looks like.
        """
        with Server() as server:
            server.wait_for_logs("[META] Loaded 1 plugin")
            self.assertNotIn("[META] Failed to load plugin", server.logs())

    _EXPECTED_PLUGINS = (
        "lan_of_doom_disable_buyzones.smx",
        "lan_of_doom_disable_radar.smx",
        "lan_of_doom_disable_round_timer.smx",
        "lan_of_doom_ffa.smx",
        "lan_of_doom_ffa_spawns.smx",
        "lan_of_doom_gungame.smx",
        "lan_of_doom_paintball.smx",
        "lan_of_doom_remove_objectives.smx",
        "lan_of_doom_respawn.smx",
        "lan_of_doom_spawn_protection.smx",
        "max_cash.smx",
        "auth_by_steam_group.smx",
    )

    def test_plugins_load(self):
        """Every compiled SourcePawn plugin loads, including the one that
        depends on a compiled native extension.

        This is what catches an extension landing in the wrong directory: the
        plugin still compiles fine, but fails at runtime because the 64-bit
        engine only looks under addons/sourcemod/extensions/x64.
        """
        with Server() as server:
            server.wait_for_logs(*(f"Loaded plugin {plugin} successfully"
                                   for plugin in self._EXPECTED_PLUGINS))

    def test_override_tickrate_loads(self):
        """-tickrate takes effect, which needs the override_tickrate extension.

        No plugin requires that extension, so nothing else here notices when
        SourceMod does not load it.
        """
        with Server("-tickrate", "100", "+map", "de_dust2") as server:
            server.wait_for_logs("setting tickrate to 100.0")

    def test_mapcycle_lists_the_installed_maps(self):
        """The generated mapcycle.txt reaches SourceMod with both sources of
        maps in it, and without the test maps that are excluded from it."""
        with Server("+map", "de_dust2", "+rcon_password",
                    _RCON_PASSWORD) as server:
            server.wait_for_logs("Loaded plugin nextmap.smx successfully")
            maps = server.rcon(_RCON_PASSWORD, "listmaps").splitlines()
            self.assertIn("de_nuke", maps, "built-in maps are missing")
            self.assertIn("breakfloor", maps, "custom maps are missing")
            self.assertNotIn("test_hardware", maps)
            self.assertNotIn("test_speakers", maps)


def main() -> None:
    """Runs the tests, honouring Bazel's --test_filter.

    Bazel passes the filter in TESTBRIDGE_TEST_ONLY, which plain
    `unittest.main()` ignores -- so `--test_filter` would silently run the whole
    suite, and every run would cost a container per test case.
    """
    test_filter = os.environ.get("TESTBRIDGE_TEST_ONLY")
    argv = list(sys.argv)
    if test_filter:
        argv.insert(1, "-k" + test_filter)
    unittest.main(argv=argv)


if __name__ == "__main__":
    main()
