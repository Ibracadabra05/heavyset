
# Setup
`docker run --rm --privileged -v /:/host solita/ubuntu-systemd setup`

# Run

`docker run -d --name systemd -p2223:22 --security-opt seccomp=unconfined --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro -t ihamisu/heavyset:1.0.4`

`ssh -p2223 vagrant@127.0.0.1` or `docker exec -ti systemd /bin/bash`
