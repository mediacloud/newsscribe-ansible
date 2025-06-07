## Install and configure Media Cloud NewsScribe cluster

### make setup

Create venv with ansible installed.

### make test

Run molecule test (create four node ES cluster)
(must be run as root, or maybe a user in the docker group)

### es-install.sh

Script to run ansible to install ES cluster, runs es-install.yml playbook.

### es-inventory.sh

Server list and config for physical servers.

### es-vars.yml

Global vars used by both molecule tests and full install.

### tasks/

Actual ansible task lists to do work used by both molecule tests and full install.

### molecule/default/

Ansible playbooks for molecule testing
