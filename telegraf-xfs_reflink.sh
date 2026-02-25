#!/bin/sh

# collect xfs reflink statistics for a given path
# run as a telegraf execd plugin, waking on SIGUSR1

if [ -z "$1" ]; then
    echo "Usage: $0 <path>" >&2
    exit 1
fi

path=$1

# verify the path is an xfs mount point with reflink support
if ! xfs_info "$path" 2>/dev/null | grep -q "reflink=1"; then
    echo "ERROR: $path is not an xfs filesystem with reflink support" >&2
    exit 1
fi

trap exit INT
trap "echo" USR1

while true; do
    # use df to identify the underlying volume
    volume=$(df "$path" | awk 'NR==2 { print $1 }')
    sum_files=$(du -sc "$path" | awk 'END { print $1 }')
    used_space=$(df "$volume" | awk 'NR==2 { print $3 }')
    ratio=$(echo "scale=2; $sum_files / $used_space" | bc)

    echo "xfs_reflink volume=\"$volume\",sum_files_KB=$sum_files,used_space_KB=$used_space,ratio=$ratio"

    # sleep until woken by SIGUSR1 from telegraf
    pkill -P $$
    sleep infinity &
    wait
done
