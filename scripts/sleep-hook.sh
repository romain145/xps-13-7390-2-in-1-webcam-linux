#!/bin/sh
# systemd-sleep hook: stop the camera relay's sensor before the system sleeps
# and restart it afterwards. A stream left running across suspend dies and
# forces an IPU reset on resume; stopping it first avoids that.
# Arguments: $1 = pre|post, $2 = suspend|hibernate|hybrid-sleep|suspend-then-hibernate
marker=/run/xps7390-webcam/paused

pid=$(systemctl show -p MainPID --value xps7390-webcam.service 2>/dev/null)
[ -n "$pid" ] && [ "$pid" -gt 0 ] 2>/dev/null || exit 0

case "$1" in
pre)
	rm -f "$marker"
	kill -USR1 "$pid" 2>/dev/null || exit 0
	# Wait (at most 3 s) until the relay confirms the sensor is stopped.
	i=0
	while [ $i -lt 30 ]; do
		[ -e "$marker" ] && exit 0
		sleep 0.1
		i=$((i + 1))
	done
	echo "xps7390-webcam: relay did not confirm the sensor stopped" >&2
	;;
post)
	kill -USR2 "$pid" 2>/dev/null
	;;
esac
exit 0
