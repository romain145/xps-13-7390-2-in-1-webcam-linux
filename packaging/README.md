Local package build: `python prepare.py && makepkg --cleanbuild`

`prepare.py` packs the driver, software ISP, scripts and systemd units into
`camera-source.tar.gz` and updates the checksum in PKGBUILD.

The Makefile selects the compiler from the target kernel. Tested against
7.3.4-1-cachyos (Clang) and 6.18.60-2-cachyos-lts (GCC).

The package installs:

- DKMS sources for the four modules (int346f, ov01a10-i346f, intel-ipu4p,
  intel-ipu4p-isys)
- `/usr/bin/ipu4-softisp`, the software ISP relay to `/dev/video57`
- `xps7390-webcam-setup.service` and `xps7390-webcam.service`
- `/usr/lib/modprobe.d/xps7390-webcam.conf` (blacklists the stock ov01a10)
- `/usr/lib/udev/rules.d/71-xps7390-webcam.rules` (no uaccess write ACL on
  `/dev/video57`, so the seat user cannot inject frames)
- `/usr/lib/xps7390-webcam/write-bridge-marker`, which writes the root-owned
  `/run/xps7390-webcam/rgb-source` marker a Gaze RGB-bridge build checks
- `/usr/lib/systemd/system-sleep/xps7390-webcam`, which stops the sensor
  before system sleep and restarts it after

Firmware is not distributed here; it is installed separately at
`/usr/lib/firmware/intel/ipu/ipu4p_cpd.bin`.

Rollback: `sudo pacman -R xps7390-webcam-dkms`, then reboot.
