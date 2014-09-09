JSCK = require "../../src/draft3"

JSONSchema= require('jsonschema').Validator
JSV = require("JSV").JSV

Benchmark = require "../benchmark.coffee"

schema = require "./schema"
valid_doc = require "./valid_doc.coffee"

repeats = 256

jsck = new Benchmark "JSCK: valid document, #{repeats} times", (bm) ->
  bm.setup -> new JSCK(schema)
  bm.measure (validator) ->
    for i in [1..repeats]
      valid = validator.validate(valid_doc)


jsonschema = new Benchmark "jsonschema: valid document, #{repeats} times", (bm) ->
  bm.setup -> new JSONSchema()
  bm.measure (validator) ->
    for i in [1..repeats]
      errors = validator.validate(valid_doc, schema).errors

jsv_bm = new Benchmark "JSV: valid document, #{repeats} times", (bm) ->
  bm.setup ->
    jsv = JSV.createEnvironment("json-schema-draft-03")
    jsv.createSchema(schema)
  bm.measure (validator) ->
    for i in [1..repeats]
      errors = validator.validate(valid_doc).errors



results = Benchmark.compare [jsck, jsonschema, jsv_bm],
  #warmup: 8
  iterations: 16

console.log()
for name, result of results
  console.log name, result.summarize()
  console.log()



