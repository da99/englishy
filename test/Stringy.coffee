

assert = require 'assert'
ep     = require 'englishy'


describe "Stringy", () ->

  describe ".strip()", () ->
    it "removes all whitespace", () ->
      assert.equal " a ".englishy('strip'), "a"

  describe ".is_empty()", () ->
    it "returns true if length is 0", () ->
      assert.equal "".englishy('is_empty'), true
    it "returns false if it contains nothing but whitespace", () ->
      assert.equal " ".englishy('is_empty'), false

  describe ".is_whitespace()", () ->
    it "returns true if contains nothing but whitespace", () ->
      assert.equal " ".englishy('is_whitespace'), true
    it "returns true if empty", () ->
      assert.equal "".englishy('is_whitespace'), true

  describe ".remove_indentation()", () ->
    it "removes beginning indentation of each line.", () ->
      str = "  a\n  b\n  c"
      assert.equal str.englishy('remove_indentation'), "a\nb\nc"
    it "returns same string if first line has no indentation", () ->
      str = "a\n  b\n  c"
      assert.equal str.englishy('remove_indentation'), str
    it "does not remove lines with only whitespace", () ->
      str = "  a\n    \n  b"
      assert.equal str.englishy('remove_indentation'), "a\n  \nb"
    it "does not remove empty lines after de-indentation", () ->
      str = "  a\n  \n  b"
      assert.equal str.englishy('remove_indentation'), "a\n\nb"

  describe '.remove_end( char )', () ->
    
    it 'removes ending period: .', () ->
      str = "i love ice cream"
      assert.equal "#{str}.".englishy('remove_end', '.'), str
      
    it 'removes ending colon: :', () ->
      str = "i love cheesecake"
      assert.equal "#{str}:".englishy('remove_end', ':'), str
      
    it 'removes random char: ^', () ->
      str = "^i love Heaven"
      assert.equal "#{str}^".englishy('remove_end', '^'), str
      
      
