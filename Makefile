# Makefile to construct environment to run ansible
VENVDIR=venv
VENVBIN=$(VENVDIR)/bin
VENVDONE=$(VENVDIR)/.done

ALL=$(VENVDONE) $(ES_ROLE_DIR)

default:
	@echo "Usage:"
	@echo "make setup -- create virtual environment"
	@echo "make test -- test using molecule & docker"
	@echo "make lint -- run pre-commit checks on all files"
	@echo "make clean -- clean up"
	@echo "make update -- update pre-commit hooks"

################ create venv

setup:	$(VENVDONE)

$(VENVDONE): $(VENVDIR) Makefile requirements.txt
	$(VENVBIN)/python3 -m pip install -r requirements.txt
	$(VENVBIN)/pre-commit install
	touch $(VENVDONE)

$(VENVDIR):
	python3 -m venv $(VENVDIR)

################ test w/ molecule

test:	_check_root
	. venv/bin/activate; molecule test

################ housekeeping

## run pre-commit checks on all files
lint:	$(VENVDONE)
	$(VENVBIN)/pre-commit run --all-files

## update .pre-commit-config.yaml
update:	$(VENVDONE)
	$(VENVBIN)/pre-commit autoupdate

_check_root:
	@test `whoami` = root || (echo "run as root" && false)

clean:
	rm -rf $(VENVDIR)
