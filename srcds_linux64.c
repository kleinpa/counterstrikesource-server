/*
 * 64-bit launcher for the Counter-Strike: Source dedicated server.
 *
 * Valve ships CS:S's 64-bit engine without a 64-bit launcher to start it. The
 * launcher does almost nothing -- it loads dedicated_srv.so and hands argv to
 * DedicatedMain -- so this reproduces the one Team Fortress 2 ships, which
 * CS:S's engine is otherwise happy with.
 *
 * Beyond that it does two things a container needs of its main process.
 *
 * It line-buffers stdout. glibc fully buffers a stdout that is not
 * a tty, which it is not in a Kubernetes pod, and the engine never changes
 * that: the console log would reach `kubectl logs` 4 KiB at a time, and a crash
 * would take the unflushed end of it along.
 *
 * It exits on SIGINT and SIGTERM. The engine leaves both at their default
 * action, which the kernel does not apply to PID 1, so Ctrl-C would do nothing
 * and stopping a pod would sit out the whole grace period before SIGKILL.
 */

#include <dlfcn.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <xmmintrin.h>

/* Relative to the working directory, as in Valve's launcher. */
#define DEDICATED_PATH "bin/linux64/dedicated_srv.so"

/* Flush-to-zero and denormals-are-zero. Valve links its launcher with
 * -ffast-math, whose startup code sets these bits, and every engine thread
 * inherits them. Without them denormal floats are computed in full, which
 * slows down physics and changes its results. */
#define MXCSR_FTZ_DAZ 0x8040

typedef int (*DedicatedMain_fn)(int argc, char **argv);

/* Ends the process on the spot, as the default action would have. The engine
 * offers no shutdown that is safe to call from a signal handler. */
static void exit_on_signal(int signum) { _exit(128 + signum); }

int main(int argc, char **argv)
{
    setvbuf(stdout, NULL, _IOLBF, BUFSIZ);
    signal(SIGINT, exit_on_signal);
    signal(SIGTERM, exit_on_signal);
    _mm_setcsr(_mm_getcsr() | MXCSR_FTZ_DAZ);

    void *dedicated = dlopen(DEDICATED_PATH, RTLD_NOW);
    if (!dedicated)
    {
        fprintf(stderr, "Failed to open %s (%s)\n", DEDICATED_PATH, dlerror());
        return 1;
    }

    DedicatedMain_fn dedicated_main =
        (DedicatedMain_fn)dlsym(dedicated, "DedicatedMain");
    if (!dedicated_main)
    {
        fprintf(stderr, "Failed to find dedicated server entry point (%s)\n",
                dlerror());
        return 1;
    }

    return dedicated_main(argc, argv);
}
