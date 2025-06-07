#!/bin/sh

echo 'THIS HAS NOT BEEN TESTED!'
exit 1

# run es-install.yml playbook:
venv/bin/ansible-playbook \
    -i es-inventory.yml \
    $* \
    es-install.yml
