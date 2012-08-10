
if !Array.prototype.last
  Array.prototype.last = (n) ->
    n = if typeof n != 'undefined' 
          n
        else
          1
    return this[@.length - n]
    
exports.Stringy = class Stringy
  constructor: (parent) ->
    @str = parent
    @HEAD_WHITE_SPACE = /^[\s]+/
    @END_PERIOD = /\.$/
    @END_COLON  = /\:$/
    
  standardize: () ->
    @str.replace(/\t/, "  ").replace(/\r/, "")
    
  strip: () ->
    @str.replace(/^\s+|\s+$/g, '')
    
  is_empty: () ->
    @str.length is 0

  is_whitespace: () ->
    return( @strip().length is 0 )
  
  begins_with_whitespace: () ->
    @HEAD_WHITE_SPACE.test @str
  has_end_period: () ->
    @END_PERIOD.test @str
  has_end_colon: () ->
    @END_COLON.test @str
    
  remove_end: (type) ->
    switch type
      when ".", "period"
        @str.replace @END_PERIOD, ""
      when ":", "colon"
        @str.replace @END_COLON, ""
      else
        @str.replace (new RegExp("\\#{type}$")), ""

  strip_beginning_empty_lines: (lines) ->
    arr = []
    for line in lines
      if (line.englishy('strip') != "" )
        arr.push line
    arr
  
  remove_indentation: () ->
    return "" if @strip() is ""
    lines = ( @str.split("\n") )
    indent_meta= @HEAD_WHITE_SPACE.exec(lines[0])
    if !indent_meta
      return lines.join("\n")
    indent = indent_meta[0]
    final = (l.replace(indent, "") for l in lines)
    final.join("\n")
  
String.prototype.englishy = (meth, args...) ->
  ( this.englishy_obj ?= new Stringy(this) )[meth](args...)
  
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
  constructor: () ->
    @d = {}
    @d.text = ""
    @regex = {}
    @regex.new_lines_at_start = /^[\n]+/
    @regex.new_lines_at_end   = /[\n]+$/
    @regex.whitespace         = /^\s+|\s+$/g
    
  text: () ->
    @d.text 

  is_empty: () ->
    @text().englishy('is_empty')

  is_whitespace: () ->
    @text().englishy('is_whitespace')
    
  append: (str) ->
    @d.text = "#{@d.text}#{str}"
    
  append_line: (line) ->
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
    @d.working_text  = str.englishy('standardize')
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
  

  to_array: () ->
    to_array = (line) ->
      if line.has_block()
        [line.text(), line.block().text() ]
      else
        [line.text()]
    (to_array(l) for l in @lines)

  is_empty: () ->
    @lines.length is 0

  in_sentence: () ->
    return false if !@lines.last()
    return false if @in_block()
    l = @lines.last().text().englishy('strip')
    !( l.englishy('has_end_period') )
  
  in_block: () ->
    return false if @is_empty()
    @lines.last().has_block()

  start_of_block: (line) ->
    line.englishy('strip').englishy('has_end_colon')

  full_sentence: (line) ->
    line.englishy('strip').englishy('has_end_period')
    
  _process_line: (line) ->
    # Skip empty lines.
    return null if line.englishy('is_whitespace') and !@in_block() and !@in_sentence()
    return null if line.englishy('is_empty') and !@in_block() and !@in_sentence()
    l = line.englishy('strip')
    
    if @in_block() and (line.englishy('begins_with_whitespace') || line.englishy('is_empty'))
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
    
    raw_lines = @d.working_text.englishy('remove_indentation').split("\n")
    @_process_line(raw_lines.shift()) while (@error is null) and raw_lines.length > 0
    # Final touches.
    for line in @lines
      line.finish_writing()

    if @lines.last && @in_sentence()
      @unknown_fragment "'#{@lines.last().text()}'"
    @lines




# exports.Stringy = Stringy
# exports.Line = Line
# exports.Block = Block
# exports.Englishy = Englishy
