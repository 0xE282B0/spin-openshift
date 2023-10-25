FROM busybox
COPY crun /assets/crun-spin
COPY spin /assets/spin
COPY installer.sh /script/installer.sh
ENTRYPOINT /script/installer.sh