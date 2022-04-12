#!/bin/bash
# Author: Khanh Nguyen Tran
# Cài đặt grafana_agent sử dụng systemd
################################# Variables ################################
source agent_config.sh

node_exporter="['$ip:9100']"
postgres_exporter="['$ip:9187']"
redis_exporter="['$ip:9121']"
mongodb_exporter="['$ip:9216']"
mysql_exporter="['$ip:9104']"
################################# Help function###############################
Help()
{
# Display Help
echo "Install grafana agent."
echo "Syntax: bash grafana_agent.sh [-h|e]"
echo "options:"
echo "-h     Print this Help."
echo "-e     Option[node_exporter|redis_exporter|postgres_exporter|mongodb_exporter|mysql_exporter]"
echo
}

generate_exporter_config()
{
# create data folder
mkdir -p /etc/agent

mkdir -p /etc/agent/data

grafana_config_file=/etc/agent/agent.yaml

if [[ ! -f $grafana_config_file ]]
then 
cat <<EOF > /etc/agent/agent.yaml
server:
   log_level: info
   http_listen_port: 9000
metrics:
  global:
    scrape_interval: 1m
  configs:
    - name: agent
      scrape_configs:
        - job_name: agent
          static_configs:
      remote_write:
        - url: $url
          basic_auth:
            username: $username
            password: $password
EOF
fi 
echo "# Generate agent.yaml file succeed! #"
}

# install grafana_agent systemd
grafana_agent_systemd()
{
mkdir -p /tmp

cd /tmp 
grafana_agent_file=/tmp/grafana-agent-0.23.0-1.amd64.deb

if [[ -f "$grafana_agent_file" ]]
then 
  echo "# Grafana-agent-0.23.0-1.amd64.deb exist! #"
else
  wget https://github.com/grafana/agent/releases/download/v0.23.0/grafana-agent-0.23.0-1.amd64.deb
fi

dpkg -i grafana-agent-0.23.0-1.amd64.deb

cat <<EOF > /etc/systemd/system/grafana-agent.service
[Unit]
Description=Grafana Agent
[Service]
User=root
ExecStart=/usr/bin/grafana-agent --config.file=/etc/agent/agent.yaml --metrics.wal-directory string=/etc/agent/data
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable grafana-agent
systemctl start grafana-agent
systemctl restart grafana-agent
echo "# Install grafana_agent successful #"
}

Help
if [[ $1 == -e ]]
then 
  generate_exporter_config
  if [[ $2 == node_exporter ]]
  then
      exporter=$node_exporter
      sed -i "/static_configs:$/a\            - targets: $exporter" /etc/agent/agent.yaml
  elif [[ $2 == postgres_exporter ]]
  then
      exporter=$postgres_exporter
      sed -i "/static_configs:$/a\            - targets: $exporter" /etc/agent/agent.yaml
  elif [[ $2 == redis_exporter ]]
  then
      exporter=$redis_exporter
      sed -i "/static_configs:$/a\            - targets: $exporter" /etc/agent/agent.yaml
  elif [[ $2 == mongodb_exporter ]]
  then
      exporter=$mongodb_exporter
      sed -i "/static_configs:$/a\            - targets: $exporter" /etc/agent/agent.yaml
  elif [[ $2 == mysql_exporter ]]
  then 
      exporter=$mysql_exporter
      sed -i "/static_configs:$/a\            - targets: $exporter" /etc/agent/agent.yaml
  else 
      echo "# Option exporter incorrect #";
      exit 1;
  fi
grafana_agent_systemd
fi 
