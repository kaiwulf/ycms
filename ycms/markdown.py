"""Turn author-written markdown into safe HTML. No Flask, no database."""

import re
from html import unescape

import markdown as md
import nh3

# Bump whenever render() output changes (new plugin, new sanitizer rule,
# switching MathML->SVG). Stored body_html is a cache of this version.
RENDER_VERSION = '2'

ALLOWED_TAGS = {
    'a', 'abbr', 'b', 'blockquote', 'br', 'code', 'em', 'i', 'li', 'ol',
    'p', 'pre', 'strong', 'ul', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'table', 'thead', 'tbody', 'tr', 'th', 'td', 'hr', 'img', 'span', 'div',
}

ALLOWED_ATTRIBUTES = {
    'a': {'href', 'title'},
    'abbr': {'title'},
    'img': {'src', 'alt', 'title'},
    'code': {'class'},
    'div': {'class'},
    'span': {'class'}
}

def _to_html(markdown_text):
    html = md.markdown(markdown_text,
            extensions=['fenced_code', 'tables', 'pymdownx.arithmatex'],
            extension_configs={
                'pymdownx.arithmatex': { 'generic': True },
            }
        )
    return html

def render(markdown_text):
    """Markdown source -> sanitized HTML, safe to insert into a page."""
    html = _to_html(markdown_text)
    return nh3.clean(html, tags=ALLOWED_TAGS, attributes=ALLOWED_ATTRIBUTES, attribute_filter=_math_class_only)

def make_preview(markdown_text, limit=200):
    """Short plain-text teaser, used when a post has no custom body_preview."""
    html = _to_html(markdown_text)
    text = nh3.clean(html, tags=set()).strip()
    text = unescape(text)
    text = re.sub(r'\s+', ' ', text)

    if len(text) <= limit:
        return text
    return text[:limit].rsplit(' ', 1)[0] + '...'

def _math_class_only(tag, attr, value):
    if (tag == 'div' or tag == 'span') and attr == 'class':
        return value if value == 'arithmatex' else None
    return value

def slugify(title):
    """'My First Post!' -> 'my-first-post'"""
    slug = re.sub(r'[^a-z0-9]+', '-', title.lower())
    return slug.strip('-')