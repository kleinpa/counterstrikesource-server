"""End-to-end tests for the Counter-Strike: Source server image.

These start the real image in a container and interrogate it over Valve's A2S
query protocol, which is the same thing the Steam server browser does. If these
pass, a client can find and join the server.

The image under test is supplied by Bazel through two environment variables set
by the ``srcds_container_test`` macro:

``SRCDS_IMAGE_LOADER``
    Runfiles path of an ``oci_load`` runnable that imports the image into the
    local container daemon. Executed once per test binary.

``SRCDS_REPO_TAG``
    The tag ``SRCDS_IMAGE_LOADER`` applies to the image.
"""

import functools
import os
import subprocess
import sys
import time
import unittest

import a2s
from python.runfiles import runfiles
from testcontainers.core.container import DockerContainer

# srcds needs to mount the map, start the engine and hand off to SourceMod
# before it answers A2S. Cold containers on a loaded machine can take a while.
_STARTUP_TIMEOUT_SECONDS = 120.0
_QUERY_TIMEOUT_SECONDS = 2.0
_POLL_INTERVAL_SECONDS = 1.0

_GAME_PORT = 27015


class ContainerError(AssertionError):
    """Raised when the container fails to start or fails to become ready."""


@functools.cache
def load_image() -> str:
    """Imports the image under test into the container daemon.

    Returns the repository tag the image was loaded under. The result is cached
    so that a test binary with many test cases only pays for one import.
    """
    tag = os.environ["SRCDS_REPO_TAG"]
    loader = runfiles.Create().Rlocation(os.environ["SRCDS_IMAGE_LOADER"])
    if loader is None or not os.path.exists(loader):
        raise ContainerError(
            f"image loader {os.environ['SRCDS_IMAGE_LOADER']!r} missing from runfiles"
        )
    subprocess.run([loader], check=True, stdout=subprocess.DEVNULL)
    return tag


def address(container: DockerContainer) -> tuple:
    """Returns the (host, port) A2S is reachable at for a started container."""
    return ("127.0.0.1", container.get_exposed_port(_GAME_PORT))


def logs(container: DockerContainer) -> str:
    """Returns the container's combined stdout and stderr so far.

    Every container in this module is started with `tty=True`: srcds detects a
    non-tty stdout and fully block-buffers it, so without a tty the engine, SM
    and plugin log lines this module polls for never reach the log stream
    until the buffer fills or the process exits -- long after any assertion
    here would have already timed out.
    """
    stdout, stderr = container.get_logs()
    return stdout.decode(errors="replace") + stderr.decode(errors="replace")


def wait_for_a2s(container: DockerContainer) -> None:
    """Blocks until the server answers A2S, or raises with the server log."""
    deadline = time.monotonic() + _STARTUP_TIMEOUT_SECONDS
    last_error = None
    while time.monotonic() < deadline:
        wrapped = container.get_wrapped_container()
        wrapped.reload()
        if wrapped.status != "running":
            raise ContainerError(
                f"server exited during startup:\n{logs(container)}")
        try:
            a2s.info(address(container), timeout=_QUERY_TIMEOUT_SECONDS)
            return
        except Exception as error:  # socket timeouts, partial responses, ...
            last_error = error
        time.sleep(_POLL_INTERVAL_SECONDS)
    raise ContainerError(
        f"server did not answer A2S within {_STARTUP_TIMEOUT_SECONDS:.0f}s "
        f"(last error: {last_error!r}):\n{logs(container)}")


def wait_for_plugins_loaded(container: DockerContainer, plugins) -> None:
    """Blocks until every name in `plugins` reports a successful load.

    Plugin loading finishes shortly after the server starts answering A2S, not
    before, so this polls the log rather than taking a single snapshot.
    """
    deadline = time.monotonic() + _STARTUP_TIMEOUT_SECONDS
    while time.monotonic() < deadline:
        server_logs = logs(container)
        if all(f"Loaded plugin {plugin} successfully" in server_logs
               for plugin in plugins):
            return
        time.sleep(_POLL_INTERVAL_SECONDS)
    raise ContainerError(
        f"not all plugins loaded within {_STARTUP_TIMEOUT_SECONDS:.0f}s:\n"
        f"{logs(container)}")


class BootTest(unittest.TestCase):
    """The server comes up, loads a map and answers the server browser."""

    def test_default_command_answers_a2s(self):
        """With no arguments the image's own cmd has to produce a live server."""
        with DockerContainer(
                load_image()).with_kwargs(init=True, tty=True).with_exposed_ports(
                    f"{_GAME_PORT}/udp") as container:
            wait_for_a2s(container)
            info = a2s.info(address(container), timeout=_QUERY_TIMEOUT_SECONDS)
            self.assertEqual(info.map_name, "de_dust2")
            self.assertEqual(info.folder, "cstrike")
            self.assertEqual(info.game, "Counter-Strike: Source")
            self.assertEqual(info.player_count, 0)
            self.assertEqual(info.server_type, "d", "server is not dedicated")
            self.assertEqual(info.platform, "l",
                             "server is not the Linux build")

    def test_args_override_the_default_map(self):
        """A deployment overriding cmd, as a Kubernetes `args:` does."""
        with DockerContainer(load_image()).with_kwargs(init=True, tty=True).with_command(
            ["+map",
             "de_nuke"]).with_exposed_ports(f"{_GAME_PORT}/udp") as container:
            wait_for_a2s(container)
            info = a2s.info(address(container), timeout=_QUERY_TIMEOUT_SECONDS)
            self.assertEqual(info.map_name, "de_nuke")

    def test_boots_on_a_custom_map(self):
        """Custom maps are merged into the image from a separate repo at build
        time, unlike the built-in maps that ship inside the game archive
        itself and are always placed correctly by it. Booting straight onto
        one catches that merge landing the .bsp anywhere other than
        cstrike/maps/, which a built-in map can never catch.
        """
        with DockerContainer(load_image()).with_kwargs(init=True, tty=True).with_command(
            ["+map",
             "breakfloor"]).with_exposed_ports(f"{_GAME_PORT}/udp") as container:
            wait_for_a2s(container)
            info = a2s.info(address(container), timeout=_QUERY_TIMEOUT_SECONDS)
            self.assertEqual(info.map_name, "breakfloor")

    def test_server_cfg_is_executed(self):
        """server.cfg only takes effect if the engine execs it on map load."""
        with DockerContainer(
                load_image()).with_kwargs(init=True, tty=True).with_exposed_ports(
                    f"{_GAME_PORT}/udp") as container:
            wait_for_a2s(container)
            rules = a2s.rules(address(container),
                              timeout=_QUERY_TIMEOUT_SECONDS)
            self.assertEqual(rules["mp_startmoney"], "16000")
            self.assertEqual(rules["mp_timelimit"], "25")


class AddonTest(unittest.TestCase):
    """Metamod, SourceMod and our plugins all load."""

    def test_metamod_loads_sourcemod(self):
        """Metamod is only interesting here as the thing that loads SourceMod.

        Asserting on "[META] Loaded" alone is not enough: Metamod says "Loaded 0
        plugins" just as happily, and a SourceMod that cannot start is exactly
        what that looks like.
        """
        with DockerContainer(
                load_image()).with_kwargs(init=True, tty=True).with_exposed_ports(
                    f"{_GAME_PORT}/udp") as container:
            wait_for_a2s(container)
            server_logs = logs(container)
            self.assertNotIn("[META] Failed to load plugin", server_logs)
            self.assertIn("[META] Loaded 1 plugin", server_logs,
                          "Metamod did not load SourceMod")

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
        with DockerContainer(
                load_image()).with_kwargs(init=True, tty=True).with_exposed_ports(
                    f"{_GAME_PORT}/udp") as container:
            wait_for_a2s(container)
            wait_for_plugins_loaded(container, self._EXPECTED_PLUGINS)
            server_logs = logs(container)
            for plugin in self._EXPECTED_PLUGINS:
                self.assertIn(f"Loaded plugin {plugin} successfully",
                              server_logs, f"{plugin} did not load")


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
