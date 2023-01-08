# State
import strutils, sequtils, asyncdispatch
import jester, templates

import std/tables, std/sugar

type
    Article = object
        id*: string
        publicationDate*: string
        title*: string
        summary*: string
        content*: string

# Application state
type
    State = object
        var nextId*    = 1
        var articleItems* = newSeq[Article]()
        var stateSeq* = newSeq[string]()

proc init(article: Article): Table[string,string] =
    var
        aTable = {"id": article.id, "publicationDate": article.publicationDate, "title": article.title, "summary": article.summary, "content": article.content}.toTable
    result = aTable

proc storeDate(date: string): string =
    var seps: seq[string]
    var 
        mo: string
        day: string
        yr: string

    seps = split(date, {'-'})
    yr = seps[2]
    result = yr



# Procedures
proc add_article(publicationDate: string, title: string, summary: string, content: string) =
    State.articleItems.add Article(
        id:          $State.nextId,
        publicationDate: publicationDate,
        title: title,
        summary: summary,
        content: content
    )

    inc(State.nextId)

# proc index(): string =
#     return master.layout("article", render.index)

#[ unit testing functions
proc test() =
    var a = Article(id:"4",publicationDate:"12-11-2022",title: "dd",summary: "55",content: "66")
    var b = init(a)
    echo "a is ",b
    var s: string
    s = storeDate( b["publicationDate"] )
    echo "date str ",s

test() ]#