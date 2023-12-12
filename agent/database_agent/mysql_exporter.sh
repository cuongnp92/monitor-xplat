#!/bin/bash
# Author: Khanh Nguyen Tran
####################### Cài đặt Mysql_exporter ####################################
bin_dir="${BIN_DIR:-/usr/local/bin}"

#source agent_config.sh
# add user and group
groupadd --system prometheus

useradd -s /sbin/nologin --system -g prometheus prometheus

# Download mysqld_exporter package
mkdir -p /opt

cd /opt/

curl -s https://api.github.com/repos/prometheus/mysqld_exporter/releases/latest   | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -

echo "Download mysql_exporter succeeded!"

tar xfz /opt/mysqld_exporter-*.linux-amd64.tar.gz || { echo "ERROR! Extracting the mysql_exporter tar"; exit 1; }
mv /opt/mysqld_exporter-*.linux-amd64 /opt/mysqld_exporter

chmod +x /opt/mysqld_exporter/mysqld_exporter

if [ ! -f $bin_dir/mysqld_exporter ]; then
    cp "/opt/mysqld_exporter/mysqld_exporter" "$bin_dir"
fi

# Create database credentials file
cat <<EOF >/etc/.mysqld_exporter.cnf
[client]
user=mysqld_exporter
password=$mysqld_exporter_password
EOF

# Set ownership permissions
chown root:prometheus /etc/.mysqld_exporter.cnf

# check and allow port ufw
status=$(ufw status | grep -c "inactive")
if [ $status == "0" ]; then
    ufw allow from 127.0.0.1 to any port 9104;
fi

if [ ! -f /etc/systemd/system/mysql_exporter.service ]; then
cat <<EOF > /etc/systemd/system/mysql_exporter.service
[Unit]
Description=Prometheus MySQL Exporter
After=network.target
User=prometheus
Group=prometheus

[Service]
Type=simple
Restart=always
ExecStart=/usr/local/bin/mysqld_exporter \
--config.my-cnf /etc/.mysqld_exporter.cnf \
--collect.global_status \
--collect.info_schema.innodb_metrics \
--collect.auto_increment.columns \
--collect.info_schema.processlist \
--collect.binlog_size \
--collect.info_schema.tablestats \
--collect.global_variables \
--collect.info_schema.query_response_time \
--collect.info_schema.userstats \
--collect.info_schema.tables \
--collect.perf_schema.tablelocks \
--collect.perf_schema.file_events \
--collect.perf_schema.eventswaits \
--collect.perf_schema.indexiowaits \
--collect.perf_schema.tableiowaits \
--collect.slave_status \
--web.listen-address=0.0.0.0:9104

[Install]
WantedBy=multi-user.target
EOF
fi

systemctl daemon-reload
systemctl enable mysql_exporter
systemctl start mysql_exporter
