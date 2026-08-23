from .db import get_db
from .markdown import render, slugify

_POST_COLUMNS = (
    'SELECT p.id, p.title, p.slug, p.body_html, p.body_markdown, p.body_preview, p.status,'
    ' p.created, p.updated, p.published_at, p.author_id, u.username'
    ' FROM post p JOIN user u ON p.author_id = u.id'
)

def get_published_posts(limit=None):
    """Published posts, newest first. Can never return a draft."""
    sql = _POST_COLUMNS + " WHERE p.status = 'published' ORDER BY p.published_at DESC"
    params = []

    if limit is not None:
        sql += ' LIMIT ?'
        params.append(limit)
    
    return get_db().execute(sql, params).fetchall()

def get_published_post_by_slug(slug):
    """One published post, or None. Returns None for drafts and unknown slugs."""
    sql = _POST_COLUMNS + " WHERE p.status = 'published' AND p.slug = ?"
    return get_db().execute(sql, (slug,)).fetchone()

def get_all_posts():
    """CMS-side: every post, drafts included. Never use on public pages."""
    sql = _POST_COLUMNS + ' ORDER BY p.created DESC'
    return get_db().execute(sql).fetchall()

def get_post_by_id(post_id):
    """CMS-side: one post by id, any status, or None."""
    sql = _POST_COLUMNS + ' WHERE p.id =?'
    return get_db().execute(sql, (post_id,)).fetchone()

def _unique_slug(base):
    """Append -2, -3, ... until the slug is free."""
    db = get_db()
    slug, n = base, 1
    while db.execute('SELECT 1 FROM post WHERE slug = ?', (slug,)).fetchone():
        n += 1
        slug = f'{base}-{n}'
    return slug

def create_post(author_id, title, body_markdown=None, body_preview=None):
    """Insert a new draft. Returns the new post's id."""
    db = get_db()
    cur = db.execute(
        'INSERT INTO post (author_id, title, slug, body_markdown, body_html,'
        ' body_preview, status)'
        " VALUES (?, ?, ?, ?, ?, ?, 'draft')",
        (author_id, title, _unique_slug(slugify(title)), body_markdown,
         render(body_markdown), body_preview or None)
    )
    db.commit()
    return cur.lastrowid

def update_post(post_id, title, body_markdown, body_preview=None):
    """Save edits. Re-renders the HTML and stamps `updated`."""
    db = get_db()
    db.execute(
        'UPDATE post SET title = ?, body_markdown = ?, body_html = ?,'
        ' body_preview = ?, updated = CURRENT_TIMESTAMP'
        ' WHERE id = ?',
        (title, body_markdown, render(body_markdown), body_preview or None, post_id)
    )
    db.commit()

def publish_post(post_id):
    """Make a post public. Keeps the original publish date on re-publish."""
    db = get_db()
    db.execute(
        "UPDATE post SET status = 'published',"
        ' published_at = COALESCE(published_at, CURRENT_TIMESTAMP)'
        ' WHERE id = ?',
        (post_id,)
    )
    db.commit()

def unpublish_post(post_id):
    """Return a published post to draft. Leaves published_at intact."""
    db = get_db()
    db.execute("UPDATE post SET status = 'draft' WHERE id = ?", (post_id,))
    db.commit()

def delete_post(post_id):
    """Permanently remove a post. post_tag rows go with it via ON DELETE CASCADE."""
    db = get_db()
    db.execute('DELETE FROM post WHERE id = ?', (post_id,))
    db.commit()

def rerender_all():
    """Re-run render() over every post. Use after changing the renderer."""
    db = get_db()
    rows = db.execute('SELECT id, body_markdown FROM post').fetchall()
    for row in rows:
        db.execute(
            'UPDATE post SET body_html = ? WHERE id = ?',
            (render(row['body_markdown']), row['id'])
        )
    db.commit()
    return len(rows)