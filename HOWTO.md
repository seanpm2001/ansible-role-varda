How to use the Varda Ansible role
=================================

[Ansible](http://www.ansible.com/) is an automation platform for application
and systems deployment. Deployments are described by *playbooks* which
leverage *roles* for composition and reuse.

The Varda Ansible role can be used to deploy a complete Varda environment from
an Ansible playbook. The environment will include the Varda API, Celery task
scheduler, Aulë web interface, HTTPS configuration, etcetera. Here we describe
the steps needed to get a Varda environment using this role.

If you're just looking for a quick deployment on a local virtual machine
without any configuration needed, have a look at the [vagrant](vagrant)
directory.


Install Ansible
---------------

We need Ansible 2.0.1 or higher.

    pip install ansible


Get the role and its dependencies
---------------------------------

Download all needed Ansible roles in the `roles` directory.

```bash
mkdir roles
git clone https://github.com/varda/ansible-role-varda.git roles/varda
git clone https://git.lumc.nl/humgen-devops/ansible-role-exim.git roles/exim
git clone https://git.lumc.nl/humgen-devops/ansible-role-mail-service-status.git roles/mail-service-status
git clone https://git.lumc.nl/humgen-devops/ansible-role-nginx.git roles/nginx
git clone https://git.lumc.nl/humgen-devops/ansible-role-postgresql.git roles/postgresql
git clone https://git.lumc.nl/humgen-devops/ansible-role-redis.git roles/redis
```


Provision a host machine
------------------------

Find or create a machine with Debian 8 (Jessie) installed and an SSH
server. We will refer to its IP address as `VARDA_IP`.

The machine must also have a user with sudo rights, which we will refer to as
`VARDA_USER`.


Create a playbook
-----------------

Create a file `playbook.yml` with contents like the following:

```yml
---
- name: deploy varda
  hosts: varda
  become: yes
  roles: [exim, varda]
  pre_tasks:
  - name: update apt cache
    apt: update_cache=yes
```


Create an inventory
-------------------

An inventory file is where you define your infrastructure for Ansible. In this
case, we have just one machine which we call `varda`. In the inventory, we
define its IP address and the user to login as:

    varda ansible_host=VARDA_IP ansible_user=VARDA_USER

Save this file as `inventory`.


Run the playbook
----------------

Now run the playbook, specifying the inventory and having Ansible ask for the
`VARDA_USER` password:

    ansible-playbook -i inventory -k playbook.yml

This will take quite a while.


Enjoy your Varda
----------------

You can now open a browser and go to https://VARDA_IP to use your new Varda
installation from the Äule web interface.


Customize the deployment
------------------------

Above we used default settings for all roles, but many of them provide
variables we can customize. We can do this by creating a host vars file:

```bash
mkdir host_vars
touch host_vars/varda.yml
```

For example, we can have the following in `host_vars/varda.yml` to use a
custom hostname, another SSL certificate than the default insecure one, and a
certain Git branch to get the Varda source code from:

```yml
---
varda_server_name: varda.example.com
varda_certificate: "{{ inventory_dir }}/varda.example.com.crt"
varda_certificate_key: "{{ inventory_dir }}/varda.example.com.key"
varda_git_branch: mynewfeature
```

Please consult the role documentation for a list of variables each role
provides.
