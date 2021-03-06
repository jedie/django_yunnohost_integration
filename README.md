# django_yunohost_integration

Python package [django_yunohost_integration](https://pypi.org/project/django_yunohost_integration/) with helpers for integrate a Django project as YunoHost package.

A example usage of this package is here:

* https://github.com/YunoHost-Apps/django_example_ynh

Pull requests welcome ;)


These projects used `django_yunohost_integration`:

* https://github.com/YunoHost-Apps/pyinventory_ynh
* https://github.com/YunoHost-Apps/django-for-runners_ynh


## Features

* SSOwat integration (see below)
* Helper to create first super user for `scripts/install`
* Run Django development server with a local generated YunoHost package installation (called `local_test`)
* Run `pytest` against `local_test` "installation"


### SSO authentication

[SSOwat](https://github.com/YunoHost/SSOwat) is fully supported:

* First user (`$YNH_APP_ARG_ADMIN`) will be created as Django's super user
* All new users will be created as normal users
* Login via SSO is fully supported
* User Email, First / Last name will be updated from SSO data


### usage

To create/update the first user in `install`/`upgrade`, e.g.:

```bash
./manage.py create_superuser --username="$admin" --email="$admin_mail"
```
This Create/update Django superuser and set a unusable password.
A password is not needed, because auth done via SSOwat ;)

Main parts in `settings.py`:
```python
from django_yunohost_integration.secret_key import get_or_create_secret as __get_or_create_secret

# Function that will be called to finalize a user profile:
YNH_SETUP_USER = 'setup_user.setup_project_user'

SECRET_KEY = __get_or_create_secret(FINAL_HOME_PATH / 'secret.txt')  # /opt/yunohost/$app/secret.txt

INSTALLED_APPS = [
    #...
    'django_yunohost_integration',
    #...
]

MIDDLEWARE = [
    #... after AuthenticationMiddleware ...
    #
    # login a user via HTTP_REMOTE_USER header from SSOwat:
    'django_yunohost_integration.sso_auth.auth_middleware.SSOwatRemoteUserMiddleware',
    #...
]

# Keep ModelBackend around for per-user permissions and superuser
AUTHENTICATION_BACKENDS = (
    'axes.backends.AxesBackend',  # AxesBackend should be the first backend!
    #
    # Authenticate via SSO and nginx 'HTTP_REMOTE_USER' header:
    'django_yunohost_integration.sso_auth.auth_backend.SSOwatUserBackend',
    #
    # Fallback to normal Django model backend:
    'django.contrib.auth.backends.ModelBackend',
)

LOGIN_REDIRECT_URL = None
LOGIN_URL = '/yunohost/sso/'
LOGOUT_REDIRECT_URL = '/yunohost/sso/'
```


## local test

For quicker developing of django_yunohost_integration in the context of YunoHost app,
it's possible to run the Django developer server with the settings
and urls made for YunoHost installation.

e.g.:
```bash
~$ git clone https://github.com/jedie/django_yunohost_integration.git
~$ cd django_yunohost_integration/
~/django_yunohost_integration$ make
install-poetry         install or update poetry
install                install project via poetry
update                 update the sources and installation and generate "conf/requirements.txt"
lint                   Run code formatters and linter
fix-code-style         Fix code formatting
tox-listenvs           List all tox test environments
tox                    Run pytest via tox with all environments
pytest                 Run pytest
publish                Release new version to PyPi
local-test             Run local_test.py to run the project locally
local-diff-settings    Run "manage.py diffsettings" with local test

~/django_yunohost_integration$ make install-poetry
~/django_yunohost_integration$ make install
~/django_yunohost_integration$ make local-test
```

Notes:

* SQlite database will be used
* A super user with username `test` and password `test` is created
* The page is available under `http://127.0.0.1:8000/app_path/`


## history

* [compare v0.1.5...master](https://github.com/YunoHost-Apps/django_yunohost_integration/compare/v0.1.5...master) **dev**
  * tbc
* v0.2.0.alpha0 **dev**
  * rename/split `django_ynh` into:
    * `django_yunohost_integration` - Python package with the glue code to integrate a Django project with YunoHost
    * `django_example_ynh` - Demo YunoHost App to demonstrate the integration of a Django project under YunoHost
* [v0.1.5 - 19.01.2021](https://github.com/YunoHost-Apps/django_yunohost_integration/compare/v0.1.4...v0.1.5)
  * Make some deps `gunicorn`, `psycopg2-binary`, `django-redis`, `django-axes` optional
* [v0.1.4 - 08.01.2021](https://github.com/YunoHost-Apps/django_yunohost_integration/compare/v0.1.3...v0.1.4)
  * Bugfix [CSRF verification failed on POST requests #7](https://github.com/YunoHost-Apps/django_yunohost_integration/issues/7)
* [v0.1.3 - 08.01.2021](https://github.com/YunoHost-Apps/django_yunohost_integration/compare/v0.1.2...v0.1.3)
  * set "DEBUG = True" in local_test (so static files are served and auth works)
  * Bugfixes and cleanups
* [v0.1.2 - 29.12.2020](https://github.com/YunoHost-Apps/django_yunohost_integration/compare/v0.1.1...v0.1.2)
  * Bugfixes
* [v0.1.1 - 29.12.2020](https://github.com/YunoHost-Apps/django_yunohost_integration/compare/v0.1.0...v0.1.1)
  * Refactor "create_superuser" to a manage command, useable via "django_yunohost_integration" in `INSTALLED_APPS`
  * Generate "conf/requirements.txt" and use this file for install
  * rename own settings and urls (in `/conf/`)
* [v0.1.0 - 28.12.2020](https://github.com/YunoHost-Apps/django_yunohost_integration/compare/f578f14...v0.1.0)
  * first working state
* [23.12.2020](https://github.com/YunoHost-Apps/django_yunohost_integration/commit/f578f144a3a6d11d7044597c37d550d29c247773)
  * init the project


## Links

* Report a bug about this package: https://github.com/YunoHost-Apps/django_yunohost_integration
* YunoHost website: https://yunohost.org/
* PyPi package: https://pypi.org/project/django_yunohost_integration/



