from flask import Flask
import os
from . import db
from werkzeug.middleware.proxy_fix import ProxyFix



# def ycms_factory(test_config=None):
def create_app(test_config=None):
    app = Flask(__name__,
    static_folder='static',
    instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'ycms.sqlite'),
    )

    # Tell flask it is behind a proxy server
    app.wsgi_app = ProxyFix(
        app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1
    )

    if test_config is None:
        app.config.from_pyfile('config.py', silent=True)
    else:
        app.config.from_mapping(test_config)
    
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass
    
    @app.route('/hello')
    def hello():
        return 'ycms'

    from . import index
    app.register_blueprint(index.bp)
    app.add_url_rule('/', endpoint='index')

    from . import db
    from . import auth
    db.init_app(app)
    app.register_blueprint(auth.bp)

    from . import blog
    app.register_blueprint(blog.bp)
    app.add_url_rule('/blog', endpoint='index')
    
    return app