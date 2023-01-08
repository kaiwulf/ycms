 #[
 #    Connecting with sqlite database
]#

import db_sqlite
import "../structures.nim"

type
  Database* = ref object
    db: DbConn
  

proc open_db*(filename = "ycms.db"): Database =
  new result
  result.db = open(filename, "", "", "")

proc close*(database: Database) =
  database.db.close()

proc setup*(database: Database) =
  database.db.exec(sql"""
    CREATE TABLE IF NOT EXISTS article(
      id text,
      publicationDate text,
      title text,
      summary text,
      content text
    );
  """)

proc post*(database: Database, article: Article) =
  database.db.exec(sql"INSERT INTO article VALUES (?,?,?,?,?);",
  article.id, article.publicationDate, article.title, article.summary, article.content)

# proc delete*(database: Database) =
#   echo("delete article")
#   database.db.exec(sql"# remove from database")

# fetch article from db as an article
proc fetch_article*(database: Database, id: string): Article =
  let title = database.db.getValue(sql"SELECT title FROM article WHERE id = ?", id)
  let publicationDate = database.db.getValue(sql"SELECT publicationDate FROM article WHERE id = ?", id)
  let summary = database.db.getValue(sql"SELECT summary FROM article WHERE id = ?", id)
  let content = database.db.getValue(sql"SELECT content FROM article WHERE id = ?", id)
  let article = Article(id: id, publicationDate: publicationDate, title: title, summary: summary, content: content)
  return article

# fetch article from db as sequence
proc search*(database: Database, id: string): seq[string] =
  var row: seq[string]
  row = database.db.getRow(
    sql"SELECT id, publicationDate, title, summary, content FROM article WHERE id = ?;", id
    )
  if row[0].len == 0:
    return @[]
  else:
    return row

# proc filler_func_name =
#   var dataTest = db.getValue(sql"SELECT data FROM test WHERE id = ?", 1)
#   ## Calculate sequence size from buffer size
#   let seqSize = int(dataTest.len*sizeof(byte)/sizeof(float64))
#   ## Copy binary string data in dataTest into a seq
#   var res: seq[float64] = newSeq[float64](seqSize)
#   copyMem(unsafeAddr(res[0]), addr(dataTest[0]), dataTest.len)
  
#   ## Check datas obtained is identical
#   doAssert res == orig

# proc getList(numRows: int, publicationDate: int) =
#     list = [0..numRows, string]

#     var 


#     let sql = db.prepare(sql"SELECT SQL_CALC_FOUND_ROWS *, UNIX_TIMESTAMP(publicationDate) AS ? FROM articles ORDER BY ? DESC LIMIT ?", publicationDate, publicationDate, numRows)
#     var article: Article
#     sql.bindParams(publicationDate)
#     result = list