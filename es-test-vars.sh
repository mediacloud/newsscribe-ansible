#!/bin/sh

# command to run es-test-vars.yml playbook
# for testing es-inventory.yml and es-vars.yml

make setup
venv/bin/ansible-playbook \
    --connection local \
    -i es-inventory.yml \
    $* \
    es-test-vars.yml
