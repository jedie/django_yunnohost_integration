SHELL := /bin/bash
MAX_LINE_LENGTH := 119

all: help

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9 -]+:.*?## / {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check-poetry:
	@if [[ "$(shell poetry --version 2>/dev/null)" == *"Poetry"* ]] ; \
	then \
		echo "Poetry found, ok." ; \
	else \
		echo 'Please install poetry first, with e.g.:' ; \
		echo 'make install-poetry' ; \
		exit 1 ; \
	fi

install-poetry:  ## install or update poetry
	pip3 install -U poetry

install: check-poetry  ## install project via poetry
	poetry install

update: install-poetry  ## update the sources and installation
	poetry update

lint: ## Run code formatters and linter
	poetry run flynt --fail-on-change --line_length=${MAX_LINE_LENGTH} django_ynh
	poetry run isort --check-only .
	poetry run flake8 django_ynh

fix-code-style: ## Fix code formatting
	poetry run flynt --line_length=${MAX_LINE_LENGTH} django_ynh
	poetry run black --verbose --safe --line-length=${MAX_LINE_LENGTH} --skip-string-normalization django_ynh django_ynh_tests
	poetry run isort .

tox-listenvs: check-poetry ## List all tox test environments
	poetry run tox --listenvs

tox: check-poetry ## Run pytest via tox with all environments
	poetry run tox

pytest: check-poetry ## Run pytest
	poetry run pytest

publish: ## Release new version to PyPi
	poetry run publish

local-test: check-poetry  ## Run local_test.py to run the project locally
	poetry install
	poetry run ./local_test.py

local-diff-settings:  ## Run "manage.py diffsettings" with local test
	poetry run python3 local_test/opt_yunohost/manage.py diffsettings


##############################################################################

.PHONY: help check-poetry install-poetry install update local-test