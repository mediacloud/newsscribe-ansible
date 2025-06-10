## Install and configure Media Cloud NewsScribe cluster

# NOTE!!!

These files are outside the story-indexer repo to reduce any
temptation to think that making changes is anything less than
dangerous and terrifying!!

To that end, it's as slim as possible, and tries to err on the side of
simplicity and transparency rather than ansible "best practices" with
files spread across multiple directories (vars, playbooks, inventories).

We regard ansible as a necessary evil for system provisioning, not as
an end to itself!

This repo uses mediacloud/ansible-elastic, a clone of a clone of
Elastic's no longer supported playbook, LIGHTLY updated for ES8 &
Debian, external to this repo to keep this repo as small/simple as
possible, and FURTHER reduce temptation to change anything!!! (see
"Development advice" section below).

It would be *GREATLY* preferable to use *ONLY* ansible to do all
configuration of the NewsScribe cluster (and these scripts install an
motd (message of the day) file to that effect!

### make setup

Create venv with ansible and molecule with docker extensions.

### make test

Run `molecule test` (create four node ES cluster using Docker);
must be run as root.

The only red output you should see are a few WARNING messages at the
beginning and end.

There is no provision for per-user or staging realms:
only one user can run tests on a given docker host system!

### es-install.sh

Script to run ansible to install ES cluster, runs es-install.yml playbook.

Must be run on a clean checkout of the `prod` branch.

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

Ansible playbooks for molecule testing.
See molecule/default/README.md for more info.

## Development advice

These scripts make changes to servers that are a critical resource.
If you're not even a little nervous about making changes, you're
almost certainly hazardous.

All locally added variables should start with mc_, ones related
to elastic search should start with mc_es_

1. If you're installing/configuring something new, create
   a new .yml file in the tasks directory and add it to all.yml.
   You can test the task locally by (temporarily!) adding an include_task
   to the end of es-test-vars.yml and running ./es-test-vars.yml
2. Test often, checkpoint by commiting your changes, or
   saving files.  YAML is a hostile programming environment,
   and it's easy to break stuff.
3. You can use ansible `- debug: var=XXX` directives
   to check variable contents when debugging.
4. ansible is always an opaque black box,
   but in this case, your ansible files are being run by
   ansible playbooks being run by molecule, so you're in
   a double black box!
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
8. When the choice is to do something simply vs handling
   all/general cases via an external module, the choice was
   to do the simple thing.

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
`molecule/default/vars.yml`: this will prevent removal or
overwrite of the `molecule/default/tmp/ansible-elasticsearch` clone of
the ansible-elasticsearch repo, so you can develop changes in place.
*DO NOT commit this change to vars.yml*!!!

`ansible-elasticsearch` is being used as the least unpleasant solution
for installing ES8.  It's being used in the LEAST modified form
possible, so it contains many steps that are no-ops, but have been
left in place should someone else find the repo helpful, or in case we
need them in the future.  The most likely case for a change is that
some step needs to be disabled, in which case the polite thing to do
is put the offending operation under `when: es_some_new_variable` and
add `es_some_new_variable: true` to
`ansible-elasticsearch/vars/main.yml` and add `es_some_new_variable:
false` to `newsscribe-ansible/es-vars.yml` (ie; see `es_certificates`,
which was disabled because it didn't run as-is under molecule).

This repo has a pre-commit hook, installed by `make setup`' it runs
checks to remove end-of-line whitespace, mising end-of-file newlines,
basic yaml checks, and `yamlfix` to try to keep the files consistently
formatted, and `ansible-lint` set to "production" criteria.

There *INTENTIONALLY* isn't a variable that says whether you're
running under Docker or not because of the temptation to check it
often, which would undermine the whole point of testing under Docker!!!
