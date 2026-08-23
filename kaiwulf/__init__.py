"""kaiwulf.dev — the website.

This package owns everything site-specific: portfolio, about page, public blog
presentation, branding and CSS. It reads posts through `ycms.content` and never
touches the CMS's tables directly.
"""


def init_site(app):
    """Register the website's blueprints on an existing Flask app."""
    from . import site#, projects, blog
    
    app.register_blueprint(site.bp)
    # app.add_url_rule('/', endpoint='index')
    # app.register_blueprint(projects.bp)
    # app.register_blueprint(blog.bp)
    pass
