#!/bin/bash

HTTPS_ENABLED=${HTTPS_ENABLED:-false}
if $HTTPS_ENABLED; then
    HTTP="https"
    CN=${CN:-$HOSTNAME}
    # generate keystone ssl certs.
    mkdir -p /etc/apache2/ssl
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout /etc/apache2/ssl/keystone.key -out /etc/apache2/ssl/keystone.crt \
        -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORG/OU=$ORG_UNIT/CN=$CN"
else
    HTTP="http"
fi

keystone-manage db_sync

keystone-manage bootstrap \
    --bootstrap-password password \
    --bootstrap-username admin \
    --bootstrap-project-name admin \
    --bootstrap-role-name admin \
    --bootstrap-service-name keystone \
    --bootstrap-region-id RegionOne \
    --bootstrap-admin-url "$HTTP://$HOSTNAME:35357/v3" \
    --bootstrap-public-url "$HTTP://$HOSTNAME:5000/v3" \
    --bootstrap-internal-url "$HTTP://$HOSTNAME:5000/v3"


export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_AUTH_URL=$HTTP://${HOSTNAME}:5000/v3

export OS_IDENTITY_API_VERSION=3
export OS_AUTH_VERSION=3


echo "ServerName $HOSTNAME" >> /etc/apache2/apache2.conf

if $HTTPS_ENABLED; then
export OS_CACERT=/etc/apache2/ssl/keystone.crt
a2enmod ssl
sed -i '/<VirtualHost/a \
    SSLEngine on \
    SSLCertificateFile /etc/apache2/ssl/keystone.crt \
    SSLCertificateKeyFile /etc/apache2/ssl/keystone.key \
    ' /etc/apache2/sites-available/keystone.conf
fi

a2ensite keystone

service apache2 restart

sleep 5

openstack role create SwiftOperator
openstack role create ResellerAdmin
openstack role create service
openstack role create _member_

openstack service create --name swift --description "Swift Object Storage Service" object-store

openstack endpoint create --region RegionOne swift public "$HTTP://127.0.0.1:8080/v1/AUTH_\$(tenant_id)s"
openstack endpoint create --region RegionOne swift internal "$HTTP://127.0.0.1:8080/v1/AUTH_\$(tenant_id)s"
openstack endpoint create --region RegionOne swift admin "$HTTP://127.0.0.1:8080/v1"


openstack project create service

openstack user create --domain default --password password  --project service swift
openstack role add --project service --user swift admin

openstack project create test

openstack user create --domain default --password testing --project test tester
openstack role add --project test --user tester admin

openstack project create test2

openstack user create --domain default --password testing2 --project test tester2
openstack role add --project test2 --user tester2 admin

openstack user create --domain default --password testing3 --project test tester3
openstack role add --project test --user tester3 _member_

openstack domain create --description "Test Domain" test-domain
openstack project create --domain test-domain test4

openstack user create --domain test-domain --password testing4 --project test4 tester4
openstack role add --project test4 --user tester4 admin

openstack project create --domain default test5

openstack user create --domain default --password testing5 --project test5 tester5
openstack role add --project test5 --user tester5 service

openstack user create --domain default --password testing6 --project test tester6
openstack role add --project test --user tester6 ResellerAdmin

#keep this container running
tail -f /dev/null
