# dockerized-keystone
Keystone Docker instance for Hummingbird/Swift SAIO

This helps to run [Keystone](https://github.com/openstack/keystone) in a container which you can spin up & down for Hummingbird/Swift SAIO.

Just use `make bootstrap` to build & run keystone container.

You can use `docker logs -f keystone` to check on bootstrap progress
