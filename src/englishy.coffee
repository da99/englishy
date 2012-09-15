
_ = require "underscore"
string_da99 = require "string_da99"

exports.stringy_compare = ( a, b ) ->
  str_a = if a.value
    a.value()
  else
    a

  str_b = if b.value
    b.value()
  else
    b

  str_a is str_b
    
if !Array.prototype.last
  Array.prototype.last = (n) ->
    n = if typeof n != 'undefined' 
          n
        else
          1
    return this[@.length - n]
    
exports.Stringy = class Stringy
  
  @is_quoted: (str) ->
    _.first(str) is '"' and _.last(str) is '"'

  @to_strings: (arr) ->
    new_arr = []
    for v in arr
      new_arr.push if _.isObject(v) and v.is_quoted
        if v.is_quoted()
          "\"#{v.value()}\""
        else
          v.value()
      else
        "#{v}"
    new_arr


  constructor: (str) ->
    if arguments.length isnt 1
      throw new Error "Only one argument is allowed: #{ (v for v in arguments).join(', ') }"
    
    @quoted = false
    
    @target = if Stringy.is_quoted(str) 
      @quoted = true
      str.substring( 1, str.length - 1 )
    else
      str


  is_stringy: () ->
    true

  is_quoted: () ->
    @quoted

  value: () ->
    @target

exports.Line = class Line
  constructor: () ->
    @d = {}
    @d.number = undefined
    @d.text = ""
    @d.block = null

  is_empty: () ->
    @d.text.length is 0

  has_block: () ->
    @d.block != null

  number: () ->
    @d.number

  text: () ->
    @d.text

  block: () ->
    @d.block

  create_block: () ->
    return false if @has_block()
    @d.block = new Block()

  update_number: (n) ->
    @d.number = n
    
  update_text: (str) ->
    @d.text = str

  append: (str) ->
    @d.text = "#{@text()}#{str}"

  finish_writing: () ->
    b = @block() 
    b and b.finish_writing()

exports.Block = class Block
  constructor: (str) ->
    @d = {}
    @d.text = str || ""
    @regex = {}
    @regex.new_lines_at_start = /^[\n]+/
    @regex.new_lines_at_end   = /[\n]+$/
    @regex.whitespace         = /^\s+|\s+$/g
    
  text: () ->
    @d.text 

  is_empty: () ->
    @text().is_empty()

  is_whitespace: () ->
    @text().is_whitespace()
    
  text_line: (line_num) ->
    target_i = line_num - 1
    lines = (v for v in @text().strip().split("\n") when not v.is_whitespace() )
    
    target = lines[target_i]
    target || throw new Error("No text line ##{line_num}.")

  append: (str) ->
    @d.text = "#{@d.text}#{str}"
    
  append_line: (line) ->
    two = "  "
    if line.indexOf(two) is 0
      line = line.replace(two, "") 
    if @is_empty()
      @d.text = line
    else
      @d.text = "#{@text()}\n#{line}"
      
  finish_writing: () ->
    @d.text = @d.text.replace( @regex.new_lines_at_start, "" )
    @d.text = @d.text.replace( @regex.new_lines_at_end,   "" )
    @d.text
    
    
exports.Englishy = class Englishy
      
  constructor: (str) ->
    @d = {}
    @d.starting_text = str
    @d.working_text  = str.standardize()
    @lines = []
    @error = null
    @parse()

  record_error: (msg) ->
    err = new Error(msg)
    err.msg = msg
    throw err
      
    @lines = err
    @error = @lines
    
  last_error: () ->
    @error

  append_to_line: (str) ->
    @lines.last().append str

  append_to_block: (l) ->
    @lines.last().block().append_line l

  push_new_line: (l) ->
    new_line = new Line()
    new_line.append l
    if @start_of_block(l)
      new_line.create_block()
    @lines.push new_line
  

  @Quotation_Mark_Split: /("[^"]+")/g
  
  @pair_to_tokens: ( pair, var_regexp ) ->
    line  = pair[0].replace( /[.:]$/ , "" )
    block = pair[1]
    line_arr = line.split @Quotation_Mark_Split
    
    for val, i in line_arr
      piece = line_arr[i]
      line_arr[i] = if Stringy.is_quoted(piece) 
        new exports.Stringy piece
      else
        if var_regexp
          arr = []
          for v in piece.split(var_regexp)
            if v.strip && var_regexp.test(v)
              arr.push new exports.Stringy v
            else
              arr.push( (new exports.Stringy ws) for ws in v.whitespace_split() )
        else
          arr = ( (new exports.Stringy ws ) for ws in piece.whitespace_split() )

        arr

    line_arr_w_empty_strings = _.flatten(line_arr)
    line_arr = ( v for v in line_arr_w_empty_strings when v.value() isnt "")

    if block and !block.text
      [ line_arr, new Block(block) ]
    else if block and block.text
      [ line_arr, block ]
    else
      [ line_arr ]

  to_tokens: ( var_regexp ) ->
    tokens  = []
    for line in @lines
      if line.has_block()
        tokens.push @constructor.pair_to_tokens( [line.text(), line.block()] , var_regexp )
      else
        tokens.push @constructor.pair_to_tokens( [line.text()] , var_regexp )
    tokens

  to_array: () ->
    arr = []
    for line in @lines
      if line.has_block()
        arr.push [line.text(), line.block().text() ]
      else
        arr.push [line.text()]
    arr

  is_empty: () ->
    @lines.length is 0

  in_sentence: () ->
    return false if !@lines.last()
    return false if @in_block()
    l = @lines.last().text().strip()
    !( l.has_end_period() )
  
  in_block: () ->
    return false if @is_empty()
    @lines.last().has_block()

  start_of_block: (line) ->
    line.strip().has_end_colon()

  full_sentence: (line) ->
    line.strip().has_end_period()
    
  _process_line: (line) ->
    # Skip empty lines.
    return null if line.is_whitespace() and !@in_block() and !@in_sentence()
    return null if line.is_empty()      and !@in_block() and !@in_sentence()
    
    l = line.strip()
    
    if @in_block() and (line.begins_with_whitespace() || line.is_empty())
      b = @lines.last().block()
      return b.append_line( line  )
      
    
    if !@in_sentence() and ( @start_of_block(l) or @full_sentence(l) )
      @push_new_line l
      return l
    
    # Are we continuing a previous sentence?
    if @in_sentence()

      # Error check: Start of block not allowed after incomplete sentence.
      if @start_of_block(l)
        return @record_error("Incomplete sentence before block: #{@lines.last().text()}")

      return @append_to_line(line)

    
    if !@in_block() and !@full_sentence(l)
      return @push_new_line( line )

    @unknown_fragment line

  unknown_fragment: (l) ->
    throw @record_error "Unknown fragment: #{l}"

  parse: () ->
    
    raw_lines = @d.working_text.remove_indentation().split("\n")
    @_process_line(raw_lines.shift()) while (@error is null) and raw_lines.length > 0
    # Final touches.
    for line in @lines
      line.finish_writing()

    if @lines.last && @in_sentence()
      @unknown_fragment "'#{@lines.last().text()}'"
    @lines


