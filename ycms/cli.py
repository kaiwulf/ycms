import click
from flask.cli import with_appcontext

from . import content
from .markdown import RENDER_VERSION

@click.command('rerender-all')
@with_appcontext
def rerender_all_command():
    """Rebuild body_html for every post from its markdown."""
    count = content.rerender_all()
    click.echo(f'Re-rendered {count} posts (RENDER_VERSION={RENDER_VERSION}).')


def init_cli(app):
    app.cli.add_command(rerender_all_command)