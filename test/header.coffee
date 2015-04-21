expect = require('chai').expect
fs = require 'fs'
Header = require '../src/header'

load = ->
  buf = fs.readFileSync './examples/singledim.nc', encoding: null
  data = new Uint8Array buf
  new Header data

describe 'header', ->
  it 'should load a file', ->
    header = load()
    expect(header.lex.i).to.equal 0
  it 'should parse magic', ->
    header = load()
    magic = header.magic()
    expect(magic.number).to.equal 1
    expect(header.lex.i).to.equal 4
  it 'should parse records', ->
    header = load()
    header.magic()
    records = header.numrecs()
    expect(records.type).to.equal 'fixed'
    expect(records.number).to.equal 0
    expect(header.lex.i).to.equal 8
  it 'should parse dimensions', ->
    header = load()
    header.magic()
    header.numrecs()
    dimensions = header.dim_list()
    expect(dimensions).to.have.length 1
    expect(dimensions[0].length).to.be.equal 5
    expect(header.lex.i).to.equal 28
  it 'should parse attributes', ->
    header = load()
    header.magic()
    header.numrecs()
    header.dim_list()
    attributes = header.gatt_list()
    expect(attributes).to.be.empty()
    expect(header.lex.i).to.equal 36
  it 'should parse variables', ->
    header = load()
    header.magic()
    header.numrecs()
    header.dim_list()
    header.gatt_list()
    variables = header.var_list()
    expect(variables).to.have.property 'vx'
    expect(variables).to.have.property 'vx'
    expect(variables.vx.dimensions).to.have.length 1
    expect(variables.vx.dimensions[0]).to.be.equal 0
    expect(header.lex.i).to.equal 80