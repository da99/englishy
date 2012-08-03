assert = require 'assert'
ep     = require 'englishy_parser'

parse_it = (str) ->
  return (new ep.Englishy(str)).lines

must_equal = (actual, expected) ->
  assert.deepEqual actual, expected

describe 'Parsing sentences', () ->
  
  it 'multiple sentences', () ->
    str = """
            This is a line.
            This is another line.
          """
    
    lines  = parse_it(str)
    target = [ 
      [ "This is a line.", null],
      [ "This is another line.", null],
    ]
    must_equal lines, target
    
  
  it "sentences continued on another line", () ->
    str = """
          This is line one.
          This is a
            continued line.
          """
    
    lines = parse_it(str)
    target= [ 
      [ "This is line one.", null],
      [ "This is a   continued line.", null]
    ]
    must_equal lines, target

  it "multiple sentences separated by whitespace lines.", () ->
    str = """
            This is a line.
               
            This is line 2.
                      
            This is line 3.
               
          """
    lines = parse_it(str)
    target = [
      [ "This is a line.", null],
      [ "This is line 2.", null],
      [ "This is line 3.", null],
    ]
    must_equal lines, target

# end # === Walt sentences

describe "Parsing blocks", () ->

  it "parses blocks surrounded by empty lines of spaces with irregular indentation.", () ->
    lines = parse_it("""
                     This is A.
                     This is B:
                        
                       Block
                     
                     """)
    must_equal lines, [["This is A.", null], ["This is B:", "  Block\n\n"] ]
  
  it "removes empty lines surrounding block", () ->
    lines = parse_it("""
      This is A.
      This is B:
          
        Block line 1.
        Block line 2.
       
    """)
    must_equal lines, [["This is A.", null], ["This is B:", "  Block line 1.\n  Block line 2.\n \n"] ]
  
  it "does not remove last colon if line has no block.", () ->
    lines = parse_it("""
      This is A.
      This is :memory:
      This is B.
    """)
    must_equal lines, [
      ["This is A.", null],
      ["This is :memory:", ''],
      ["This is B.", null]
    ]

# end # === Walt blocks

describe "Returning errors", () ->
  
  it "if incomplete sentence is found", () ->
    err = parse_it("""
      This is one line.
      This is an incomp sent
    """)
    assert.ok     /incomp sent/.test(err.message)

  it "if incomplete sentence is found before start of a block", () ->
    err = parse_it("""
      This is one line.
      This is an incomp sent
      This is a block:
        Block
    """)
    assert.ok     /incomp sent$/.test(err.message)
  
# end # === Walt parsing errors

