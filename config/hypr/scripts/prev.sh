#!/bin/bash
echo $$ starting socat  >> /tmp/hyprland-socket
/usr/bin/socat -t 10000 -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
  echo $$ $line >> /tmp/hyprland-socket
    if [[ $line == *"closewindow"* ]]; then
        # Get current workspace ID
        current_workspace=$(hyprctl activewindow -j | jq '.workspace.id')
        
        # Get count of windows in current workspace
        window_count=$(hyprctl workspaces -j | jq ".[] | select(.id == $current_workspace) | .windows")
        
        # Switch only if workspace is empty (window count is 0)
        if [ 0"$window_count" -eq 0 ]; then
            hyprctl dispatch workspace previous
        fi
    fi
done &
