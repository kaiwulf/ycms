import templates
# import sqlite

proc action(): string =
    let f = readFile("test_source_minor.html")
    result = f


proc archive(): string = 
  let f = readFile("test_source_minor.html")
  result = f

proc viewArticle(): string =
  result = "article"


proc homepage(): string =
  result = "homepage"

# ?php echo htmlspecialchars( $results['pageTitle'] )?

proc header(): string =
  tmpli html"""<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Title</title>
    <link rel="stylesheet" type="text/css" href="style.css" />
  </head>
  <body>
    <div id="container">

      <a href="."><img id="logo" src="images/logo.jpg" alt="Widget News" /></a>"""
  return result

proc footer(): string =
  tmpli html"""</div>
    <div id="footer">
      Widget News &copy; 2011. All rights reserved. <a href="admin.php">Site Admin</a>
    </div>
    <div class="wideBox">
      <p>&copy; Elated.com | <a href="http://kaiwulf.dev">Back to Tutorial</a></p>
      <p style="font-size: .8em; line-height: 1.5em;"><a rel="license" href="http://creativecommons.org/licenses/by/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by/3.0/88x31.png" /></a><br />This <span xmlns:dc="http://purl.org/dc/elements/1.1/" href="http://purl.org/dc/dcmitype/Text" rel="dc:type">work</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://www.elated.com/" property="cc:attributionName" rel="cc:attributionURL">http://www.elated.com/</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>.</p>
    </div>
    </div>"""
  return result

proc archive_index()*: string =
    let x = action()

    result = header() & action() & footer()
  
proc article_index()*: string = discard

proc homepage_index()*: string = discard