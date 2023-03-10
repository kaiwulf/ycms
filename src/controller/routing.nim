import jester
# import ../model/sqlite

import ../view/[main, blog_main]

# let db = open_db()
routes:
    get "/":                        resp main_page()
    get "/blog_main":               resp render_blog_main()
    get "/blog_main/@articleNum":   resp full_article()