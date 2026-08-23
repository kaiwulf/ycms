import os

from flask import Flask
from werkzeug.middleware.proxy_fix import ProxyFix


def create_app(test_config=None):
    """Assemble the website and the CMS engine into one Flask app.

    This is the only module that knows both packages exist. `kaiwulf` may
    import `ycms`; `ycms` must never import `kaiwulf`.
    """
    app = Flask(
        __name__,
        instance_relative_config=True,
        # The app's own static/template folders belong to the website, so
        # kaiwulf templates keep using url_for('static', ...) unchanged.
        static_folder='kaiwulf/static',
        template_folder='kaiwulf/templates',
    )

    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'ycms.sqlite'),
    )

    if test_config is None:
        app.config.from_pyfile('config.py', silent=True)
    else:
        app.config.from_mapping(test_config)

    # Tell flask it is behind a proxy server
    app.wsgi_app = ProxyFix(
        app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1
    )

    os.makedirs(app.instance_path, exist_ok=True)

    import ycms
    import kaiwulf

    ycms.init_cms(app)
    kaiwulf.init_site(app)

    return app
