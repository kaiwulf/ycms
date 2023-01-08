#? stdtmpl(subsChar = '$', metaChar = '!')
!import strutils
!import get_articles
!import render_article
!import ../structures
!
!proc `$!`(text: string): string =
!   text.escape()
!end proc
!
!proc render_blog_articles(num: int): string =
!   var x: string
!   let articles = get_articles_from_db(num)
!   for arts in articles:
!       x = header(arts.title) & body(arts.title, arts.content, arts.publicationDate) &  footer()
!   end for
!   return x
!end proc
!
! # num_articles is number of 
! # will eventually set num_articles equal to articles_displayed: int, assigned by backend configuration
!let num_articles = 3
! # num_articles_page is number of articles per page which is configured in backend
!let num_articles_page = 5
!proc render_blog_main*(title: string, content: string, header: string, articles: seq[Article]): string =
!result = ""
<!DOCTYPE html>
    <body>
        <link rel="stylesheet" href="../style.css">
        <title>${$!title}</title>
        <div id=container>
            <h1>${$!title}</h1>
            <div id=content>
                <h2>${$!header}</h2>
                ${$!render_blog_articles(num_articles_page)}
                
            </div>
        </div>
    <!--    <div class="dropdown">
            <button class="dropbtn">Dropdown</button>
            <div class="dropdown-content">
                ${$!num_menu_tags(num_articles, num_articles_page)}
    </div>  -->
    </div>
</body>
</html>
!end proc
! # when isMainModule:
! #   echo(render_blog_main("kaiwulf<>", "this is the content", "THIS IS IT!", get_articles_from_db(num_articles)))
! # end when