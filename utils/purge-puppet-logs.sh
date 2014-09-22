#!/bin/sh
find '/var/log/docker-logs/remote/' -name 'puppet-apply.log' | while read file x; do
  echo "Pugre: ${file}"
  echo > "${file}"
done
