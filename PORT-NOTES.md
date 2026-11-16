# CachyOS kernel compatibility port

Base: 336a8a3. Target tested for compilation: 7.3.4-1-cachyos.

LED implementation is taken from Linux v7.3:
https://github.com/torvalds/linux/blob/v7.3/drivers/platform/x86/intel/int3472/led.c
The upstream SPDX header is preserved. Original LED implementation is retained
as led-legacy.c; Kbuild selects according to INT3472_MAX_LEDS in target headers.
The privacy connection name stays `privacy` on both paths.

The top-level Makefile detects CONFIG_CC_IS_CLANG from the target kernel and
sets LLVM=1 when needed. The installed 6.18.60 LTS kernel uses GCC; both
kernel builds have now passed.
All four modules compile and pass modpost against the installed kernel headers.
The older-kernel branch has not been built in this environment.

Validated on a Dell XPS 13 7390 2-in-1 running 7.3.4-1-cachyos: PCI driver
binds, OV01A10 probes (media entity `ov01a10 2-0036`, discovered by the setup
script), firmware authenticates, raw capture and the software ISP relay work,
including across s2idle and deep (S3) suspend.

Original install.sh is NOT the installation path for this port; use the
locally built Arch package (packaging/) for tracked installation and removal.
Firmware remains a separate verified local extraction.

## Runtime findings

- Keep the sensor's default vertical blanking (96, 60 fps). Any longer frame
  makes the IPU4P firmware abort ~25% of DMA transfers ~1 ms after start of
  frame (FW error 8, HW_REPORTED_STR2MMIO), independent of exposure and CPU
  latency. The software ISP sums 2-4 frames instead for low light.
- `ipu4p_resume()` could not power PSYS during system resume (PSYS is a
  child of ISYS, which is still resuming), so the firmware was never
  re-authenticated after S3 and every stream failed. Authentication now runs
  in the `.complete` PM callback and is skipped when the firmware is still
  authenticated (s2idle).
- A stream that is live across suspend dies and needs an ISYS reset. The
  system-sleep hook (scripts/sleep-hook.sh) stops the relay's sensor first.
- Firmware call timeout reduced from 2 s to 750 ms so a hung stream recovers
  faster; normal replies take milliseconds.
- On this laptop, deep S3 was followed twice by a hard freeze minutes later
  (also once with the camera idle and its firmware re-authenticated). s2idle is
  the default and was stable; avoid deep sleep and hibernation.
