DROP TABLE IF EXISTS post_tag;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS user;

CREATE TABLE user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
);

CREATE TABLE post (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  author_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  slug TEXT UNIQUE,
  body_markdown TEXT NOT NULL,
  body_html TEXT NOT NULL,
  body_preview TEXT,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated TIMESTAMP,
  published_at TIMESTAMP,
  math_output TEXT NOT NULL DEFAULT 'mathml'
      CHECK (math_output IN ('mathml', 'svg')),
  FOREIGN KEY (author_id) REFERENCES user (id)
);

CREATE INDEX idx_post_status_published ON post (status, published_at DESC);

CREATE TABLE tag (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL
);

create TABLE post_tag (
  post_id INTEGER NOT NULL REFERENCES post (id) ON DELETE CASCADE,
  tag_id INTEGER NOT NULL REFERENCES tag (id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, tag_id)
);