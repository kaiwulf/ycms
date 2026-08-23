from flask import Blueprint, render_template

from ycms.content import get_published_posts

bp = Blueprint('site', __name__)

@bp.route('/')
def index():
    latest_posts = get_published_posts(limit=3)
    return render_template('index.html', latest_posts=latest_posts)

@bp.route('/about')
def about():
    return render_template('about.html', message='https://github.com/kaiwulf')