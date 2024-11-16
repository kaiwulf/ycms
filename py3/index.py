from flask import (
    Blueprint, render_template
)

from py3.blog import get_latest_posts

bp = Blueprint('index', __name__)

@bp.route('/')
def index():
    latest_posts = get_latest_posts()
    return render_template('/index.html', latest_posts=latest_posts)

@bp.route('/about')
def about():
    url="https://github.com/kaiwulf"
    return render_template('/about.html', message=url)
