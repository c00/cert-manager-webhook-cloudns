# Cert-Manager ClouDNS DNS01 Provider

A Cert-Manager DNS01 provider for ClouDNS.

## Installation

You should make your own docker image and push it to your own repository. Then generate the manifests to apply them to your cluster.

### Make your own docker image

Go to `./makefile` and adjust the first 3 lines.

The `IMAGE_NAME` should be the location of your docker repo. If you are using docker hub, just putting `[username]/[reponame]` will work.

For the `IMAGE_TAG`, the most reasonable thing to do is to change it to the latest tag of the git repo. This doesn't affect anything, but is good practice for clarity.

Namespace is the k8s namespace. You can leave this as it is.

Now you can build the docker image, push it and generate the resources for k8s.

```sh
# Build the Docker image
make build

# Push it to your docker repository
make push

# Create the resources, found in ./.out/rendered-manifest.yaml
make rendered-manifest.yaml
```

Before applying the manifest create a secret that contains the auth id and api key from Cloudns. Copy the file `./deploy/secrets/cloudns-api.yaml.sample` to `./deploy/secrets/cloudns-api.yaml`, and adjust the new file. Set your authId and auth password in it. If you are using a different namespace, make sure to also set the correct namespace in the secret.

Now apply your secret to the cluster (e.g. `kubectl apply -f ./deploy/secrets/cloudns-api.yaml`) and then apply the rendered manifest (e.g. `kubectl apply -f ./.out/renered-manifest.yaml`).

If this is a private docker repo, make sure to also add your docker credentials to the namespace.

## Note

This fork has `update-deps` branch merged and a few other changes that it works with recent versions of **Kubernetes** (1.23+) and **cert-manager** (1.7.2) to avoid errors and warnings. The github workflow builds images for `amd64` and `arm64`.

## Configuration

Cert-Manager expects DNS01 providers to parse configuration from incoming webhook requests.

This can be used to have multiple Cert-Manager `Issuer` resources use the same instance of the provider with different credentials or configuration.

Because we currently don't need this and the LEGO library already has support for parsing environment variables (and files), we have opted to not use this.

The `testdata/config.json` file is there because the DNS01 provider conformance testing suite wants to mock the requests away, and needs a folder to load the data from.

### Environment Options

| Name                         | Required                | Description                                                       |
| ---------------------------- | ----------------------- | ----------------------------------------------------------------- |
| `GROUP_NAME`                 | yes                     | Used to organise cert-manager providers, this is usually a domain |
| `CLOUDNS_AUTH_ID_FILE`       | yes                     | Path to file which contains ClouDNS Auth ID                       |
| `CLOUDNS_AUTH_PASSWORD_FILE` | yes                     | Path to file which contains ClouDNS Auth password                 |
| `CLOUDNS_TTL`                | no, default: 60         | ClouDNS TTL                                                       |
| `CLOUDNS_HTTP_TIMEOUT`       | no, default: 30 seconds | ClouDNS API request timeout                                       |

## Development

### Running DNS01 provider conformance testing suite

```bash
# Get kubebuilder
./scripts/fetch-test-binaries.sh

# Run testing suite
TEST_ZONE_NAME=<domain> CLOUDNS_AUTH_ID_FILE=.creds/auth_id CLOUDNS_AUTH_PASSWORD_FILE=.creds/auth_password go test -v .
```
