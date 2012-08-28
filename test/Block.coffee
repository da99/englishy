
assert = require 'assert'
ep     = require 'englishy'

new_block = (args...) ->
  new ep.Block(args...)

describe "Block", () ->

  describe "()", () ->

    it "sets text to an empty string", () ->
      assert.equal new_block().text(), ""
      
  describe "text_line(n)", () ->

    it "grabs first line that has is non-empty", () ->
      b = new_block(" \n \nText 1\n\nText 2" )
      assert.equal b.text_line(2), "Text 2"

    it "raises error if lines does not exist.", () ->
      b = new_block(" \n \nText 1\n\nText 2 " )
      err = null
      try 
        b.text_line(3)
      catch e
        err = e
        
      assert.equal err.message, "No text line #3."
      
    it "does not remove indentation", () ->
      b = new_block("  Text 1\n  Text 2\n    Text 3" )
      assert.equal b.text_line(3), "    Text 3"

  describe "append( text )", () ->
    it "appends text", () ->
      b = new_block()
      b.append("a")
      b.append("bc")
      assert.equal b.text(), "abc"
      
  describe "append_line( line )", () ->
    it "appends line preceded by a new line", () ->
      b = new_block()
      b.append("a")
      b.append_line("b")
      assert.equal b.text(), "a\nb"

    it "does not append a new line if it is the first line", () ->
      b = new_block()
      b.append("a line")
      assert.equal b.text(), "a line"

  describe 'is_empty()', () ->
    it "returns true if text is 0 length", () ->
      assert.equal new_block().is_empty(), true
    it "returns false if text contains nothing but whitespace", () ->
      b = new_block()
      b.append "  \n  "
      assert.equal b.is_empty(), false

  describe 'is_whitespace()', () ->
    it "returns true if text is 0 length", () ->
      assert.equal new_block().is_whitespace(), true
    it "returns true if text contains nothing but whitespace", () ->
      b = new_block()
      b.append "  \n  "
      assert.equal new_block().is_whitespace(), true
      
  describe 'finish_writing()', () ->

    it "removes any trailing consecutive new lines", () ->
      b = new_block()
      b.append "a\n\n\n"
      b.finish_writing()
      assert.equal b.text(), "a"

    it "does not remove new lines followed by empty spaces", () ->
      txt = "a\nb\nc\n  "
      b = new_block()
      b.append "#{txt}\n"
      b.finish_writing()
      assert.equal b.text(), txt

