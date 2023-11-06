## Set up an OpenShift cluster
### Local
Requirements: RedHat account, Device with at least 10GB of RAM capable of nested virtualization.

CRC is an OpenShift distribution that runs on your local development machine, on MAc and windows it is using a virtual machine. It can be downloaded from RedHat via [crc.dev](https://crc.dev).

After downloading the CLI the cluster can be created with `crc setup` and `crc start`.

### Cloud
xRequirements: AWS account with EC2 CPU limtit >= 100, RedHat Account, Device that can run the ROSA CLI.

ROSA ([RedHat OpenShift on AWS](https://www.redhat.com/en/technologies/cloud-computing/openshift/aws)) is a managed OpenShift distribution that runs on AWS. To use ROSA, your AWS account and your RedHat account must be linked. The process can be started from either side. 
I recommend to log into your AWS account and search for ROSA in the service catalog. The dialog will check the requirements and redirect you to RedHat if your account can be connected. You may need to request to increase the max EC2 CPU quota for the region you are working with to 100 or more.
You can then download the ROSA CLI to guide you through the process. The web interface also provides useful information and visualizes the process.

## Installing crun+spin
This repository contains binary build of a not yet merged crun handler and staticly build binaries of the spin CLI. Both are currently in the process of being contributed upstream.

### test setup
connect to your cluster and ose either `kubectl` or `oc` to create a new RuntimeClass and a deployment with the test image from the `containerd-wasm-shims` repository. The pods should stay in `creating` state.
```
echo '
  apiVersion: node.k8s.io/v1                                           
  kind: RuntimeClass
  metadata:
    name: crun-spin
  handler: crun-spin' | oc apply -f -

echo '
  apiVersion: apps/v1                                                  
  kind: Deployment
  metadata:
    name: wasm-spin
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: wasm-spin
    template:
      metadata:
        labels:
          app: wasm-spin
      spec:
        runtimeClassName: crun-spin
        containers:
        - name: spin-hello
          image: ghcr.io/deislabs/containerd-wasm-shims/examples/spin-rust-hello:latest
          command: ["/"]
' | oc apply -f -
```

Now apply the Daemonset from this repository to install crun-spin and the static spin cli on the nodes. Result should be that the test deployment changes to `running` state.
The spin app is running on port `3000` if forwarded to localhost. You can access it at [localhost:3000/hello](http://localhost:3000/hello).

```
oc apply -f daemonset.yaml
# wait a few seconds untill it is done and forward the port to your local host
oc port-forward deployment/wasm-spin 3000:3000
# if you are working on ROSA you can also expose the port to the public internet
oc expose deployment wasm-spin --port 3000
oc expose service/wasm-spin
```
