# ycms — to do

Working notes. Each item says what it is, where it lives, and what already
exists to build on.

## Next up: deployment, backups and migrations

### 1. Deploy ycms and the site to the remote server
A repeatable way to get the code, the static assets and the database onto the
server, and to update them later.

- **`SECRET_KEY` is hardcoded to `'dev'`** in `app.py:24`. `create_app` loads
  `instance/config.py` over it when present, but no such file exists. Deployed
  as-is, anyone can forge a session cookie and log in to the admin. Production
  needs a real key in `instance/config.py` (or the environment), never committed.
- `ProxyFix` is already configured for one proxy hop (`app.py:38`), which
  matches running behind nginx. It must be exactly one hop, or clients can
  spoof `X-Forwarded-*` headers.
- Serve with a WSGI server (gunicorn or uWSGI) behind nginx, not `flask run`.
  `run.sh` is dev-only.
- nginx can serve `/static/` and `/ycms/static/` directly from disk instead of
  through Flask. `tex-svg.js` is 2.1 MB, so this is worth doing.
- Decide the update path: `git pull` on the server, rsync from local, or a
  built package. `setup.py` now lists correct dependencies, so a venv plus
  `pip install -e .` is viable.
- `instance/` holds the database and the secret key and must not be
  overwritten by a deploy.
- The migrations item below must land before real posts go live. After that,
  `init-db` on the server destroys data.

### 2. Back up the database, offsite
- **Do not copy the `.sqlite` file while the app is running.** A copy taken
  mid-write can be corrupt. Use SQLite's online backup, which produces a
  consistent snapshot of a live database: `sqlite3 ycms.sqlite ".backup out.sqlite"`
  or Python's `sqlite3.Connection.backup()`. A `flask backup-db` command
  alongside `rerender-all` in `ycms/cli.py` would keep it in one place.
- Schedule with a systemd timer or cron on the server.
- Offsite to S3: `aws s3 cp` or boto3. Decisions: retention (S3 lifecycle
  rules can expire old backups automatically), encryption, and a dedicated
  IAM user whose key can only write to that one bucket.
- **Test a restore.** A backup that has never been restored is a guess.
- Uploaded files, once they exist, need backing up too. Only the database
  matters today.

### 3. Schema migrations without wiping data
Today the only way to change the schema is `flask --app app init-db`, which
runs `DROP TABLE` on everything. That's fine while the database holds dummy
data. Once real posts exist on the live site, every schema change has to
upgrade the existing database in place.

**Must be in place before the first real post goes live.** Until then,
re-initialising stays the cheap option.

A lightweight approach that fits the code as it stands (raw `sqlite3`, no ORM,
so Alembic would be a poor fit):

- **Numbered SQL files** in `ycms/migrations/`, for example
  `0002_add_subtitle.sql`. Each file makes one change and never gets edited
  after it has run anywhere.
- **Track the version in the database itself** with `PRAGMA user_version`, an
  integer SQLite stores in the file header. It currently reads `0`.
- **A `flask migrate` command** in `ycms/cli.py`. It reads `user_version`,
  applies every higher-numbered file in order, each inside a transaction, and
  bumps the version after each one. Running it twice does nothing the second
  time.
- **Baseline.** The current `schema.sql` is version 1. `init-db` should set
  `user_version` to the latest migration number, so a fresh install isn't
  told to replay changes it already has.
- **`schema.sql` stays the fresh-install definition** and gets updated
  alongside each migration. A test can check the two stay in step: build one
  database from `schema.sql`, another from version 1 plus all migrations, and
  compare their `sqlite_master`.

Things that will bite:

- **SQLite's `ALTER TABLE` is limited.** Adding a column is easy, and dropping
  or renaming one works on this SQLite (3.53). Changing a column's type or
  a `CHECK` constraint, such as the `status` or `math_output` checks, is not
  supported. Those need the rebuild procedure: create the new table, copy
  the rows, drop the old table, rename the new one. Foreign keys must be off
  during the rebuild, or deleting the old `post` table cascades into
  `post_tag` and deletes every tag link.
- **`PRAGMA foreign_keys` can't change inside a transaction.** `db.py`
  switches it on for every connection, so the migrate command has to turn it
  off before starting a rebuild and back on after.
- **`init-db` becomes dangerous on the live server.** It should refuse to run
  when the database already contains posts, unless given an explicit
  `--force`.
- **Back up before migrating.** The migrate command should take an online
  backup first (see the backup item), so a failed migration can be undone.
- `_POST_COLUMNS` in `ycms/content.py` lists columns explicitly, so a new
  column is invisible to the app until it's added there too.

## Blog features

### 4. Post subtitle
Add a subtitle/standfirst that renders under the title on the post page and
optionally on the index.

- Schema change: new nullable `subtitle` column on `post` in `ycms/schema.sql`.
  Fine to re-init while the data is dummy. After that it's the first
  migration (see the migrations item).
- `_POST_COLUMNS` in `ycms/content.py:4` selects columns explicitly — add it
  there or it won't reach any template.
- `create_post` / `update_post` signatures and `PostForm` in `ycms/admin.py`.
- Render in `ycms/templates/ycms/blog/post.html.j2`, under the `<h1>`.

### 5. Tags / hashtags in the editor
The database already has this and nothing uses it:

```sql
CREATE TABLE tag      (id, name UNIQUE);
CREATE TABLE post_tag (post_id, tag_id, PRIMARY KEY (post_id, tag_id));
```

`ON DELETE CASCADE` is already declared and `ycms/db.py:19` switches on
`PRAGMA foreign_keys` per connection, so deleting a post will clean up its
`post_tag` rows without extra work.

Needs: a field in `PostForm`, tag read/write functions in `ycms/content.py`
(the only place post SQL is allowed to live), display on the post page, and a
decision on whether tags get their own browse pages — `/blog/tag/<name>` — or
are display-only for now.

Parsing decision: free-text comma-separated, or `#hashtag` syntax lifted out
of the body? The second is more work and interacts with markdown.

### 6. Pagination
`ycms/blog.py:13` hardcodes `page = 1` while the template already builds
`?page=N` links (`index.html.j2:27-42`). Clicking page 2 silently re-serves
page 1.

Read `request.args`, then decide the three edge cases: `?page=0` (negative
OFFSET), `?page=99` when there are 2 pages, and `?page=banana`.
`count_published_posts()` and the `limit`/`offset` arguments already exist.

Deferred until there are enough posts to test against.

## Editor

### 7. Formatting toolbar
Buttons over the markdown textarea in `ycms/templates/ycms/admin/editor.html.j2`
for headings, bold, italic, underline, links, code, and a math-symbol palette.

The editor is plain `<textarea id="editor">`, so this is selection
manipulation — `selectionStart`/`selectionEnd`, wrap or prefix, restore the
cursor. Note markdown has no underline; it would have to emit raw `<u>`, which
means adding `u` to `ALLOWED_TAGS` in `ycms/markdown.py`.

The math palette is the interesting half: inserting `\frac{}{}` and leaving
the cursor in the first pair of braces is the difference between useful and
annoying. Worth deciding whether it inserts LaTeX or opens a picker.

The existing live preview (POST to `/admin/preview`, debounced 250ms) already
re-renders on `input`, so toolbar edits should dispatch an `input` event to
keep the preview in sync.

## Rendering

### 8. Previews can truncate mid-equation
`make_preview` in `ycms/markdown.py` cuts at `limit` characters with no
knowledge of math, so a teaser can end with an opening `\(` and no `\)`.
MathJax then scans forward looking for the close.

Options: cut only at a safe point outside math, drop a trailing unbalanced
delimiter, or strip math from teasers entirely. Currently theoretical — needs
a post whose first 200 characters happen to split a delimiter.

### 9. MathML alongside SVG
`schema.sql` already declares the column for this:

```sql
math_output TEXT NOT NULL DEFAULT 'mathml' CHECK (math_output IN ('mathml','svg'))
```

Nothing reads it yet, and the live database doesn't have the column at all.
Currently every page loads `tex-svg.js`. Serving MathML instead means a
different MathJax bundle and a per-post (or per-site) switch on that column.

## Platform

### 10. CSS semantic tokens
Replace hardcoded colours with named design tokens as CSS custom properties,
so a site restyles by redefining a handful of variables instead of hunting
through hundreds of rules.

- `kaiwulf/static/style.css` repeats literal colours throughout. `#00a0b0`
  appears 9 times and `#ef7d50` 6, with `#eb6841`, `#edc951` and `#333`
  close behind. Rebranding means finding every one.
- Two layers: primitives (`--orange-500: #eb6841`) and semantic roles that
  point at them (`--color-accent`, `--color-text`, `--color-surface`,
  `--color-border`, `--color-code-bg`). Rules only ever use the semantic
  names.
- ycms ships a base stylesheet for its own markup (blog, post body, admin,
  `.arithmatex`) written entirely against semantic tokens, with defaults. A
  site overrides the tokens in its own stylesheet, loaded after, and only
  writes rules for its own layout.
- Dark mode then becomes one `@media (prefers-color-scheme: dark)` block that
  redefines tokens, instead of the browser force-inverting the page.
- Boundary to decide: ycms styles its own components, never the host site's
  layout. `#container` and `.wideBox` stay kaiwulf's.

### 11. Second site: kaisage.net
One ycms install serving two sites: `kaiwulf.dev` and `kaisage.net` in
production, `kaiwulf.localhost` and `kaisage.localhost` locally behind nginx.
Logging in on one site's admin edits only that site. It must be impossible to
edit the other site from it.

The central decision is the tenancy model:

- **Two app instances.** Each site is its own `create_app()` with its own
  `instance/` directory, database and secret key, and nginx routes each
  hostname to its own process. Isolation is structural, since the processes
  share no data. Simplest and safest, and it matches the existing
  `ycms`/`kaiwulf` split directly.
- **One app, host-aware.** A single process picks the site from the `Host`
  header. Every post query in `ycms/content.py` then needs a `site_id`
  filter, and the `user` table needs to know which site an account belongs
  to. Forgetting the filter in one query leaks or edits the other site. That
  is a large, permanent correctness burden.

Either way, session cookies are host-only by default, so a login on
`kaiwulf.localhost` is not sent to `kaisage.localhost`. Never set
`SESSION_COOKIE_DOMAIN` to a shared parent domain.

Recommendation: two instances unless there's a concrete reason to share one
database.

### 12. Composable sites from premade parts
Build a site by choosing ycms parts — blog, projects, about — and giving them
branding, rather than writing each site's package from scratch.

- The blog is already this shape: a blueprint plus default templates that a
  site can override by name. Projects would follow the same pattern.
- `init_cms(app)` registers everything unconditionally. A part-based version
  takes a list, for example `init_cms(app, parts=['blog', 'projects'])`, or
  reads it from config.
- Anything that links between parts, such as nav menus and the home page's
  latest-posts list, must tolerate a part being absent. `url_for('blog.index')`
  raises `BuildError` when the blueprint isn't registered.
- Depends on the semantic tokens work, since parts need to look native in
  whichever site assembles them.

## Housekeeping

Done 2026-09-10:

- ~~Live database behind `ycms/schema.sql`~~ — re-initialised with
  `flask --app app init-db`. `post.math_output` and
  `idx_post_status_published` now exist. All tables are empty, including
  `user`, so an account has to be registered again at `/auth/register`.
  Schema changes after this need a migration, now tracked as its own item.
- ~~`ycms/templates/ycms/editor/` dead templates~~ — removed.
- ~~`setup.py` named a package that doesn't exist~~ — now
  `pymdown-extensions`.
- ~~No CSS for post-body elements~~ — added rules for `pre`, `code`,
  `blockquote`, `hr`, `article`, `.about` and `div.arithmatex` at the end of
  `kaiwulf/static/style.css`, following the existing light palette.
