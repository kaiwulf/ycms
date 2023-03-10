#? stdtmpl(subsChar = '$', metaChar = '!', toString = "xmltree.escape")
!import xmltree
!
!proc `$!`(text: string): string =
!   text.escape()
!end proc
!
!proc header*(title: string): string =
!result = ""
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>${$!title}</title>
    <link rel="stylesheet" type="text/css" href="../style.css" />
  </head>
  <body>
    <div id="container">

      <a href="."><img id="logo" src="../logo.jpg" alt="Widget News" /></a>
!end proc
!
!proc footer*(): string =
!result = ""
</div>
    <div id="footer">
      Widget News &copy; 2011. All rights reserved. <a href="admin.php">Site Admin</a>
    </div>
    <div class="wideBox">
      <p>&copy; kaiwulf.dev | <a href="http://kaiwulf.dev">Back to Home</a></p>
      <p style="font-size: .8em; line-height: 1.5em;">
        <a rel="license" href="http://creativecommons.org/licenses/by/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by/3.0/88x31.png" /></a>
        <br />This <span xmlns:dc="http://purl.org/dc/elements/1.1/" href="http://purl.org/dc/dcmitype/Text" rel="dc:type">work</span> by 
        <a xmlns:cc="http://creativecommons.org/ns#" href="http://www.elated.com/" property="cc:attributionName" rel="cc:attributionURL">http://www.sagewulf.com/</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>.
      </p>
    </div>
    </div>
!end proc
!
!proc body*(title: string, content: string, publicationDate: string): string =
!result = ""
!
        <h1 id="title">${$!title}</h1>
        <span><div id="content">${$!content}</div></span>
!end proc
!
!proc full_article*(): string =
!   var x: string
!   x = header("kai's blog") & body("kai's blog", "this is it!", "5-23-2101") & footer()
!   return x
!end proc