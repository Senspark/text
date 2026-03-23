#!/usr/bin/env bash

PACKAGE_NAME=com.senspark.goldminer.gm10
LOG_FILE="logcat_${PACKAGE_NAME}_$(date +'%Y%m%d%H%M%S').log"

# Launch the app
echo "Launching $PACKAGE_NAME..."
adb shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1

# Get PID immediately after launch (give it a moment to spawn)
sleep 1
PID=$(adb shell pidof "$PACKAGE_NAME" 2>/dev/null | tr -d '\r')

# ---------------------------------------------------------------------------
# FILTER OPTIONS — replace the logcat line(s) below with one of these:
#
# Level filter via logcat priority (*:X means "all tags at level X and above"):
#   adb logcat -v color -v printable --pid "$PID" *:E          # Error + Fatal only
#   adb logcat -v color -v printable --pid "$PID" *:F          # Fatal only
#   adb logcat -v color -v printable --pid "$PID" *:W          # Warning + above
#
# Grep for crashes / exceptions (works on the piped output):
#   ... | grep -E "FATAL|AndroidRuntime|CRASH|Exception|Error"
#   ... | grep -iE "crash|fatal|exception|anr|signal [0-9]"
#
# Combine level filter + grep (e.g. errors that mention a specific tag/class):
#   adb logcat -v color -v printable --pid "$PID" *:E | grep "MyClass"
#
# Show only a specific tag regardless of PID (e.g. Unity log tag):
#   adb logcat -v color -v printable Unity:D *:S             # Unity tag, silence rest
#   adb logcat -v color -v printable DEBUG:D *:S
# ---------------------------------------------------------------------------

if [ -n "$PID" ]; then
    echo "App running (PID: $PID) — logging to $LOG_FILE"
    adb logcat -v color -v printable --pid "$PID" | tee >(sed 's/\x1b\[[0-9;]*m//g' > "$LOG_FILE")
else
    echo "Warning: app not running — logging all output to $LOG_FILE"
    adb logcat -v color -v printable | tee >(sed 's/\x1b\[[0-9;]*m//g' > "$LOG_FILE")
fi