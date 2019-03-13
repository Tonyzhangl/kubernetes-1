#!/usr/bin/env bash

DOCKER_OPTS=${1:-""}

DOCKER_CONFIG=/opt/kubernetes/cfg/docker

cat <<EOF >$DOCKER_CONFIG
DOCKER_OPTS="-H tcp://127.0.0.1:4243 -H unix:///var/run/docker.sock -s overlay --selinux-enabled=false ${DOCKER_OPTS}"
EOF

cat <<EOF >/usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target flannel.service
Requires=flannel.service

[Service]
Type=notify
EnvironmentFile=-/run/flannel/docker
EnvironmentFile=-/opt/kubernetes/cfg/docker
WorkingDirectory=/opt/kubernetes/bin
ExecStart=/opt/kubernetes/bin/dockerd \$DOCKER_OPT_BIP \$DOCKER_OPT_MTU \$DOCKER_OPTS
LimitNOFILE=1048576
LimitNPROC=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable docker
systemctl restart docker
systemctl status docker