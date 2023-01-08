# Package

version       = "0.0.1"
author        = "kai sage"
description   = "A content management system written in nim"
license       = "MIT"
srcDir        = "src"
skipExt       = @["nim"]
bin           = @["ycms"]


# Dependencies

requires "nim >= 1.6.6", "jester >= 0.5"
