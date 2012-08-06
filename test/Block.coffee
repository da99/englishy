
assert = require 'assert'
ep     = require 'englishy'

new_block = () ->
  new ep.Block()

describe "Block", () ->

  describe "()", () ->

    it "sets text to an empty string", () ->
      assert.equal new_block().text(), ""
      
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

