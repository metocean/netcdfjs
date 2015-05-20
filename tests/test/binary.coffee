expect = require('chai').expect
binary = require '../src/binary'

hex = (s) ->
  s
    .replace ' ', ''
    .match /.{1,2}/g
    .map (byte) -> parseInt byte, 16

describe 'reading floats', ->
  it 'should parse zero', ->
    expect(binary.readFloat hex '0000 0000').to.equal 0
  it 'should parse negative zero', ->
    expect(binary.readFloat hex '8000 0000').to.equal -0
  it 'should parse infinity', ->
    expect(binary.readFloat hex '7f80 0000').to.equal Infinity
  it 'should parse negative infinity', ->
    expect(binary.readFloat hex 'ff80 0000').to.equal -Infinity
  it 'should parse NaN', ->
    expect(isNaN binary.readFloat hex '7fff ffff').to.be.true()
  it 'should parse negative NaN', ->
    expect(isNaN binary.readFloat hex 'ffff ffff').to.be.true()
  it 'should parse one', ->
    expect(binary.readFloat hex '3f80 0000').to.equal 1
  it 'should parse negative 2', ->
    expect(binary.readFloat hex 'c000 0000').to.equal -2
  it 'should parse max float', ->
    expect(binary.readFloat hex '7f7f ffff').to.equal 3.4028234663852886e+38
  it 'should parse one third', ->
    expect(binary.readFloat hex '3eaa aaab').to.equal 0.3333333432674408
describe 'reading doubles', ->
  it 'should parse zero', ->
    expect(binary.readDouble hex '0000 0000 0000 0000').to.equal 0
  it 'should parse negative zero', ->
    expect(binary.readDouble hex '8000 0000 0000 0000').to.equal -0
  it 'should parse infinity', ->
    expect(binary.readDouble hex '7ff0 0000 0000 0000').to.equal Infinity
  it 'should parse negative infinity', ->
    expect(binary.readDouble hex 'fff0 0000 0000 0000').to.equal -Infinity
  it 'should parse NaN', ->
    expect(isNaN binary.readDouble hex '7fff ffff ffff ffff').to.be.true()
  it 'should parse negative NaN', ->
    expect(isNaN binary.readDouble hex 'ffff ffff ffff ffff').to.be.true()
  it 'should parse one', ->
    expect(binary.readDouble hex '3ff0 0000 0000 0000').to.equal 1
  it 'should parse 2', ->
    expect(binary.readDouble hex '4000 0000 0000 0000').to.equal 2
  it 'should parse negative 2', ->
    expect(binary.readDouble hex 'c000 0000 0000 0000').to.equal -2
  it 'should parse max double', ->
    expect(binary.readDouble hex '7fef ffff ffff ffff').to.equal 1.7976923312185979e+308
  it 'should parse one third', ->
    expect(binary.readDouble hex '3fd5 5555 5555 5555').to.equal 0.3333332588263905