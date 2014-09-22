#!/bin/sh
IP='10.20.0.2'
PORT='22'
if [ -n "${1}" ]; then
  IP="${1}"
fi
if [ -n "${2}" ]; then
  PORT="${2}"
fi

DIR=`dirname "${0}"`
cd "${DIR}" || exit 0

set -x
ssh-copy-id -p "${PORT}" "root@${IP}"
ssh -p "${PORT}" "root@${IP}" "yum install -y rsync"

sync() {
  from="${1}"
  to="${2}"
  ssh -p "${PORT}" "root@${IP}" "mkdir -p '${to}'"
  rsync --rsh "ssh -p ${PORT}" -av --progress -c --delete "${from}/" "root@${IP}:${to}/"
}

sync '..' '/etc/puppet/modules/fuel-patching-hooks' 
sync '..' '/etc/puppet/2014.1.1-5.0.2/modules/fuel-patching-hooks' 
sync '..' '/etc/puppet/2014.1.1-5.1/modules/fuel-patching-hooks' 
