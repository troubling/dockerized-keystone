# dockerized-keystone
Keystone Docker instance for Hummingbird/Swift SAIO

This helps to run [Keystone](https://github.com/openstack/keystone) in a container which you can spin up & down for Hummingbird/Swift SAIO.

You can run Keystone with http(default) or https( -e HTTPS_ENABLED=true)

## For HTTP:
Just use `make bootstrap` to build & run keystone container in http mode.

## For HTTPS:
In order to run keystone with TLS, you need to supply certificate, key and ca bundle.

It expects following files to be present:
```
$pwd/ssl/keystone.crt
$pwd/ssl/keystone.key
$pwd/ssl/ca.crt
```

Now run `make bootstrap-ssl` to build & run keystone container in https mode.

You can provide hostname with `-h {hostname}` with docker run.

You can use `docker logs -f keystone` to check on bootstrap progress


In order to run swift functional tests with this keystone, you will need to make following changes:

diff swift/doc/saio/swift/proxy-server.conf /etc/swift/proxy-server.conf
```diff swift/doc/saio/swift/proxy-server.conf /etc/swift/proxy-server.conf
7a8
> tempauth_enabled = false
12c13,14
< pipeline = catch_errors gatekeeper healthcheck proxy-logging cache bulk tempurl ratelimit crossdomain container_sync tempauth staticweb copy container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server
---
> pipeline = catch_errors gatekeeper healthcheck proxy-logging cache bulk tempurl ratelimit crossdomain container_sync authtoken keystoneauth staticweb copy container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server
72a75
> object_post_as_copy = true
77a81,101
>
> [filter:authtoken]
> paste.filter_factory = keystonemiddleware.auth_token:filter_factory
> auth_uri = http://127.0.0.1:5000/
> auth_url = http://127.0.0.1:35357/
> auth_plugin = password
> project_domain_id = default
> user_domain_id = default
> project_name = service
> username = swift
> password = password
> cache = swift.cache
> include_service_catalog = False
> delay_auth_decision = True
>
> [filter:keystoneauth]
> use = egg:swift#keystoneauth
> reseller_prefix = AUTH, GLANCE
> operator_roles = admin, swiftoperator
> reseller_admin_role = ResellerAdmin
> GLANCE_service_roles = service
```
diff swift/test/sample.conf /etc/swift/test.conf
```diff swift/test/sample.conf /etc/swift/test.conf
3,6c3,6
< auth_host = 127.0.0.1
< auth_port = 8080
< auth_ssl = no
< auth_prefix = /auth/
---
> #auth_host = 127.0.0.1
> #auth_port = 8080
> #auth_ssl = no
> #auth_prefix = /auth/
10,14c10,14
< #auth_version = 3
< #auth_host = localhost
< #auth_port = 5000
< #auth_ssl = no
< #auth_prefix = /v3/
---
> auth_version = 3
> auth_host = localhost
> auth_port = 5000
> auth_ssl = no
> auth_prefix = /v3/
32,35c32,35
< #account4 = test4
< #username4 = tester4
< #password4 = testing4
< #domain4 = test-domain
---
> account4 = test4
> username4 = tester4
> password4 = testing4
> domain4 = test-domain
43,45c43,45
< #account5 = test5
< #username5 = tester5
< #password5 = testing5
---
> account5 = test5
> username5 = tester5
> password5 = testing5
60c60
< #service_prefix = SERVICE
---
> service_prefix = GLANCE
64,66c64,66
< #account6 = test
< #username6 = tester6
< #password6 = testing6
---
> account6 = test
> username6 = tester6
> password6 = testing6
```

