# Packer base templates

A collection of base OS templates.

## Usage

For CI purposes, the `maketemplate.py` was built.

```
$ python maketemplate.py -h
usage: maketemplate.py [-h] [--debug] [--skip-build] [--packer PACKER]
                       --varfile VARFILE

Build Packer Template

optional arguments:
  -h, --help         show this help message and exit
  --debug            enable verbose logging
  --skip-build       skip packer build. For testing only.
  --packer PACKER    packer binary to use
  --varfile VARFILE  packer var file to use
```

This will read a variable file, extract the template to use from it and build it using packer. After this, it creates or updates an `ovfindex.xml` file (check [OVF RepositorySpace](http://wiki.abiquo.com/display/doc/Template+Repository+Reference#TemplateRepositoryReference-OVFIndexFile-ovfindex.xml))

## Testing

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
