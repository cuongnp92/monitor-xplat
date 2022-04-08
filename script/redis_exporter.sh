#!/bin/bash
####################### Cài đặt Redis_exporter ####################################
# Install redis_exporter
version="${VERSION:-1.35.1}"
arch="${ARCH:-linux-amd64}"
bin_dir="${BIN_DIR:-/usr/bin}"

source agent_config.sh

wget "https://github.com/oliver006/redis_exporter/releases/download/v$version/redis_exporter-v$version.$arch.tar.gz" \
    -O /opt/redis_exporter.tar.gz

mkdir /opt/redis_exporter

cd /opt || { echo "ERROR! No /opt found"; exit 1; }

tar xfz /opt/redis_exporter.tar.gz -C /opt/redis_exporter || { echo "ERROR! Extracting the redis_exporter tar"; exit 1; }

cp "/opt/redis_exporter/redis_exporter-v$version.$arch/redis_exporter" "$bin_dir"

# allow port ufw
sudo ufw allow from 127.0.0.1 to any port 9121

cat <<EOF > /etc/systemd/system/redis_exporter.service
[Unit]
Description=Redis Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=redis
Group=redis
Type=simple
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/bin/redis_exporter 
    --log-format=txt 
    --namespace=redis 
    --web.listen-address=:9121 
    --redis.addr="redis://$ip:6379" 
    --redis.password="$database_password"
    --web.telemetry-path=/metrics
[Install]
WantedBy=multi-user.target    
EOF

useradd -rs /bin/false redis_exporter

systemctl daemon-reload
systemctl enable redis_exporter.service
systemctl start redis_exporter.service


echo "SUCCESS! Installation redis_exporter succeeded!"


