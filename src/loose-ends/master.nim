import templates

# local
import article, render, sqlite

proc render_layout() =

    content = render.index()
    title = render.title()
    layout(title, content)

# Views
proc layout(title, content: string): string = tmpli html"""
    <!DOCTYPE html>
    <link rel="stylesheet" href="/style.css">
    <title>$title</title>
    <div id=container>
        <h1>$title</h1>
        <div id=content>
            <h2>File starts here</h2>
            $content
        </div>
</body>
</html>"""

settings:
    port = Port(mainPort)
    bindAddr = mainURL

routes:

    get "/":            resp render.homepage_index()
    get "/archive":     resp render.arhive_index()
    get "/articles":    resp render.article_index()

    post "/archive":
        resp render.archive_index()
    post "/article":
        resp render.article_index()
    
runForever()