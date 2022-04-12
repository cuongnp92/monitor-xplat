#!/bin/bash
# Author: Khanh Nguyen Tran
# Install node_exporter
version="${VERSION:-1.3.1}"
arch="${ARCH:-linux-amd64}"
bin_dir="${BIN_DIR:-/usr/local/bin}"

# Check folder opt
mkdir -p /opt;

# Download node_exporter
wget "https://github.com/prometheus/node_exporter/releases/download/v$version/node_exporter-$version.$arch.tar.gz" \
    -O /opt/node_exporter.tar.gz
echo "Download node_exporter succeeded"

# Check folder node_exporter
mkdir -p /opt/node_exporter;

# move node_exporter to /usr/local/bin
cd /opt

tar xfz /opt/node_exporter.tar.gz -C /opt/node_exporter || { echo "ERROR! Extracting the node_exporter tar"; exit 1; }

if [ ! -f $bin_dir/node_exporter ]; then
    cp "/opt/node_exporter/node_exporter-$version.$arch/node_exporter" "$bin_dir";
fi 

# check and allow port ufw
status=$(ufw status | grep -c "inactive")
if [ $status == "0" ]; then
    ufw allow from 127.0.0.1 to any port 9100;
fi

if [ ! -f /etc/systemd/system/node_exporter.service ]; then
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target
EOF
fi

useradd -rs /bin/false node_exporter

systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service

echo "SUCCESS! Installation node_exporter succeeded!"