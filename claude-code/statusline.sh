#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
case "$PCT" in ''|*[!0-9]*) PCT=0 ;; esac
[ "$PCT" -gt 100 ] && PCT=100
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Detect OS version from CLAUDE.md (first line)
OS_VERSION=""
CLAUDE_MD="$HOME/claude_config/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  OS_VERSION=$(head -1 "$CLAUDE_MD" | sed 's/^# //')
else
  OS_VERSION="⚠ OS not loaded"
fi

# Progress bar (20 chars wide)
FILLED=$((PCT / 5))
if [ "$PCT" -ge 70 ]; then
  COLOR="\033[31m"  # red when >= 70%
elif [ "$PCT" -ge 50 ]; then
  COLOR="\033[33m"  # yellow when >= 50%
else
  COLOR="\033[32m"  # green
fi
RESET="\033[0m"
# BSD seq counts down when last < first (seq 1 0 → "1 0"), so build the bar with a loop
BAR=""
for ((i = 0; i < FILLED; i++)); do BAR+="▓"; done
for ((i = FILLED; i < 20; i++)); do BAR+="░"; done

printf "${COLOR}${BAR}${RESET} %s%% | %s | \$%.2f | %s" "$PCT" "$MODEL" "$COST" "$OS_VERSION"
