# Packer base templates

A collection of base OS templates.

## Usage

The list of available templates is found in the `templates/` directory. Some of them can be used to build more than one version of a template. For example, using `centos.json` you can build CentOS 6 and 7:

```
$ packer build -var-file vars/centos6 templates/centos.json
$ packer build -var-file vars/centos7 templates/centos.json
```

You can also override variables for testing:

```
$ packer build -var iso_url=http://some.site/new.iso -var iso_checksum=xxxxxx -var-file vars/centos6 templates/centos.json
```

# Work in progress
