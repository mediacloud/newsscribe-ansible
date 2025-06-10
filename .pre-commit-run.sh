#!/bin/sh

# Invoked from .pre-commit-config.yaml to run mypy (or other tool)

# from rss-fetcher, from mc-providers, from es-tools, from sitemap-tools

# NOTE!! Takes FULL command line as arguments
LOG=$0.log
(
  date
  pwd
  echo COMMAND LINE: $0 $*
  echo '#####'
  echo ENVIRONMENT:
  env
  echo '#####'
) > $LOG

if [ -n "$VIRTUAL_ENV" ]; then
    TMP=$VIRTUAL_ENV/requirements.txt
else
    echo "$0: VIRTUAL_ENV not set; see $LOG" 1>&2
    exit 1
fi
echo TMP $TMP >> $LOG

# check saved copy of pyproject.toml to see if it has changed (or does
# not yet exist) and if (re)install pre-commit optional dependencies if
# needed.
if cmp -s requirements.txt $TMP; then
    echo no change to requirements.txt >> $LOG
else
    echo installing pre-commit optional dependencies >> $LOG
    if python3 -m pip install -r requirements.txt; then
	cp -p requirements.txt $TMP
	echo done >> $LOG
    else
	STATUS=$?
	echo pip failed $STATUS >> $LOG
	exit $STATUS
    fi
fi
#pip list >> $LOG
# NOTE! first arg must be command to invoke!
"$@"
