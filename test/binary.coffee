expect = require('chai').expect
binary = require '../src/binary'

hex = (s) ->
  s
    .replace ' ', ''
    .match /.{1,2}/g
    .map (byte) -> parseInt byte, 16

describe 'binary float', ->
  it 'should parse zero', ->
    expect(binary.float hex '0000 0000').to.equal 0
  it 'should parse negative zero', ->
    expect(binary.float hex '8000 0000').to.equal -0
  it 'should parse infinity', ->
    expect(binary.float hex '7f80 0000').to.equal Infinity
  it 'should parse negative infinity', ->
    expect(binary.float hex 'ff80 0000').to.equal -Infinity
  it 'should parse NaN', ->
    expect(isNaN binary.float hex '7fff ffff').to.be.true()
  it 'should parse negative NaN', ->
    expect(isNaN binary.float hex 'ffff ffff').to.be.true()
  it 'should parse one', ->
    expect(binary.float hex '3f80 0000').to.equal 1
  it 'should parse negative 2', ->
    expect(binary.float hex 'c000 0000').to.equal -2
  it 'should parse max float', ->
    expect(binary.float hex '7f7f ffff').to.equal 3.4028234663852886e+38
  it 'should parse one third', ->
    expect(binary.float hex '3eaa aaab').to.equal 0.3333333432674408
describe 'binary double', ->
  it 'should parse zero', ->
    expect(binary.float hex '0000 0000 0000 0000').to.equal 0
  it 'should parse negative zero', ->
    expect(binary.float hex '8000 0000 0000 0000').to.equal -0
  it 'should parse infinity', ->
    expect(binary.float hex '7ff0 0000 0000 0000').to.equal Infinity
  it 'should parse negative infinity', ->
    expect(binary.float hex 'fff0 0000 0000 0000').to.equal -Infinity
  it 'should parse NaN', ->
    expect(isNaN binary.float hex '7fff ffff ffff ffff').to.be.true()
  it 'should parse negative NaN', ->
    expect(isNaN binary.float hex 'ffff ffff ffff ffff').to.be.true()
  it 'should parse one', ->
    expect(binary.float hex '3ff0 0000 0000 0000').to.equal 1
  it 'should parse 2', ->
    expect(binary.float hex '4000 0000 0000 0000').to.equal 2
  it 'should parse negative 2', ->
    expect(binary.float hex 'c000 0000 0000 0000').to.equal -2
  it 'should parse max double', ->
    expect(binary.float hex '7fef ffff ffff ffff').to.equal 3.4028234663852886e+38
  it 'should parse one third', ->
    expect(binary.float hex '3fd5 5555 5555 5555').to.equal 0.3333333134651184