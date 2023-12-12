#!/bin/bash
# Author: Khanh Nguyen Tran 
####################### Cài đặt Postgres_exporter ####################################
# Install postgres_exporter
version="${VERSION:-0.10.1}"
arch="${ARCH:-linux-amd64}"
bin_dir="${BIN_DIR:-/usr/local/bin}"

#source agent_config.sh

# Check folder opt 
wget "https://github.com/prometheus-community/postgres_exporter/releases/download/v$version/postgres_exporter-$version.$arch.tar.gz" \
    -O /opt/postgres_exporter.tar.gz
echo "Download postgres_exporter succeed"

# Check folder postgres_exporter
mkdir -p /opt/postgres_exporter

# move postgres_exporter to /usr/local/bin
cd /opt 

tar xfz /opt/postgres_exporter.tar.gz -C /opt/postgres_exporter || { echo "ERROR! Extracting the postgres_exporter tar"; exit 1; }

if [ ! -f $bin_dir/postgres_exporter ]; then
    cp "/opt/postgres_exporter/postgres_exporter-$version.$arch/postgres_exporter" "$bin_dir";
fi

# check and allow port ufw
status=$(ufw status | grep -c "inactive")
if [ $status == "0" ]; then
    ufw allow from 127.0.0.1 to any port 9187;
fi

# create env file
if [ ! -f /opt/postgres_exporter/postgres_exporter.env ]; then
cat <<EOF >/opt/postgres_exporter/postgres_exporter.env
DATA_SOURCE_NAME="postgresql://${database_username}:${database_password}@localhost:5432/${database}?sslmode=disable"
EOF
fi

if [ ! -f /etc/systemd/system/postgres_exporter.service ]; then
cat <<EOF > /etc/systemd/system/postgres_exporter.service
[Unit]
Description=Prometheus exporter for Postgresql
Wants=network-online.target
After=network-online.target
[Service]
User=postgres
Group=postgres
WorkingDirectory=/opt/postgres_exporter
EnvironmentFile=/opt/postgres_exporter/postgres_exporter.env
ExecStart=/usr/local/bin/postgres_exporter --web.listen-address=:9187 --web.telemetry-path=/metrics
Restart=always
[Install]
WantedBy=multi-user.target
EOF
fi 

useradd -rs /bin/false postgres_exporter

systemctl daemon-reload
systemctl enable postgres_exporter.service
systemctl start postgres_exporter.service


echo "SUCCESS! Installation postgres_exporter succeeded!"


