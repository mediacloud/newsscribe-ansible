started w/ "molecule init scenario --driver-name docker"
which created converge.yml and molecule.yml

### molecule.yml

Molecule configuration

### vars.yml

Variables used by multiple playbooks

### Other .yml files

`molecule test` runs the following playbooks if they exist:
dependency, cleanup, destroy, syntax, create, prepare, converge,
idempotence (re-runs converge(?) again to make sure nothing changes),
side_effect, cleanup, destroy.

#### create.yml

Runs locally, creates Docker network and containers.

#### converge.yml

Runs on each container, installs ES, tests cluster is up.

#### destroy.yml

Destroys Docker network, removes temp files.  Runs at start to ensure
clean starting environment, and again at end to clean up.

See top level README.md for development advice, and how to stop
world destruction, and do post-mortems on failures.

#### prepare.yml

Runs locally, clones ansible-elasticsearch git repo.
