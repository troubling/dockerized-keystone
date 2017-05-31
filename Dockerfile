FROM ubuntu

RUN apt-get update &&  apt-get install -y \
    keystone \
    vim \
    python-pip \
    python-virtualenv
RUN sed 's/connection = sqlite:\/\/\/\/var\/lib\/keystone\/keystone.db/connection = mysql:\/\/root:password@mysql\/keystone/g' -i /etc/keystone/keystone.conf

COPY bootstrap-keystone.sh /etc/bootstrap-keystone.sh
RUN chown root:root /etc/bootstrap-keystone.sh && chmod a+x /etc/bootstrap-keystone.sh

ENTRYPOINT ["/etc/bootstrap-keystone.sh"]

EXPOSE 35357
EXPOSE 5000
