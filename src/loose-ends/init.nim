import std/db_sqlite
import parsecfg

let dict = loadConfig("config.cfg")

let db_user   = dict.getSectionValue("Database", "user")
let db_pass   = dict.getSectionValue("Database", "pass")
let db_name   = dict.getSectionValue("Database", "name")
let db_host   = dict.getSectionValue("Database", "host")

let mainURL   = dict.getSectionValue("Server", "url")
let mainPort  = parseInt dict.getSectionValue("Server", "port")
let mainWebsite = dict.getSectionValue("Server", "website")

var db*: DbConn

type
    uData* = ref object of RootObj
        loggedIn*: bool
        userid, username*, userpass*, email*: string
        req*: Request

proc init(ycms_db: var uData) =
    ycms_db.userpass = ""
    ycms_db.username = ""
    ycms_db.userid   = ""
    ycms_db.loggedIn = false
