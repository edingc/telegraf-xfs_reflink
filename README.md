# telegraf-xfs_reflink

[![Actions](https://github.com/edingc/telegraf-xfs_reflink/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/edingc/telegraf-xfs_reflink/actions)
[![Contributors](https://img.shields.io/github/contributors/edingc/telegraf-xfs_reflink.svg)](https://github.com/edingc/telegraf-xfs_reflink/graphs/contributors)
[![License](https://img.shields.io/github/license/edingc/telegraf-xfs_reflink.svg)](https://github.com/edingc/telegraf-xfs_reflink/blob/master/LICENSE)

A [Telegraf](https://github.com/influxdata/telegraf) plugin to report simple XFS reflink statistics. Inspired by [Luca Dell'Oca](https://www.virtualtothecore.com/calculate-space-savings-of-a-xfs-volume-with-reflink-and-veeam-fast-clone/) and the [telegraf-apt](https://github.com/x70b1/telegraf-apt) Telegraf plugin.

XFS reflinks allow multiple files to share the same underlying data blocks, reducing disk usage. This plugin tracks how much space is being saved on a given XFS volume through reflinks.

This plugin runs as a daemon and emits metrics at the interval configured in Telegraf.

## Requirements

- Linux system with an XFS filesystem mounted with reflink support (`mkfs.xfs -m reflink=1`)
- [Telegraf](https://github.com/influxdata/telegraf) with `execd` input plugin support

## Installation

1. Copy `telegraf-xfs_reflink.sh` to your desired location (e.g. `/opt/telegraf/`).
2. Make the script executable:
```sh
   chmod +x /opt/telegraf/telegraf-xfs_reflink.sh
```

## Configuration

Add the following to your Telegraf configuration, replacing `/storage` with the the path to your volume and setting the collection interval as desired:

```ini
[[inputs.execd]]
  command = ["/bin/sh", "/opt/telegraf/telegraf-xfs_reflink.sh", "/storage"]
  data_format = "influx"

  interval = "4h"
  signal = "SIGUSR1"
```

## Output

```sh
# sh /opt/telegraf/telegraf-xfs_reflink.sh /storage
xfs_reflink volume="/dev/mapper/storage_vg-storage_lv",sum_files_KB="734403080872",used_space_KB="165905404608",ratio="4.42"
```

## How to Read Output

**volume**

Returns the physical volume of the input path specified.

**sum_files_KB**

Returns the size in Kilobytes of the input path, as reported by `du`.

**used_space_KB**

Returns the actual size of the input path's volume, as reported by `df`.

**ratio**

Returns the savings ratio obtained by XFS reflinks. In the above example output, the obtained savings ratio is 4.42, meaning the files would take 4.42 times the disk space without reflinks.