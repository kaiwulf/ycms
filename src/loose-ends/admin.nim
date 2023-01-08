import db_sqlite
import parsecfg
import jester

import init

let dict = loadConfig("config.cfg")

let db_user   = dict.getSectionValue("Database", "user")
let db_pass   = dict.getSectionValue("Database", "pass")
let db_name   = dict.getSectionValue("Database", "name")
let db_host   = dict.getSectionValue("Database", "host")

let mainURL   = dict.getSectionValue("Server", "url")
let mainPort  = parseInt dict.getSectionValue("Server", "port")
let mainWebsite = dict.getSectionValue("Server", "website")

# probably won't use
# var db: DbConn

type
    uData* = ref object of RootObj
        loggedIn*: bool
        userid, username*, userpass*, email*: string
        req*: Request

proc init(c: var uData) =
    c.userpass = ""
    c.username = ""
    c.userid   = ""
    c.loggedIn = false

func loggedIn(c: uData): bool =
    c.username.len > 0

proc checkLoggedIn(c: var uData) =
    if not c.req.cookies.hasKey("sid"): return

    let sid = c.req.cookies["sid"]

    if execAffectedRows(db, sql("UPDATE session SET lastModified = " & $toInt(epochTime()) & " " & "WHERE ip =? AND key = ?")), c.req.ip, sid) > 0:
        c.userid = getValue(db, sql"SELECT userid FROM session WHERE ip = ? AND key = ?", c.req.ip, sid)
        let row = getRow(db, sql"SELECT name, email, status FROM person WHERE id = ?", c.userid)
        c.username = row[0]
        c.email = toLowerAscii(row[1])
        discard tryExec(db, sql"UPDATE person SET lastOnline = ? WHERE id = ?", toInt(epochTime()), c.userid)
    else:
        c.loggedIn = false

proc login(c: var uData, email, pass: string): tuple[b: bool, s: string] =
  const query = sql"SELECT id, name, password, email, salt, status FROM person WHERE email = ?"
  if email.len == 0 or pass.len == 0:
    return (false, "Missing password or username")

  for row in fastRows(db, query, toLowerAscii(email)):
    if row[2] == makePassword(pass, row[4], row[2]):
      c.userid   = row[0]
      c.username = row[1]
      c.userpass = row[2]
      c.email    = toLowerAscii(row[3])
      let key = makeSessionKey()
      exec(db, sql"INSERT INTO session (ip, key, userid) VALUES (?, ?, ?)", c.req.ip, key, row[0])

      info("Login successful")
      return (true, key)

  info("Login failed")
  return (false, "Login failed")

proc logout(c: var uData) =
  c.username = ""
  c.userpass = ""
  const query = sql"DELETE FROM session WHERE ip = ? AND key = ?"
  exec(db, query, c.req.ip, c.req.cookies["sid"])


template createTFD() =
  var c {.inject.}: uData
  new(c)
  init(c)
  c.req = request
  if cookies(request).len > 0:
    checkLoggedIn(c)
  c.loggedIn = loggedIn(c)


when isMainModule:
  echo "yCMS is now running: " & $now()
  if "newdb" in commandLineParams() or not fileExists(db_host):
    generateDB()
    quit()

  try:
    db = open(connection=db_host, user=db_user, password=db_pass, database=db_name)
    info("Connection to DB is established.")
  except:
    fatal("Connection to DB could not be established.")
    sleep(5_000)
    quit()

  if "newuser" in commandLineParams():
    createAdminUser(db, commandLineParams())
    quit()