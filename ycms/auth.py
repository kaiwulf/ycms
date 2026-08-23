import functools
from flask import (
    Blueprint, g, redirect, render_template, request, session, url_for
)

from werkzeug.security import check_password_hash, generate_password_hash
from .db import get_db

bp = Blueprint('auth', __name__, url_prefix='/auth',
               template_folder='templates')

@bp.route('/register', methods=('GET', 'POST'))
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        error = None

        if not username:
            error = 'Username is required'
        elif not password:
            error = 'Password required'
        
        if error is None:
            try:
                db.execute(
                    "INSERT INTO user (username, password) VALUES (?, ?)",
                    (username, generate_password_hash(password)),
                )
                db.commit()
            except db.IntegrityError:
                error = f"User {username} is already registered"
            else:
                return redirect(url_for("auth.login"))
        # flush(error)
    return render_template('ycms/auth/register.html')

@bp.route('/login', methods=('GET','POST'))
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        # new_password = request.form['new-password']
        db = get_db()
        error = None
        user = db.execute(
            'SELECT * FROM user WHERE username = ?', (username,)
        ).fetchone()

        if user is None:
            error = 'Incorrect username'
        # This code will be for updating password in a new page in auth/
        # elif new_password:
        #     try:
        #         db.execute(
        #             "UPDATE user SET password = ? WHERE username = ?", (generate_password_hash(new_password), username)
        #         )
        #         db.commit()
        #     except db.IntegrityError:
        #         error = f"Error changing password"
        #     else:
        #         return redirect(url_for("auth.login"))
        # if password is not None:
        elif not check_password_hash(user['password'], password):
            error = 'Incorrect password'
        
        if error is None:
            session.clear()
            session['user_id'] = user['id']
            return redirect(url_for('admin.dashboard'))

        # flush(error)
    return render_template('ycms/auth/login.html')

@bp.before_app_request
def load_logged_in_user():
    user_id = session.get('user_id')

    if user_id is None:
        g.user = None
    else:
        g.user = get_db().execute(
            'SELECT * FROM user WHERE id = ?', (user_id,)
        ).fetchone()

@bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

def login_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if g.user is None:
            return redirect(url_for('auth.login'))

        return view(**kwargs)
    return wrapped_view