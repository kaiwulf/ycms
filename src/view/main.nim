#? stdtmpl(subsChar = '$', metaChar = '!')
!
!proc main_page*(): string =
!   result = ""
<!DOCTYPE html>
    <body>
        <link rel="stylesheet" href="style.css">
        <title>kaiwulf.dev</title>
        <div id=container>
            <h1>Website</h1>
            <div id="content">
                <h2>header</h2>
                <a href="./blog_main">the kaiblog</a>
            </div>
        <div id=content>
            <h2>proj1 with webassembly?</h2>
        </div>
        </div>
    </body>
</html>
!end proc
!
! when isMainModule:
!   echo(main_page())
! end when