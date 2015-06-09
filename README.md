# RDPG CF Service Checks

Simple application to provide checks for rdpg service from a CF app

After registering RDPG service broker with Cloud Foundry we can follow the 
workflow below in order to provision a service instances and then bind this application to it as follows.

# Workflow

Create a service instance,
```sh
cf create-service rdpg small rdpg-service-1
```

We can see the service listed now,
```sh
cf services
```

Deploy an application to our cloud foundry for testing,
```sh
git clone https://github.com/wayneeseguin/rdpg-cf-service-checks
cd rdpg-cf-service-checks
cf push
```
Note that this will push application named `rdpg-cf-service-checks` as per `manifest.yml` configuration by default.

Bind the application to the service we created above,
```sh
cf bind-service rdpg-cf-service-checks rdpg-service-1
```

Expose the binding to the application and restart the application so that
it connects to the database:
```sh
cf restage rdpg-cf-service-checks
```

Visit The web UI in the browser, for example on a development cloud foundry if 
our application once pushed is named `rdpg-cf-service-checks` we would visit:
[http://rdpg-cf-service-checks.10.244.0.34.xip.io](http://rdpg-cf-service-checks.10.244.0.34.xip.io)

Note that your specific domain URL will also show up if you run,
```sh
cf apps
```

If at any point in time a `cf` command fails, re-run it prepended with `CF_TRACE=true` 
to find out the details of the failure.

Application logs can also be examined,

```sh
cf logs rdpg-cf-service-checks --recent
```

## Development

Note that in development if the app can not connect to the database there is a 
workaround.
```sh
cat > everything.json <<EOF
[{ 
  "destination": "0.0.0.0-255.255.255.255",
  "protocol": "all" 
}]
EOF

cf create-security-group everything everything.json

cf bind-security-group everything ${USER} rdpg
```
(The issue is with default bosh-lite security groups)
