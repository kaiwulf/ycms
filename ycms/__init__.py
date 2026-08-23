"""YCMS — a small, reusable CMS engine.

This package must never import from `kaiwulf` or contain anything specific to
one website (branding, CSS, copy). Everything site-specific lives in the site
package; everything reusable lives here.
"""

from flask import Blueprint


def init_cms(app):
    """Attach the CMS engine to an existing Flask app."""
    from . import db, auth

    db.init_app(app)
    app.register_blueprint(auth.bp)

    # The editor's own assets (marked.min.js), served at /ycms/static/...
    # so they never collide with the website's static files.
    static_bp = Blueprint(
        'ycms_static', __name__,
        static_folder='static',
        static_url_path='/ycms/static',
    )
    app.register_blueprint(static_bp)

    from . import admin, cli
    app.register_blueprint(admin.bp)
    cli.init_cli(app)
