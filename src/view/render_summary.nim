#? stdtmpl(subChar = '$', metaChar = '!', toString = "xmltree.escape")
!import xmltree
!import render_article
!import get_articles
!
!proc `$!`(text: string): string =
!   text.escape()
!end proc
!
!proc render_blog_summary*(num: int): string =
!let db = open_db()
!let summaries = get_summary_from_db(num)
!result = ""
!   for i in 0 .. num:
!       summaries[i]
    <title><a href="article_${$!id}">${$!title}</a></title>
    <div>
        ${$!summary}
    </div>
!end proc
!
!proc render_blog_articles*(num_id: int): string =
!   var x: string
!   let num = intToStr(num_id)
!   let articles = get_articles_from_db(num)
!   for arts in articles:
!       x = header(arts.title) & body(arts.title, arts.content, arts.publicationDate) &  footer()
!   end for
!   return x
!end proc