Install and configure Media Cloud NewsScribe cluster

* make setup

create venv with ansible installed, plus populate

* make test

run molecule test (create four node ES cluster)
(must be run as root, or maybe a user in the docker group)

* es-install.sh

Script to run ansible to install ES cluster, runs es-install.yml playbook.

* es-vars.yml

Global vars used by both molecule tests and full install.
