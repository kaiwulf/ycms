import sqlite
import "../structures.nim"
import os

when isMainModule:
    removeFile("ycms.db")
    var db = open_db()
    db.setup()

    db.post(Article(id:"1452", publicationDate:"10-11-1023", title:"how to fly", summary:"you can fly", content:"weeee!"))

    let retrieve = db.search("1452")
    echo(retrieve)

    let article = db.fetch_article( "1452" )

    echo(article)