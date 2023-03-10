#? stdtmpl(subChar = '$', metaChar = '!', toString = "xmltree.escape")
!import xmltree
!import render_article
!import get_articles
!import strformat
!import ../model/sqlite
!import ../structures
!
!proc `$!`(text: string): string =
!   text.escape()
!end proc
!
!proc render_blog_summary*(num: int): string =
!   result = ""
    <div>
!   var title: string
!   var summary: string
!   var id: string
!   var db = open_db()
!   var summaries = get_summary_from_db(num)
!
!   for i in 0 .. num:
!       title = summaries[i][0]
!       summary = summaries[i][1]
!       id = summaries[i][2]
        <title><a href="article_${$!id}">${$!title}</a></title>
        <div>
            ${$!summary}
            <span>string</span>
        </div>
!        echo fmt"{id} {summary} {title}"
!   end for
    </div>
!   db.close()
!end proc
!
!proc render_blog_articles*(num_id: int): string =
!   var x: string
!   var articles = get_articles_from_db(num_id)
!   for arts in articles:
!       x = header(arts.title) & body(arts.title, arts.content, arts.publicationDate) &  footer()
!   end for
!   return x
!end proc