import jester
import ../model/sqlite

let db = open_db()
routes:
    get "/":            resp main_page()
    get "/blog_main":   resp render_blog_main()