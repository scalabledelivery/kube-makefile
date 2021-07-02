# kube-makefile
This is an example application that you can use to develop Kubernetes applications locally on Docker for Desktop.

It is designed so that `make run` will build the Dockerfile, replace placeholders in `manifests/deploy.tpl.yaml`, and apply the deploy manifest. 

The `toolbox` directory is meant to hold helper scripts for both development and production.

If you run `make build` a production manifest will be produced at `manifests/deploy.yaml`. 

Customize `Makefile` to fill your needs. This is just an example project.

## Launch a Shell
Assuming that the application is currently being ran.
```text
make shell
```

## Cleanup
If a build fails, just run `make clean` and it will handle deleting the deployment an deleting `manifests/deploy.yaml`.
