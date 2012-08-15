assert = require 'assert'
ep     = require 'englishy'

parse_it = (str) ->
  return (new ep.Englishy(str)).to_array()

record_err = (f) ->
  err = null
  try
    f()
  catch e
    err = e
  err

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
      [ "This is a line."],
      [ "This is another line."],
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
      [ "This is line one." ],
      [ "This is a  continued line." ]
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
      [ "This is a line." ],
      [ "This is line 2." ],
      [ "This is line 3." ],
    ]
    must_equal lines, target

# end # === Walt sentences

describe "Parsing blocks", () ->
  
  it "removes empty lines surrounding block w/ no spaces past block indentation", () ->
    lines = parse_it("""
      This is A.
      This is B:
      
        Block line 1.
        Block line 2.
      
      """)
    must_equal lines, [["This is A."], ["This is B:", "  Block line 1.\n  Block line 2."] ]

  it "parses blocks surrounded by empty lines of spaces w/ irregular indentation.", () ->
    lines = parse_it("  This is A.\n  This is B:\n    \n    Block\n    \n")
    must_equal lines, [["This is A."], ["This is B:", "  \n  Block\n  "] ]
  
  it "does not remove last colon if line has no block.", () ->
    lines = parse_it("""
      This is A.
      This is :memory:
      This is B.
    """)
    must_equal lines, [
      ["This is A."],
      ["This is :memory:", ''],
      ["This is B."]
    ]

# end # === Walt blocks

describe "Returning errors", () ->
  
  it "if incomplete sentence is found", () ->
    err = record_err () ->
      parse_it("""
        This is one line.
        This is an incomp sent
      """)
    assert.ok /incomp sent/.test(err.message)

  it "if incomplete sentence is found before start of a block", () ->
    err = record_err () ->
      parse_it("""
        This is one line.
        This is an incomp sent
        This is a block:
          Block
      """)
    assert.ok /This is an incomp sent$/.test(err.message)
  
# end # === Walt parsing errors

