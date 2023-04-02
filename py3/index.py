from flask import (
    Blueprint, render_template
)

bp = Blueprint('index', __name__)

@bp.route('/')
def index():
    return render_template('/index.html')

@bp.route('/about')
def about():
    url="https://github.com/kaiwulf"
    return render_template('/about.html', message=url)
