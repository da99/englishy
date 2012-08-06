
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
    
  strip: () ->
    @str.replace(/^\s+|\s+$/g, '')
    
  is_empty: () ->
    @str.length is 0

  is_whitespace: () ->
    return( @strip().length is 0 )
  
  strip_beginning_empty_lines: (lines) ->
    arr = []
    for line in lines 
      if (line.englishy('strip') != "" )
        arr.push line
    arr
  
  remove_indentation: () ->
    return "" if @strip() is ""
    lines = @strip_beginning_empty_lines( @str.split("\n") )
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
    @d.block = new Englishy.Block()

  update_number: (n) ->
    @d.number = n
    
  update_text: (str) ->
    @d.text = str

  append: (str) ->
    @.text = "#{@text()}#{str}"

exports.Block = class Block
  constructor: () ->
    @d = {}
    @d.text = ""
    @regex = {}
    @regex.new_lines_at_start = /^[\n]+/
    @regex.new_lines_at_end   = /[\n]+$/
    @regex.whitespace         = /^\s+|\s+$/g
    
  is_empty: () ->
    @text().length is 0

  is_whitespace: () ->
    @text().replace(@regex.whitespace, '') is ""
    
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
    @HEAD_WHITE_SPACE = /^\s/
    @END_PERIOD = /\.$/
    @END_COLON  = /\:$/
    
    @string = str.replace(/\t/, "  ").replace(/\r/, "")
    @lines = []
    @error = null
    @parse()

  record_error: (msg) ->
    err = new Error(msg)
    err.msg = msg
      
    @lines = err
    @error = @lines
    
  last_error: () ->
    @error

  last_line: () ->
    last = @lines.last()
    last and last.text

  last_block: () ->
    last = @lines.last()
    last and last.block().text

  append_to_line: (str) ->
    @lines.last().append str

  append_to_block: (l) ->
    @last_block().append_line l

  push_new_line: (l) ->
    new_line = new @Line()
    new_line.append l
    if @start_of_block(l)
      new_line.create_block()
    @lines.push new_line
  

  array: () ->
    @lines

  in_sentence: () ->
    return false if !@last_line()
    return false if @in_block()
    l = @strip @last_line()
    !( @END_PERIOD.test(l) )
  
  in_block: () ->
    return false if @is_empty()
    @last_line().has_block()

  start_of_block: (line) ->
    @END_COLON.test @strip(line)

  full_sentence: (line) ->
    @END_PERIOD.test @strip(line)
    
  _process_line: (line) ->
    # Skip empty lines.
    return null if @is_empty(line) and !@in_block() and !@in_sentence()
    
    l = @strip(line)
    
    begins_with_whitespace = @HEAD_WHITE_SPACE.test(line)
    
    if @in_block()

      if line.length is 0 and @last_block() is ''
        return line

      if @is_block_empty() and line.length > 0 and @is_empty(l)
        @append_to_block( line + "\n" )
        return line

      if (begins_with_whitespace or @is_empty(l))
        @append_to_block( line + "\n" )
        return line
    
    if !@in_sentence() and ( @start_of_block(l) or @full_sentence(l) )
      @push_new_line l
      return l
    
    # Are we continuing a previous sentence?
    if @in_sentence()

      # Error check: Start of block not allowed after incomplete sentence.
      if @start_of_block(l)
        return @record_error("Incomplete sentence before block: #{@last_line()}")

      return @append_to_line(line)

    
    if !@in_block() and !@full_sentence(l)
      return @push_new_line( line )

    @unknown_fragment line

  unknown_fragment: (l) ->
    @record_error "Unknown fragment: #{l}"

  parse: () ->
    
    raw_lines = @remove_indentation(@string).split("\n")
    @_process_line(raw_lines.shift()) while (@error is null) and raw_lines.length > 0
    # Final touches.
    for line in @lines
      line.cleanup()

    if @lines.last && @in_sentence()
      @unknown_fragment @last_line()
    @lines




# exports.Stringy = Stringy
# exports.Line = Line
# exports.Block = Block
# exports.Englishy = Englishy
