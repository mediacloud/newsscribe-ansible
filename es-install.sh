#!/bin/sh

DEBUG=1
if [ "$xDEBUG" != x ]; then
    fatal() {
	echo debug: continuing
    }
    quit_if_debug() {
	exit
    }
else
    fatal() {
	exit 1
    }
    quit_if_debug() {
	true
    }
fi

UNAME=$(whoami)
if [ "x$UNAME" = xroot ]; then
   echo run as regular user 1>&2
   fatal
fi

# TEMP!!! replace philbudne with mediacloud!!!
UPSTREAM=$(git remote -v | awk '/git@github.com:philbudne\/newsscribe-ansible.git/ { print $1; exit }')
if [ "x$UPSTREAM" = x ]; then
    echo no upstream remote found 1>&2
    fatal
fi
echo upstream repo $UPSTREAM
git remote get-url $UPSTREAM

BRANCH=$(git branch --show-current)
if [ "x$BRANCH" != prod ]; then
    echo not on prod branch 1>&2
    fatal
fi

# checks for valid ssh key (but not write privs!)
if ! git fetch $UPSTREAM; then
    echo git fetch failed 1>&2
    fatal
fi

if ! git diff --quiet; then
    echo repo is dirty 1>&2
    fatal
fi

if ! git diff --quiet $UPSTREAM/prod; then
    echo repo has not been pushed/merged 1>&2
    fatal
fi

# XXX "git push --dry-run" to test for write permission (pushing tag)?

TMP=$(awk '/mc_tmp:/ { print $2 }' es-vars.yml)
if [ -d tmp ]; then
   echo tmp directory exists 1>&2
   exit 1
fi

# get mc_es_ansible_elasticsearch_repo from es-vars.yml?
ANSIBLE_ELASTIC_REPO=$(awk '/^mc_es_ansible_elasticsearch_repo:.*git@github.com/ { print $2 }' es-vars.yml)
mkdir $TMP
cd $TMP
if ! git clone $ANSIBLE_ELASTIC_REPO; then
    echo git clone failed 1>&2
    exit
fi
quit_if_debug

TAG=${UNAME}-$(date '%Y-%m-%d-%H-%M-%S')
# run es-install.yml playbook:
if sudo venv/bin/ansible-playbook -i es-inventory.yml $* es-install.yml; then
    echo "SUCCESS!! applying tag $TAG and pushing to $ORIGIN"
    git tag $TAG
    git push $ORIGIN $TAG

    echo "applying $TAG to ansible-elasticsearch"
    cd tmp/ansible-elasticsearch
    git tag $TAG
    git push origin $TAG

    echo removing tmp directory
    rm -rf tmp
echo
    echo FAILED -- not tagged
fi
