#!/bin/sh
STATUS=$(pgrep wf-recorder && echo "recording" || echo "idle")
COMMAND="$1"
TEXT="<span color=\\\"green\\\">IDL</span>"

if [ "$STATUS" == "idle" ]; then
  if [ "$COMMAND" == "toggle" ]; then
    STATUS="recording"
    /home/damaru/.config/hypr/scripts/record-screen monitor &
  elif [ "$COMMAND" == "start" ]; then
    STATUS="recording"
    /home/damaru/.config/hypr/scripts/record-screen monitor &
  elif [ "$COMMAND" == "stop" ]; then
    STATUS="idle"
    killall wf-recorder
  elif [ "$COMMAND" != "" ]; then
    STATUS="recording"
    /home/damaru/.config/hypr/scripts/record-screen $COMMAND &
  fi
else
  if [ "$COMMAND" != "" ]; then
    STATUS="idle"
    killall wf-recorder
  fi
fi

echo "$STATUS" > /tmp/record-screen-status

if [ "$STATUS" == "idle" ]; then
    TEXT="<span color=\\\"#255F25\\\">   </span>"
else
    TEXT="<span color=\\\"#FF9999\\\"  background=\\\"#FF0000\\\">   </span>"
fi

echo "{\"text\": \"${TEXT}\"}"
