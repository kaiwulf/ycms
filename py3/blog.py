from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for, abort
)
from werkzeug.exceptions import abort
from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField
from wtforms.validators import DataRequired
from bleach import clean
from markupsafe import Markup

from py3.auth import login_required
from py3.db import get_db

bp = Blueprint('blog', __name__)

ALLOWED_TAGS = [
    'a', 'b', 'abbr', 'blockquote', 'code', 'em', 'i', 'li', 'ol', 'strong', 'ul', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'br'
]

ALLOWED_ATTRS = {
    'a': ['href', 'title'],
    'abbr': ['title'],
    'abbr': ['title']
}

class PostForm(FlaskForm):
    title = StringField('Title', validators=[DataRequired()])
    body = TextAreaField('Content', validators=[DataRequired()])

def get_latest_posts(limit=3):
    db = get_db()
    return db.execute(
        'SELECT p.id, title, body, created, author_id, username'
        ' FROM post p JOIN user u ON p.author_id = u.id'
        ' ORDER BY created DESC LIMIT ?',
        (limit,)
    ).fetchall()

@bp.route('/blog')
def blog_index():
    db = get_db()
    posts = db.execute(
        'SELECT p.id, title, body, created, author_id, username'
        ' FROM post p JOIN user u ON p.author_id = u.id'
        ' ORDER BY created DESC'
    ).fetchall()
    return render_template('blog/blog_index.html', posts=posts)

@bp.route('/blog/create', methods=('GET','POST'))
@login_required
def create():
    form = PostForm()
    if form.validate_on_submit():
        title = form.title.data
        # title = request.form['title']
        # body = request.form['body']
        # error = None

        body = clean(
            form.body.data,
            tags=ALLOWED_TAGS,
            attributes=ALLOWED_ATTRS,
            strip=True
        )

        db = get_db()
        db.execute(
            'INSERT INTO post (title, body, author_id)'
                ' VALUES (?, ?, ?)',
                (title, body, g.user['id'])
        )

        # if not title:
        #     error = 'Title required'
        
        # if error is not None:
        #     flash(error)
        # else:
        #     db = get_db()
        #     db.execute(
        #         'INSERT INTO post (title, body, author_id)'
        #         ' VALUES (?, ?, ?)',
        #         (title, body, g.user['id'])
        #     )
        db.commit()
            # return redirect(url_for('blog.blog_index'))
    return render_template('blog/create.html', form=form)

def get_post(id, check_author=True):
    post = get_db().execute(
        'SELECT p.id, title, body, created, author_id, username'
        ' FROM post p JOIN user u ON p.author_id = u.id'
        ' WHERE p.id = ?',
        (id,)
    ).fetchone()

    if post is None:
        abort(404, f"Post id {id} doesn't exist.")
    
    if check_author and post['author_id'] != g.user['id']:
        abort(403)

    post = dict(post)
    post['body'] = Markup(post['body'])

    return post

@bp.route('/blog/<int:id>/update', methods=('GET','POST'))
@login_required
def update(id):
    post = get_post(id)

    if request.method == 'POST':
        title = request.form['title']
        body = request.form['body']
        error = None

        if not title:
            error = 'Title is required'

        if error is not None:
            flash(error)
        else:
            db = get_db()
            db.execute(
                'UPDATE post SET title = ?, body = ?'
                ' WHERE id = ?',
                (title, body, id)
            )
            db.commit()
            return redirect(url_for('blog.blog_index'))
    return render_template('blog/update.html', post=post)

@bp.route('/blog/<int:id>/delete', methods=('POST',))
@login_required
def delete(id):
    get_post(id)
    db = get_db()
    db.execute('DELETE FROM post WHERE id = ?', (id,))
    db.commit()
    return redirect(url_for('blog.blog_index'))