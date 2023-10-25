#!/bin/sh
cp /assets/crun-spin /mnt/node-root/usr/local/bin/
cp /assets/spin /mnt/node-root/usr/local/bin/
mkdir -p /mnt/node-root/run/crun-spin

CRIO_CONF=/etc/crio/crio.conf
if ! grep -q crun-spin $NODE_ROOT$CRIO_CONF; then
    echo '
[crio.runtime.runtimes.crun-spin]
runtime_root = "/run/crun-spin"
' >> $NODE_ROOT$CRIO_CONF
    nsenter --target 1 --mount --uts --ipc --net -- systemctl restart crio
else
  echo "$NODE_ROOT$CRIO_CONF already contains 'crun-spin', nothing to do."
fi
