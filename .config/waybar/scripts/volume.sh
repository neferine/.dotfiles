#!/bin/bash

volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo true || echo false)

if [ "$muted" = true ]; then
  icon=""
else
  if [ "$volume" -ge 70 ]; then
    icon=""
  elif [ "$volume" -ge 30 ]; then
    icon=""
  else
    icon=""
  fi
fi

echo "{\"text\": \"$icon $volume%\"}"
