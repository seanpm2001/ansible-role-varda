Local deployment with Vagrant
=============================

Tested with Vagrant 1.7.4.

This provides easy deployment on a local virtual machine using Vagrant. The
configuration is based on a
[Debian 8 (Jessie) box](https://atlas.hashicorp.com/debian/boxes/jessie64).


Usage
-----

Role dependencies are configured using git submodules, so fetch those first:

    git submodule init
    git submodule update

To get a machine up, run:

    vagrant up

If you just want to re-play the Ansible playbook, run:

    vagrant provision

You can SSH into the machine with:

    vagrant ssh

Running Ansible manually can be done like this:

    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml playbook.yml

(Unfortunately, there seems to be no easier way to disable host key checking
for the Vagrant host only.)


Configuration
-------------

The machine configuration can be changed by setting the following environment
variables:

### `VARDA_IP`

Default: 192.168.111.224

IP address of the virtual machine.

### `VARDA_PORT_FORWARD_SSH`

Default: 2524

Local port forward for SSH (VM port 22).

### `VARDA_PORT_FORWARD_HTTP`

Default: 8090

Local port forward for HTTP (VM port 80).

### `VARDA_PORT_FORWARD_HTTPS`

Default: 8091

Local port forward for HTTPS (VM port 443).

### `VARDA_MEMORY`

Default: 1024

Memory for the VM (in megabytes).

### `VARDA_CORES`

Default: 1

Number of cores for the VM.


Notes
-----

The Varda API and Aulë can be accessed over HTTPS on
[localhost port 8091](https://localhost:8091/) or
[VM port 443](https://192.168.111.224/).

The self-signed SSL certificate is valid for:

- `varda.local`
- `localhost`
- 192.168.111.224
- 127.0.0.1

Since Varda needs an MTA, Exim is installed and configured for local delivery
only.
