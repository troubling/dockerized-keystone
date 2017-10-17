FROM ubuntu

RUN apt-get update &&  apt-get install -y \
    keystone \
    vim \
    python-openstackclient

RUN sed -e 's/connection = sqlite:\/\/\/\/var\/lib\/keystone\/keystone.db/connection = mysql:\/\/root:password@mysql\/keystone/g'  \
-e 's/#expiration = 3600/expiration = 604800/g' \
-e 's/#min_pool_size = 1/min_pool_size = 5/g' \
-e 's/#max_pool_size = <None>/max_pool_size = 15/g' \
-e 's/#db_retry_interval = 1/db_retry_interval = 1/g' \
-e 's/#db_inc_retry_interval = true/db_inc_retry_interval = true/g' \
-e 's/#db_max_retry_interval = 10/db_max_retry_interval = 3/g' \
-i /etc/keystone/keystone.conf

COPY bootstrap-keystone.sh /etc/bootstrap-keystone.sh
RUN chown root:root /etc/bootstrap-keystone.sh && chmod a+x /etc/bootstrap-keystone.sh

ENTRYPOINT ["/etc/bootstrap-keystone.sh"]

EXPOSE 35357
EXPOSE 5000
