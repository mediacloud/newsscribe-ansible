#!/bin/sh

# command to run es-test-vars.yml playbook
# for testing/dumping es-vars.yml

make setup
venv/bin/ansible-playbook \
    --connection local \
    -i es-test-inventory.yml \
    $* \
    es-test-vars.yml
