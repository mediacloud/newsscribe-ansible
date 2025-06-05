#!/bin/sh
# create venv w/ ansible:
make setup
# run es-install.yml playbook:
venv/bin/ansible-playbook \
    -i es-inventory.yml \
    $* \
    es-install.yml
