#? stdtmpl(subsChar = '$', metaChar = '!')
!import strutils
!import get_articles
!#import render_article
!import render_summary
!#import ../structures
!
!proc `$!`(text: string): string =
!   text.escape()
!end proc
!
! # num_articles is number of 
! # will eventually set num_articles equal to articles_displayed: int, assigned by backend configuration
!let num_articles = 3
! # num_articles_page is number of articles per page which is configured in backend
!let num_articles_page = 5
!proc render_blog_main*(): string =
!result = ""
<!DOCTYPE html>
    <body>
        <link rel="stylesheet" type="text/css" href="style.css">
        <title>Adventures in Tech</title>
        <div id=container>
            <h1>header 1</h1>
            <div id=content>
                <h2>header 2</h2>
                <a href="render_summary"> render_blog_summary(num_articles_page) </a>
                
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
!writeFile("blog.html",result)
!end proc