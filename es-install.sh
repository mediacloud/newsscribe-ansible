#!/bin/sh

fatal() {
    exit 1
}

UNAME=$(whoami)
if [ "x$UNAME" = xroot ]; then
   echo run as regular user 1>&2
   fatal
fi

UPSTREAM=$(git remote -v | awk '/git@github.com:mediacloud\/newsscribe-ansible.git/ { print $1; exit }')
if [ "x$UPSTREAM" = x ]; then
    echo no mediacloud ssh remote found 1>&2
    fatal
fi
echo upstream repo $UPSTREAM $(git remote get-url $UPSTREAM)

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

if ! git diff --quiet $UPSTREAM/prod >/dev/null 2>&1; then
    echo repo has not been pushed/merged 1>&2
    fatal
fi

echo 'checking push (for tagging)'
if ! git push --dry-run >/dev/null 2>&1; then
    echo push test failed 1>&2
    fatal
fi

################ get ansible-elastic from github

TMP=$(awk '/mc_tmp:/ { print $2 }' es-vars.yml)
if [ "x$TMP" = x ]; then
    echo could not read mc_tmp setting 1>&2
    exit 1
elif [ -d $TMP ]; then
    # rather than figuring out if it's disposable, let the human..
    echo $TMP directory exists 1>&2
    exit 1
fi

# get mc_es_ansible_elasticsearch_repo from es-vars.yml?
ANSIBLE_ELASTIC_REPO=$(awk '/^mc_es_ansible_elasticsearch_repo: / { print $2 }' es-vars.yml)
if [ "x$ANSIBLE_ELASTIC_REPO" = x ]; then
    echo could not read mc_es_ansible_elasticsearch_repo setting 1>&2
    exit 1
fi

#### check out into TMP directory

CWD=$(pwd)
trap "cd $CWD; rm -rf tmp" 0
mkdir $TMP
cd $TMP
echo cloning $ANSIBLE_ELASTIC_REPO
# clone using ssh url, for pushing tag
if ! git clone https://git@github.com/${ANSIBLE_ELASTIC_REPO}.git >/dev/null; then
    echo git clone failed 1>&2
    exit 1
fi
echo testing $ANSIBLE_ELASTIC_REPO push
if ! git push --dry-run; then
    exit 1
fi
cd ..

################ run ansible (shudder)

# run es-install.yml playbook:
if sudo venv/bin/ansible-playbook -i es-inventory.yml es-install.yml; then
    TAG=success-$(date '%Y-%m-%d-%H-%M-%S')-${UNAME}

    echo "SUCCESS!! applying tag $TAG and pushing to $ORIGIN"
    git tag $TAG
    git push $ORIGIN $TAG

    echo "applying $TAG to ansible-elasticsearch"
    (cd tmp/ansible-elasticsearch; git tag $TAG; git push origin $TAG)
echo
    echo ansible run failed -- not tagged
    exit 1
fi
