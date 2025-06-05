# Makefile to construct environment to run ansible
VENVDIR=venv
VENVBIN=$(VENVDIR)/bin
VENVDONE=$(VENVDIR)/.done

ALL=$(VENVDONE) $(ES_ROLE_DIR)

default:
	@echo "Usage:"
	@echo "make setup -- create virtual environment"
	@echo "make test -- test using molecule & docker"
	@echo "make clean -- clean up"

################ create venv

setup:	$(VENVDONE)

$(VENVDONE): $(VENVDIR) Makefile requirements.txt
	$(VENVBIN)/python3 -m pip install -r requirements.txt
	touch $(VENVDONE)

$(VENVDIR):
	python3 -m venv $(VENVDIR)

################ test w/ molecule

test:	_check_root
	. venv/bin/activate; molecule test

################ housekeeping

_check_root:
	@test `whoami` = root || (echo "run as root" && false)

clean:
	rm -rf $(VENVDIR)
