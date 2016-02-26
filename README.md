Ansible role for Varda
======================


This role deploys the database for genomic variation frequencies
[Varda](https://varda.readthedocs.org/).

New here? Check out [How to use the Varda Ansible role](HOWTO.md).


Table of contents
-----------------

- [Requirements](#requirements)
- [Description](#description)
- [Dependencies](#dependencies)
- [Variables](#variables)
- [Local deployment with Vagrant](#local-deployment-with-vagrant)


Requirements
------------

- Debian 8 (Jessie) with a configured MTA
- Ansible version 2.0.1


Description
-----------

The deployment uses the following tools:

- [nginx](http://nginx.org/) as reverse proxy for Gunicorn and for serving
  static files.
- [systemd](http://freedesktop.org/wiki/Software/systemd/) for process
  control.
- [Gunicorn](http://gunicorn.org/) as WSGI HTTP server.
- [virtualenv](http://virtualenv.readthedocs.org/) for isolation of the Varda
  package and its Python dependencies.
- [PostgreSQL](http://www.postgresql.org/) for the database.
- [Redis](http://redis.io/) for message broker and task result backend.

Two applications are served by nginx:

- Varda RESTful HTTP API: `https://<servername>/api`
- Aulë web interface: `https://<servername>/`


### Files and directories

Logging is done at several levels in this stack:

- Varda API Gunicorn log: `/opt/varda/versions/*/log/api.log`
- Varda Celery log: `/opt/varda/versions/*/log/celery.log`
- nginx access and error log: `/var/log/nginx/`
- redis server logs: `/var/log/redis/`
- PostgreSQL server logs: `/var/log/postgresql/`

Tool configurations can be found here (but you should never manually touch
them):

- Varda configuration: `/opt/varda/versions/*/conf/settings.py`
- Aulë configuration: `/opt/varda/src/aule/web/scripts/config.coffee`
- Varda API Gunicorn configuration: `/opt/varda/versions/*/conf/api.conf`
- Varda Celery configuration: `/opt/varda/versions/*/conf/celery.conf`
- nginx configuration: `/etc/nginx/sites-available/varda`

All Varda processes run as user `varda`, which is also the owner of everything
under `/opt/varda`. Some other Varda related locations are:

- Varda data: `/opt/varda/data/`
- Varda reference genome: `/opt/varda/genome/`
- Varda Git clone: `/opt/varda/src/varda/`
- Aulë Git clone: `/opt/varda/src/aule/`
- Varda versions: `/opt/varda/versions/`


### Zero-downtime deployments

In order to obtain zero-downtime deployments, we fix and isolate deployment
versions. A version is identified by its Git commit hash and contains a Python
virtual environment, configuration files, log files, and a unix socket for the
API. Several versions can co-exist, but only one version is active
(published).

The deployment of a new version is done when the Varda Git repository checkout
changes:

1. Create the new version in `/opt/varda/versions/<git commit hash>/`.
2. Run unit tests (if enabled, see variables below).
3. Run database migrations.
4. Start the new Gunicorn API.
5. Test the availability of the API.
6. Stop running Celery and start a new one.
7. Reload nginx with the new Gunicorn upstream.
8. Stop the old Gunicorn API (first completing all its pending requests).

In step 7, nginx will complete all existing requests from the old
configuration while accepting requests with the new configuration, so this is
zero-downtime.

The order above also means database migrations must always keep compatibility
with the existing codebase, so some may have to be broken down into several
steps and completed over several deployments.


### User environment

The `~/.bashrc` file for user `varda` activates the Varda Python virtual
environment and sets the `VARDA_SETTINGS` environment variable. Administrative
work is best done as that user:

    sudo -u varda -i

Please note that you should re-source `~/.bashrc` in any existing shell
sessions after deploying a new Varda version, to switch to the current virtual
environment.


Dependencies
------------

This role depends on the following roles:

### `postgresql`

https://git.lumc.nl/humgen-devops/ansible-role-postgresql

Variable overrides:

    postgresql_databases:
      - name: varda
        encoding: UTF8
        lc_collate: 'en_US.UTF-8'
        lc_ctype: 'en_US.UTF-8'
        backup: true

    postgresql_users:
      - name: varda
        password: "{{ varda_database_password }}"
        attributes: NOSUPERUSER,NOCREATEDB
        database_privileges:
          - database: varda
            privileges: ALL

### `redis`

https://git.lumc.nl/humgen-devops/ansible-role-redis

### `nginx`

https://git.lumc.nl/humgen-devops/ansible-role-nginx

### `mail-service-status`

https://git.lumc.nl/humgen-devops/ansible-role-mail-service-status


Variables
---------

Also see variables of dependencies.

### `varda_certificate`

Default: `localhost-insecure.crt` (self-signed certificate for `localhost`)

SSL certificate file.

### `varda_certificate_key`

Default: `localhost-insecure.key`

SSL certificate keyfile.

### `varda_database_password`

Default: `insecure_password`

Password for the PostgreSQL database user.

### `varda_admin_password`

Default: `$2a$12$K5b7FEntllDWUDKqEcYmyu9hJyWWpB.9VTdAWJJW2Y9iOayFFdjui`
(hashed `insecure_password`)

Hashed password for the admin user. Can be computed in Python on a machine
with Varda installed as follows:

    >>> from varda.models import User
    >>> User.hash_password('my plaintext password')
    '$2a$12$pGK5H8c74SR0Zx0nqHQEU.6qTICkj1WUn1RMzN9NRBFmZFOGE1HF6'

### `varda_server_name`

Default: `localhost`

Server name by which Varda can be reached.

### `varda_api_proxy_read_timeout`

Default: 60

Nginx read timeout for the API Gunicorn upstream.

### `varda_api_worker_class`

Default: `sync`

Type of Gunicorn worker for the API. Must be one of `sync`, `eventlet`,
`gevent`.

### `varda_api_workers`

Default: 2

Number of Gunicorn workers for the API.

### `varda_api_timeout`

Default: 30

Timeout before killing silent Gunicorn workers for the API.

### `varda_celery_max_tasks_per_child`

Default: 4

Maximum number of tasks a Celery worker can execute before it’s replaced by a
new process.

### `varda_celery_concurrency`

Default: 3

The number of Celery worker processes.

### `varda_max_upload_size`

Default: 1073741824 (1GB)

Maximum size for uploaded files.

### `varda_genome`

Default: `null`

URL to gzipped reference genome fasta file.

### `varda_genome_sha256sum`

Default: `null`

SHA-256 checksum of the gzipped reference genome fasta file.

### `varda_chromosome_aliases`

Default: `[]`

Per chromosome, a list of name aliases.

### `varda_aule_my_gene_info`

Default: `null`

[MyGene.info](http://mygene.info/) configuration used for frequency lookup by
transcript in Aulë. This should be a dictionary with the following fields:

- `species`: Query MyGene.info for transcripts in this organism.
- `exons_field`: Field name in MyGene.info gene annotation containing a
  dictionary with coordinate data for each transcript. Coordinates should
  correspond with the reference genome of the Varda server.
- `email`: MyGene.info encourages regular users to provide an email, so that
  they can better track the usage or follow up with you. This field is
  optional.

Example:

    varda_aule_my_gene_info:
        species: human
        exons_field: exons_hg19

### `varda_prune_versions`

Default: `true`

Whether or not to remove old Varda versions, including their Python virtual
environment, log files, and configuration.

### `varda_unit_tests`

Default: `false`

Whether or not to run Varda unit tests. Deployment will be aborted if they
fail.

### `varda_git_repository`

Default: `https://github.com/varda/varda.git`

Varda Git repository URL to clone.

### `varda_git_branch`

Default: `master`

Varda Git repository branch to checkout.

### `varda_aule_git_repository`

Default: `https://github.com/varda/aule.git`

Aulë Git repository URL to clone.

### `varda_aule_git_branch`

Default: `master`

Aulë Git repository branch to checkout.


Local deployment with Vagrant
-----------------------------

Easy deployment on a local virtual machine using Vagrant is provided in the
[vagrant](vagrant) directory.
