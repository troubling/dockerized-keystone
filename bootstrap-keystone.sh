#!/bin/bash

keystone-manage db_sync

keystone-manage bootstrap \
    --bootstrap-password password \
    --bootstrap-username admin \
    --bootstrap-project-name admin \
    --bootstrap-role-name admin \
    --bootstrap-service-name keystone \
    --bootstrap-region-id RegionOne \
    --bootstrap-admin-url http://localhost:35357 \
    --bootstrap-public-url http://localhost:5000 \
    --bootstrap-internal-url http://localhost:5000


service keystone start

sleep 5

export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://127.0.0.1:5000/v3

export OS_IDENTITY_API_VERSION=3
export OS_AUTH_VERSION=3

openstack role create SwiftOperator
openstack role create ResellerAdmin
openstack role create service
openstack role create _member_

openstack service create --name swift --description "Swift Object Storage Service" object-store

openstack endpoint create --region RegionOne swift public "http://127.0.0.1:8080/v1/AUTH_\$(tenant_id)s"
openstack endpoint create --region RegionOne swift internal "http://127.0.0.1:8080/v1/AUTH_\$(tenant_id)s"
openstack endpoint create --region RegionOne swift admin "http://127.0.0.1:8080/v1"


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
