#!/usr/bin/env bash
# Claude Code status line for engineers (no git branch)
# Shows: cwd | model | context usage | 5h rate limit | 7d rate limit

input=$(cat)

# --- Fields from JSON ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# --- Shorten cwd: replace $HOME with ~ ---
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# --- Context bar ---
context_str=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  filled=$(( used_int / 10 ))
  bar=""
  for i in $(seq 1 10); do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}█"
    else
      bar="${bar}░"
    fi
  done
  context_str="ctx:${bar} ${used_int}%"
fi

# --- Assemble parts ---
parts=()

# Directory (cyan)
parts+=("$(printf '\033[36m%s\033[0m' "$short_cwd")")

# Model (magenta)
if [ -n "$model" ]; then
  parts+=("$(printf '\033[35m%s\033[0m' "$model")")
fi

# Context (green->red based on usage)
if [ -n "$context_str" ]; then
  if [ -n "$used_pct" ] && [ "$(printf "%.0f" "$used_pct")" -ge 80 ]; then
    parts+=("$(printf '\033[31m%s\033[0m' "$context_str")")
  else
    parts+=("$(printf '\033[32m%s\033[0m' "$context_str")")
  fi
fi

# Rate limit (5-hour): green <50%, yellow 50-79%, red >=80%
if [ -n "$five_hour_pct" ]; then
  five_int=$(printf "%.0f" "$five_hour_pct")
  if [ "$five_int" -ge 80 ]; then
    rl_color='\033[31m'
  elif [ "$five_int" -ge 50 ]; then
    rl_color='\033[33m'
  else
    rl_color='\033[32m'
  fi
  parts+=("$(printf "${rl_color}5h: ${five_int}%%\033[0m")")
fi

# Rate limit (7-day): green <50%, yellow 50-79%, red >=80%
if [ -n "$seven_day_pct" ]; then
  seven_int=$(printf "%.0f" "$seven_day_pct")
  if [ "$seven_int" -ge 80 ]; then
    rl7_color='\033[31m'
  elif [ "$seven_int" -ge 50 ]; then
    rl7_color='\033[33m'
  else
    rl7_color='\033[32m'
  fi
  parts+=("$(printf "${rl7_color}7d: ${seven_int}%%\033[0m")")
fi

# Join with separator
sep="$(printf '\033[90m │ \033[0m')"
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${sep}${part}"
  fi
done

printf "%b\n" "$result"
