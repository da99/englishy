
Englishy: Intro and Usage
================

A npm module providing simple line and blockquote parsing (w/o paragraphs):

    shell> npm install englishy
    
    my_str = """
    
      This is a line.
      This is a 2-line
        line.
      This is a line with a block:
        
        I am a block.
        I am also part of a block.

    """

    ep = require("englishy")
    parsed = new ep.Englishy(str)
    parsed.to_array()
    # ==>
      [ 
        [ "This is a line" ],
        [ "This is a 2-line line" ],
        [ "This is a line with a block", "  I am a block.\n  I am also part of a block."]
      ]

      
Why create this?
====
I plan on using it for my i\_love\_u npm package. 
You never heard of it, but it will be famous in 
several years.



