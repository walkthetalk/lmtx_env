if not modules then modules = { } end modules ['t-pretty-console'] = {
        version   = 0.9,
        comment   = "Companion to t-pretty-console.mkxl",
        author    = "Yi Qingliang",
        copyright = "2023 Yi Qingliang",
        license   = "GNU General Public License version 3"
    }
    
    local handler = visualizers.newhandler {
        startinline  = function() context.ConsoleSnippet(false,"{") end,
        stopinline   = function() context("}") end,
        startdisplay = function() context.startConsoleSnippet() end,
        stopdisplay  = function() context.stopConsoleSnippet() end ,

        ftest     = function(s)
                            context.verbatim.ConsoleSnippet(s)
                        end,
    }

    local grammar = visualizers.newgrammar(
       "default",
       {
          "visualizer",
          visualizer = visualizers.makepattern(handler, "ftest", lpeg.patterns.anything^0),
       }
    )
    
    local parser = lpeg.P(grammar)
    
    visualizers.register("console", { parser = parser, handler = handler, grammar = grammar } )
