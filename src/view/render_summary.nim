#? stdtmpl(subChar = '$', metaChar = '!', toString = "xmltree.escape")
!import xmltree
!import render_article
!import get_articles
!import ../model/sqlite
!
!proc `$!`(text: string): string =
!   text.escape()
!end proc
!
!proc render_blog_summary*(num: int): string =
!   let title: string
!   let summary: string
!   let id: string
!   var
!      db = open_db()
!      summaries = get_summary_from_db(num)
!   result = ""
    <div>
!   for i in 0 .. num:
!       title = summaries[i][0]
!       summary = summaries[i][1]
!       id = summaries[i][2]
        <title><a href="article_${$!id}">${$!title}</a></title>
        <div>
            ${$!summary}
        </div>
!   end for
    </div>
!   db.close()
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