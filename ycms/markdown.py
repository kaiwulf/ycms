"""Turn author-written markdown into safe HTML. No Flask, no database."""

import re

import markdown as md
import nh3

ALLOWED_TAGS = {
    'a', 'abbr', 'b', 'blockquote', 'br', 'code', 'em', 'i', 'li', 'ol',
    'p', 'pre', 'strong', 'ul', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'table', 'thead', 'tbody', 'tr', 'th', 'td', 'hr', 'img',
}

ALLOWED_ATTRIBUTES = {
    'a': {'href', 'title'},
    'abbr': {'title'},
    'img': {'src', 'alt', 'title'},
    'code': {'class'},
}

def render(markdown_text):
    """Markdown source -> sanitized HTML, safe to insert into a page."""
    html = md.markdown(markdown_text, extensions=['fenced_code', 'tables'])
    return nh3.clean(html, tags=ALLOWED_TAGS, attributes=ALLOWED_ATTRIBUTES)

def make_preview(markdown_text, limit=200):
    """Short plain-text teaser, used when a post has no custom body_preview."""
    html = md.markdown(markdown_text)
    text = nh3.clean(html, tags=set()).strip()
    text = re.sub(r'\s+', ' ', text)

    if len(text) <= limit:
        return text
    return text[:limit].rsplit(' ', 1)[0] + '...'

def slugify(title):
    """'My First Post!' -> 'my-first-post'"""
    slug = re.sub(r'[^a-z0-9]+', '-', title.lower())
    return slug.strip('-')