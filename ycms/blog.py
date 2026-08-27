from flask import Blueprint, render_template
from werkzeug.exceptions import abort

from . import content

bp = Blueprint('blog', __name__, url_prefix='/blog',
               template_folder='templates')

@bp.route('')
def index():

    per_page = 10
    page = 1

    total = content.count_published_posts()
    total_pages = -(-total // per_page)

    posts = content.get_published_posts(limit=per_page, offset=(page - 1) * per_page)
    return render_template("ycms/blog/index.html", posts=posts, page=page, total_pages=total_pages, per_page=per_page)

@bp.route('/<slug>')
def post(slug):
    entry = content.get_published_post_by_slug(slug)
    if entry is None:
        abort(404)
    return render_template("ycms/blog/post.html", post=entry)