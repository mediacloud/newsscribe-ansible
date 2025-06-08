## Install and configure Media Cloud NewsScribe cluster

# NOTE!!!

These files are outside the story-indexer repo to reduce any
temptation to think that making changes is anything less than
dangerous and terrifying!!

To that end, it's as slim as possible, and tries to err on the side of
simplicity and transparency rather than ansible "best practices"
hiding things in playbooks and inventories directories.

We regard ansible as a necessary evil for system provisioning, not as
an end to itself!

This repo uses mediacloud/ansible-elastic, a clone of Elastic's no
longer supported playbook, LIGHTLY updated for ES8 & Debian, external
to this repo to keep this repo as small/simple as possible, and
FURTHER reduce temptation to change anything!!! (see "Development
advice" section below).

It would be *GREATLY* preferable to use *ONLY* ansible to do all
configuration of the NewsScribe cluster (and these scripts install an
motd (message of the day) file to that effect!

### make setup

Create venv with ansible and molecule with docker extensions.

### make test

Run molecule test (create four node ES cluster)
(must be run as root, or maybe a user in the docker group).

The only red output you should see are three WARNING messages for
unused test steps at the start, and repeated at the end of the run.

### es-install.sh

Script to run ansible to install ES cluster, runs es-install.yml playbook.

### es-inventory.yml

Server list and config for physical servers.

Supplies settings for all nodes (vars section) and per-node
(hosts section).

### es-vars.yml

Global default vars used by both molecule tests and full install.

### tasks/ directory

Actual ansible task lists to do work.  `all.yml` is included by both
molecule test and full install and runs on all remote nodes.

### molecule/default/ directory

Ansible playbooks for molecule testing

#### prepare.yml

Runs locally, checks out ansible-elasticsearch repo.

#### create.yml

Runs locally, creates a docker network and docker containers for test
nodes.  Containers run systemd to more fully simulate real servers.

#### converge.yml

Runs inside containers, includes `tasks/all.yml`

#### destroy.yml

Runs locally, before and after create/converge to clean up: stops and
removes the docker containers, docker network, and checkout of
ansible-elasticsearch repository.

## Development advice

1. If you're installing/configuring something new, create
   a new .yml file in the tasks directory and add it to all.yml
2. Test often, checkpoint by commiting your changes, or
   saving files.  YAML is a hostile programming environment,
   and it's easy to break stuff.
3. Use ansible `- debug: var=XXX` directives
   to check variable contents when debugging.
4. ansible is a pain, and "debug" (see above) is your friend,
   but in this case, your ansible files are being run by
   ansible playbooks being run by molecule, so you're in
   the deep end (a black box inside a black box).
5. Keep it simple, avoid changes, don't be a hero.
6. ALWAYS run "make test" (runs "molecule test")
   before opening a pull request, or pushing to
   a branch with an open PR.
7. Undefined variables are often the result of a problem (botch) in a "vars"
   file.  `/es-test-vars.sh` (runs locally as a regular user) can help
   you see what ansible is picking up.  Running
   `venv/bin/ansible-inventory -i es-inventory.yml --list`
   will test the es-inventory.yml file.  This is where having
   a saved copy of known working files can be a life saver!

When you need to do a post-mortem on a container, you can disable
container destruction by running `molecule test --destroy=never`
(AFTER sourcing venv/bin/activate: molecule expects `ansible-xxx`
commands to be found in `PATH`). This allows you to inspect the state
of the containers (eg; with `docker exec -it es-test-N bash`).
*BUT* if you don't run `molecule destroy` before the next `molecule
test` the old containers will be left in place which may confound your
tests, so always run a clean `make test` (or `molecule test`) before
considering your changes tested.

Should it be necessary to make a change to ansible-elasticsearch
uncomment the line
`#mc_es_ansible_elasticsearch_force_checkout_cleanup: false` in
`molecule/default/vars.yml`: this will leave prevent removal or
overwrite of the `molecule/default/tmp/ansible-elasticsearch` clone of
the ansible-elasticsearch repo.  *DO NOT* commit this change to
vars.yml!!!

`ansible-elasticsearch` is being used as the least unpleasant solution
for installing ES8.  It's being used in the LEAST modified form
possible.  So it contains many steps that are no-ops, but have been
left in place should someone else find the repo helpful, or in case we
need them in the future.  The most likely case for a change is that
some step needs to be disabled, in which case the polite thing to do
is put the offending operation under `when: es_some_new_variable` and
add `es_some_new_variable: true` to
`ansible-elasticsearch/vars/main.yml` and add `es_some_new_variable:
false` to `newsscribe-ansible/es-vars.yml` (ie; see `es_certificates`,
which was disabled because it didn't run as-is under molecule).
