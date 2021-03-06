assert = require 'assert'
ep     = require 'englishy'


strings = (arr) ->
  new_arr = []
  for line_and_block in arr
    line     = line_and_block[0]
    block    = line_and_block[1]
    new_line = ( v.value() for v in line_and_block[0] )
    
    if block
      new_arr.push [ new_line, block  ]
    else
      new_arr.push [ new_line ]
      
  new_arr

parse_it = (str) ->
  return (new ep.Englishy(str)).to_array()

to_tokens  = (str, args...) ->
  return strings (new ep.Englishy(str)).to_tokens(args...)

record_err = (f) ->
  err = null
  try
    f()
  catch e
    err = e
  err

must_equal = (actual, expected) ->
  assert.deepEqual actual, expected

describe 'Parsing to tokens', () ->

  it 'parses multiple sentences', () ->
    str = """
            This is a line.
            This is another line.
          """
    
    lines  = to_tokens(str)
    target = [
      [ "This is a line".whitespace_split()       ],
      [ "This is another line".whitespace_split() ],
    ]
    must_equal lines, target

  it 'does not split group of words surrounded by " marks', () ->
    str = """
            This is a, "a group of words", "another group".
            This is another line.
          """
    
    lines  = to_tokens(str)
    target = [
      [ ["This", "is", "a,", 'a group of words', ',', 'another group' ] ],
      [ ["This", "is", "another", "line"]          ],
    ]
    assert.deepEqual lines, target

  it 'splits words partially surrounded by " marks: hi " hello', () ->
    str = """
            This is a, "a group" of "words.
            This is another line.
          """
    
    lines  = to_tokens(str)
    target = [
      [ ['This', 'is', 'a,', 'a group', 'of', '"words'] ],
      [ ["This", "is", "another", "line"] ],
    ]
    assert.deepEqual lines, target


  it "separates variables if given a pattern: .to_tokens( /(!>[^<]+<)/ ) ", () ->
    str = """
            !>OP<: do this +!>Num<.
            !>Do Op<: do this +!>Num 1<.
          """
    
    lines  = to_tokens(str, /(!>[^>]+<)/ )
    target = [
      [ ['!>OP<', ':', 'do', 'this', '+', '!>Num<'] ],
      [ ['!>Do Op<', ':', 'do', 'this', '+', '!>Num 1<'] ]
    ]
    assert.deepEqual lines, target

  it "does not separate variables if they are in a quotation marked string", () ->
    str = """
            !>OP<: do this +!>Num< "!>String<".
            !>Do Op<: do this +!>Num 1< "!>NU< is nice".
          """
    
    lines  = to_tokens(str, /(!>[^>]+<)/ )
    target = [
      [ ['!>OP<', ':', 'do', 'this', '+', '!>Num<', '!>String<' ] ],
      [ ['!>Do Op<', ':', 'do', 'this', '+', '!>Num 1<', '!>NU< is nice' ] ]
    ]
    assert.deepEqual lines, target

  it "returns a Block as the second argument.", () ->
     str = """
       One is: 1.
       This is a block:

         Block 1.
         Block 2.
     """

     tokens = to_tokens(str)
     assert.equal tokens[1][1].text(), "Block 1.\nBlock 2."


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
    must_equal lines, [["This is A."], ["This is B:", "Block line 1.\nBlock line 2."] ]

  it "parses blocks surrounded by empty lines of spaces w/ irregular indentation.", () ->
    lines = parse_it("  This is A.\n  This is B:\n    \n   Block\n    \n")
    must_equal lines, [["This is A."], ["This is B:", " Block"] ]
  
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

