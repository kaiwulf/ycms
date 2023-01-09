import ../structures
# import ../model/db
import ../model/sqlite
import system
import strutils

proc get_summary_from_db*(num_articles: int): seq[array[3,string]] =
    var article_summary: seq[array[3,string]]
    var db = open_db()

    for i in 0 .. num_articles:
        article_summary.add(db.fetch_summary( intToStr(i) ))
    return article_summary

proc get_articles_from_db*(num_articles: int): seq[Article] =
    var article_seq: seq[Article]
    var db = open_db()

    for i in 0 .. num_articles:
        article_seq.add(db.fetch_article( intToStr(i) ) )
    return article_seq

proc num_menu_tags*(num_articles: int, num_articles_page: int): string =
    if num_articles > num_articles_page:
        return intToStr(num_articles mod num_articles_page)