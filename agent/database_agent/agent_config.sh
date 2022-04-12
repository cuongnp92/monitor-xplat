#!/bin/bash
############################################################
#### File chua thong tin xac thuc url cua grafana_agent ####
############################################################
ip="${IP:-điền vào đây}"
url="${URL:-điền vào đây}"
username="${USERNAME:-điền vào đây}"
password="${PASSWORD:-điền vào đây}"

############# Thông tin xác thực của database (Redis, Postgres) ##########################
database_username="${DB_USERNAME:-điền vào đây}"
database_password="${DB_PASSWORD:-điền vào đây}"
database="${DATABASE:-điền vào đây}"

############ Neu monitor MongoDB thì sử dụng tham số này ###############
mongodb_exporter_password="${mongodb_exporter_password:-điền vào đây}"

############ Neu monitor MysqlDB thì sử dụng tham số này ###############
mysqld_exporter_password="${mysqld_exporter_password:-điền vào đây}"
