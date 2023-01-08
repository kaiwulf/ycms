 #[
 #   App state machine
]#

# Imports
import strutils, sequtils, asyncdispatch
import jester, templates

import std/tables

import article

# Application state
var nextId*    = 1
var articleItems* = newSeq[Article]()
var stateSeq* = @[]

routes:

    get "/":            resp render.index()
    get "/archive":     resp render.index()

    post "/archive":
        render.archive()
        resp render.index()
    
runForever()