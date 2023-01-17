# Teleport in docker

This is a docker container that contains teleport and kubectl plus some QOL improvements
to provide a separated environm,ent when accessing remote clusters via teleport.

There is no dependencies needed on your local machine besides docker.

The teleport session will reside in your machines home folder ready for reuse, while the critical
kube context is inside your container.

No accidential mix up of local dev environmnet with production systems possible :)

## build

### For x86_64 systems:

```bash
$ docker build -t teleport .
```

### For ARM systems

(currently untested due to the lack of an arm system)

```bash
$ docker build -t teleport --build-arg CLOUDCLI_ARCH=arm .
```

## Run

Add the following settings to your bashrc or export them in any other way in your shell.

__*Adjust the valuies correspondingly*__

```bash
export TELEPORT_PROXY="xxxx.teleport.sh:443"
export PROD_ROLES="xxxx-production-user"
```

You can start the container by running

```bash
./teleport
```
