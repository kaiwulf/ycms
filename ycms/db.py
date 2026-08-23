import os
import sqlite3
import click
from flask import current_app, g

# schema.sql ships with this package, so locate it relative to this file
# rather than relative to whichever app happens to be running.
SCHEMA_PATH = os.path.join(os.path.dirname(__file__), 'schema.sql')

def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect(
            current_app.config['DATABASE'],
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        g.db.row_factory = sqlite3.Row
        # SQLite ignores FOREIGN KEY constraints unless this is switched on,
        # and it is per-connection, so it must be set on every connect.
        g.db.execute('PRAGMA foreign_keys = ON')
    return g.db

def close_db(e=None):
    db = g.pop('db', None)

    if db is not None:
        db.close()

def init_db():
    db = get_db()
    with open(SCHEMA_PATH, encoding='utf8') as f:
        db.executescript(f.read())

@click.command('init-db')
def init_db_command():
    init_db()
    click.echo('initialized the db')

def init_app(app):
    app.teardown_appcontext(close_db)
    app.cli.add_command(init_db_command)
