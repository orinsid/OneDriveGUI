#!/bin/sh

set -u # Treat unset variables as an error.
trap "exit" TERM QUIT INT
trap "kill_OneDriveGUI" EXIT
export QT_DEBUG_PLUGINS=1
export HOME=/root
cd $HOME/OneDriveGUI/src
log() {
    echo "[onedriveguisupervisor] $*"
}
getpid_OneDriveGUI() {
    PID=UNSET
    if [ -f $HOME/.config/onedrivegui.pid ]; then
        PID="$(cat $HOME/.config/onedrivegui.pid)"
        if [ ! -f /proc/$PID/cmdline ] || ! cat /proc/$PID/cmdline | grep -qw "OneDriveGUI.py"; then
            PID=UNSET
        fi
    fi
    if [ "$PID" = "UNSET" ]; then
        PID="$(ps -o pid,args | grep -w "OneDriveGUI.py" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    fi
    echo "${PID:-UNSET}"
}

is_OneDriveGUI_running() {
    [ "$(getpid_OneDriveGUI)" != "UNSET" ]
}

start_OneDriveGUI() {
        export TERMINAL=xterm
        #exec xterm
        xterm -e "nohup python3 OneDriveGUI.py > $HOME/.config/output.log 2>&1" &
}

kill_OneDriveGUI() {
    PID="$(getpid_OneDriveGUI)"
    if [ "$PID" != "UNSET" ]; then
        log "Terminating OneDriveGUI..."
        kill $PID
        wait $PID
    fi
}

if [ ! -d "$HOME/.config/onedrive" ]; then
  cp -r "$HOME/config/onedrive" "$HOME/.config/"
fi

if [ ! -f "$HOME/.config/onedrive-gui" ]; then
  cp -r "$HOME/config/onedrive-gui" "$HOME/.config/"
fi


if ! is_OneDriveGUI_running; then
    log "OneDriveGUI not started yet.  Proceeding..."
    start_OneDriveGUI
fi



OneDriveGUI_NOT_RUNNING=0
while [ "$OneDriveGUI_NOT_RUNNING" -lt 5 ]
do
    if is_OneDriveGUI_running; then
        OneDriveGUI_NOT_RUNNING=0
    else
        OneDriveGUI_NOT_RUNNING="$(expr $OneDriveGUI_NOT_RUNNING + 1)"
    fi
    sleep 1
done

log "OneDriveGUI no longer running.  Exiting..."


