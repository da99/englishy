assert = require 'assert'
ep     = require 'englishy'

describe 'Stringy constructor', () ->

  it "sets .is_quoted() to true if string is surrounded by quotes.", () ->
    str = new ep.Stringy '"test"'
    assert.equal str.is_quoted(), true

  it "removes surrounding quotation marks", () ->
    str = new ep.Stringy '"my string"'
    assert.equal str.value(), 'my string'


describe 'Stringy compare', () ->

  it "returns true if Stringy's value is same as string", () ->
    str     = "me"
    stringy = new ep.Stringy str
    assert.equal ep.stringy_compare(stringy, str), true

  it "returns false if Stringy's value is not same as string", () ->
    str     = "me"
    stringy = new ep.Stringy "not me"
    assert.equal ep.stringy_compare(stringy, str), false

  it 'returns true if both values are the same string', () ->
    str     = "me"
    assert.equal ep.stringy_compare(str, str), true

  it 'returns false if values are different strings', () ->
    assert.equal ep.stringy_compare("me", "not me"), false


describe 'Stringy.to_strings', () ->

  it "returns an array of Stringys as Strings.", () ->
    arr = ( (new ep.Stringy v) for v in 'abc'.split('') )
    assert.deepEqual ep.Stringy.to_strings(arr), ['a','b','c']

  for target in [ true, false, null, undefined ]
    it "turns #{target} to a string", () ->
      arr = ( (new ep.Stringy v) for v in 'abc'.split('') )
      arr.push target
      assert.deepEqual ep.Stringy.to_strings(arr), ['a','b','c', "#{target}"]
      
