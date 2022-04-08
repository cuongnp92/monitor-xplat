#!/bin/bash
# Author: Khanh Nguyen Tran
####################### Cài đặt Mongodb_exporter ####################################
# Install postgres_exporter
version="${VERSION:-0.7.1}"
arch="${ARCH:-linux-amd64}"
bin_dir="${BIN_DIR:-/usr/local/bin}"

source agent_config.sh

# Check folder opt
mkdir -p /opt;

wget "https://github.com/percona/mongodb_exporter/releases/download/v$version/mongodb_exporter-$version.$arch.tar.gz" \
    -O /opt/mongodb_exporter.tar.gz
echo "Download mongodb_exporter succeeded"

mkdir -p /opt/mongodb_exporter

cd /opt 

tar xfz /opt/mongodb_exporter.tar.gz -C /opt/mongodb_exporter || { echo "ERROR! Extracting the mongodb_exporter tar"; exit 1; }

if [ ! -f $bin_dir/mongodb_exporter ]; then
    cp "/opt/mongodb_exporter/mongodb_exporter" "$bin_dir"
fi
# create env file
cat <<EOF >/opt/mongodb_exporter/mongodb_exporter.env
MONGODB_URI=mongodb://mongodb_exporter:$mongodb_exporter_password@localhost:27017
EOF

# allow port ufw
# check and allow port ufw
status=$(ufw status | grep -c "inactive")
if [ $status == "0" ]; then
    ufw allow from 127.0.0.1 to any port 9216;
fi

if [ ! -f /lib/systemd/system/mongodb_exporter.service ]; then
cat <<EOF > /lib/systemd/system/mongodb_exporter.service
[Unit]
Description=MongoDB Exporter
User=mongodb

[Service]
Type=simple
Restart=always
EnvironmentFile=/opt/mongodb_exporter/mongodb_exporter.env
ExecStart=/usr/local/bin/mongodb_exporter

[Install]
WantedBy=multi-user.target
EOF
fi

useradd -rs /bin/false mongodb_exporter

systemctl daemon-reload
systemctl enable mongodb_exporter.service
systemctl start mongodb_exporter.service


echo "SUCCESS! Installation mongodb_exporter succeeded!"