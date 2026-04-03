#!/bin/sh
input=$(cat)
[ -z "$input" ] && input='{"model":{"display_name":"Claude"},"workspace":{"current_dir":""},"context_window":{"total_input_tokens":0,"total_output_tokens":0,"context_window_size":200000}}'

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# User and host
user=$(whoami)
host=$(hostname -s)

# Current working directory from Claude context
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -z "$cwd" ]; then
  cwd=$(pwd)
fi
dir=$(basename "$cwd")

# Git branch and status (skip optional locks)
git_info=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Check for dirty state
    if ! git -C "$cwd" -c gc.auto=0 diff --quiet 2>/dev/null || ! git -C "$cwd" -c gc.auto=0 diff --cached --quiet 2>/dev/null; then
      git_info=" \033[1;33m$branch *\033[0m"
    else
      git_info=" \033[1;35m$branch\033[0m"
    fi
  fi
fi

# Context total tokens (cumulative input + output)
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Format individual in/out tokens
if [ "$total_in" -ge 1000000 ]; then
  total_in_fmt=$(echo "$total_in" | awk '{printf "%.1fM", $1/1000000}')
elif [ "$total_in" -ge 1000 ]; then
  total_in_fmt=$(echo "$total_in" | awk '{printf "%.1fk", $1/1000}')
else
  total_in_fmt="${total_in}"
fi
if [ "$total_out" -ge 1000000 ]; then
  total_out_fmt=$(echo "$total_out" | awk '{printf "%.1fM", $1/1000000}')
elif [ "$total_out" -ge 1000 ]; then
  total_out_fmt=$(echo "$total_out" | awk '{printf "%.1fk", $1/1000}')
else
  total_out_fmt="${total_out}"
fi

# Model context window size (total capacity)
ctx_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
if [ "$ctx_window_size" -ge 1000000 ]; then
  ctx_window_fmt=$(echo "$ctx_window_size" | awk '{printf "%.0fM", $1/1000000}')
elif [ "$ctx_window_size" -ge 1000 ]; then
  ctx_window_fmt=$(echo "$ctx_window_size" | awk '{printf "%.0fk", $1/1000}')
else
  ctx_window_fmt="${ctx_window_size}"
fi

# Context used percentage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  ctx_pct=$(printf "%.0f" "$used_pct")
else
  ctx_pct="0"
fi

# Progress bar for context usage (10 chars wide)
bar_width=10
filled=$(( ctx_pct * bar_width / 100 ))
empty=$(( bar_width - filled ))
bar_filled=""
bar_empty=""
i=0
while [ "$i" -lt "$filled" ]; do
  bar_filled="${bar_filled}█"
  i=$(( i + 1 ))
done
i=0
while [ "$i" -lt "$empty" ]; do
  bar_empty="${bar_empty}░"
  i=$(( i + 1 ))
done
# Color: green <50%, yellow 50-80%, red >80%
if [ "$ctx_pct" -ge 80 ]; then
  bar_color="\033[1;31m"
elif [ "$ctx_pct" -ge 50 ]; then
  bar_color="\033[1;33m"
else
  bar_color="\033[1;32m"
fi
progress_bar="${bar_color}${bar_filled}\033[0;90m${bar_empty}\033[0m"

# Pricing based on claude-sonnet-4 rates: $3/M input, $15/M output
cost_usd=$(echo "$total_in $total_out" | awk '{printf "%.4f", ($1/1000000)*3 + ($2/1000000)*15}')
# BRL conversion (approximate rate USD->BRL ~5.70)
cost_brl=$(echo "$cost_usd" | awk '{printf "%.4f", $1 * 5.70}')

# Session duration from transcript file creation time
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  start_ts=$(stat -f "%B" "$transcript" 2>/dev/null || stat -c "%W" "$transcript" 2>/dev/null)
  now_ts=$(date +%s)
  if [ -n "$start_ts" ] && [ "$start_ts" -gt 0 ] 2>/dev/null; then
    elapsed=$((now_ts - start_ts))
    hrs=$((elapsed / 3600))
    mins=$(((elapsed % 3600) / 60))
    secs=$((elapsed % 60))
    if [ "$hrs" -gt 0 ]; then
      duration=$(printf "%dh%02dm" "$hrs" "$mins")
    else
      duration=$(printf "%dm%02ds" "$mins" "$secs")
    fi
  else
    duration="--"
  fi
else
  duration="--"
fi

printf "[ \033[1;32mUser: \033\033[1;34m%s@%s\033[0m | \033[1;37m%s\033[0m | %b ]\n [ \033[1;32mModel: \033[1;37m%s\033[0m \033[0;90m(%s)\033[0m ] | \033[1;37min:\033[0m %s \033[1;37mout:\033[0m %s | %b \033[1;31m(%s%%)\033[0m ]\n [ \033[1;32mCost:\033[0m \033[1;31m\$%s USD\033[0m / \033[1;31mR\$%s BRL\033[0m | \033[1;32mSection: \033[1;37m%s ] \033" \
"$user" "$host" "$dir" "$git_info" \
"$model" "$ctx_window_fmt" "$total_in_fmt" "$total_out_fmt" "$progress_bar" "$ctx_pct" \
"$cost_usd" "$cost_brl" "$duration"
