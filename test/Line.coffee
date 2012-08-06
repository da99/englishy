

assert = require 'assert'
ep     = require 'englishy'

new_line = (args...) ->
  new ep.Line(args...)
  
describe "Line", () ->

  describe "()", () ->

    it "sets number to undefined", () ->
      assert.equal new_line().number(), undefined

    it "does not have a block", () ->
      assert.equal new_line().has_block(), false

    it "is empty", () ->
      assert.equal new_line().is_empty(), true

  describe "append(text)", () ->
    it "appends text", () ->
      line = new_line()
      line.append "a"
      line.append "b"
      line.append "c"
      assert.equal line.text(), "abc"
