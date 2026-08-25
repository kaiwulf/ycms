from flask import (
    Blueprint, flash, g, redirect, render_template, url_for, jsonify, request
)
from werkzeug.exceptions import abort
from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, SubmitField
from wtforms.validators import DataRequired

from . import content
from .auth import login_required
from .markdown import render

bp = Blueprint('admin', __name__, url_prefix='/admin',
               template_folder='templates')


class PostForm(FlaskForm):
    title = StringField('Title', validators=[DataRequired()])
    body_markdown = TextAreaField('Content', validators=[DataRequired()])
    body_preview = TextAreaField('Custom teaser (optional)')
    save = SubmitField('Save draft')
    publish = SubmitField('Publish')


@bp.route('/')
@login_required
def dashboard():
    return render_template('ycms/admin/dashboard.html',
                           posts=content.get_all_posts())

@bp.route('/new', methods=('GET', 'POST'))
@login_required
def create():
    form = PostForm()
    if form.validate_on_submit():
        post_id = content.create_post(
            g.user['id'], form.title.data,
            form.body_markdown.data, form.body_preview.data,
        )
        if form.publish.data:
            content.publish_post(post_id)
        flash('Published.' if form.publish.data else 'Draft saved.')
        return redirect(url_for('admin.edit', post_id=post_id))

    return render_template('ycms/admin/editor.html', form=form, post=None)


@bp.route('/<int:post_id>/edit', methods=('GET', 'POST'))
@login_required
def edit(post_id):
    post = content.get_post_by_id(post_id)
    if post is None:
        abort(404)

    form = PostForm(data={
        'title': post['title'],
        'body_markdown': post['body_markdown'],
        'body_preview': post['body_preview'],
    })

    if form.validate_on_submit():
        content.update_post(post_id, form.title.data,
                            form.body_markdown.data, form.body_preview.data)
        if form.publish.data:
            content.publish_post(post_id)
        flash('Published.' if form.publish.data else 'Saved.')
        return redirect(url_for('admin.edit', post_id=post_id))

    return render_template('ycms/admin/editor.html', form=form, post=post)


@bp.route('/<int:post_id>/unpublish', methods=('POST',))
@login_required
def unpublish(post_id):
    content.unpublish_post(post_id)
    flash('Returned to draft.')
    return redirect(url_for('admin.dashboard'))


@bp.route('/<int:post_id>/delete', methods=('POST',))
@login_required
def delete(post_id):
    content.delete_post(post_id)
    flash('Deleted.')
    return redirect(url_for('admin.dashboard'))

@bp.route('/preview', methods=('POST',))
@login_required
def preview():
    """Render markdown exactly as publish would. Same function, no drift."""
    data = request.get_json(silent=True) or {}
    src = data.get('src')
    if not isinstance(src, str):
        return jsonify(error='src must be a string'), 400
    return jsonify(html=render(src))