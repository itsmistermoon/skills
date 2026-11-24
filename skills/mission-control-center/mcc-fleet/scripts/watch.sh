#!/usr/bin/env bash
# Watch a report or a missing Rex pane. Run in the background.
set -u
session=$1 block=$2 result=$3 idle=${4:-900}
last_hash= same_since=$(date +%s)
while :; do
  if [ -f "$result" ]; then echo "report: $result"; exit 0; fi
  if ! screen=$(rex capture -s "$session" -b "$block" --trim 2>/dev/null); then
    echo "pane gone; report: $result"; exit 1
  fi
  if printf '%s\n' "$screen" | tail -40 | grep -Eq 'Hooks need review|Do you want to proceed|Do you trust|Would you like to run|Allow this|needs your approval'; then
    echo "agent stopped at a prompt: $block"; exit 2
  fi
  hash=$(printf '%s' "$screen" | shasum | cut -c1-40)
  now=$(date +%s)
  if [ "$hash" != "$last_hash" ]; then
    last_hash=$hash same_since=$now
  elif [ $((now - same_since)) -ge "$idle" ]; then
    echo "agent idle for ${idle}s: $block"; exit 3
  fi
  sleep 30
done
