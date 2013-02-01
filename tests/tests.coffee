vows = require 'vows'
assert = require 'assert'
sql = require '../index'

module.exports = vows.describe('Le SQL querying in le Javascript')
.addBatch
  'INSERT query':
    topic: ->
      new sql.Query()
      .insertInto('roundtable')
      .values
        camelot: 'a silly place'
        kings: 1
        knights: ['Bedivere', 'Lancelot', 'Robin']
      .toString()

    'should be correct for string, numeric, array': (topic) ->
      expected = """INSERT INTO roundtable (camelot, kings, knights) VALUES ('a silly place', 1, '{"Bedivere", "Lancelot", "Robin"}');"""
      assert.equal topic, expected

  'UPDATE query':
    topic: new sql.Query()
      .update('roundtable')
      .set
        camelot: 'a silly place'
        kings: 1
        knights: ['Bedivere', 'Lancelot', 'Robin']
      .where
        id: 35
      .toString()
    'should be correct for string, numeric, array': (topic) ->
      expected = """UPDATE roundtable SET camelot = 'a silly place', kings = 1, knights = '{"Bedivere", "Lancelot", "Robin"}' WHERE id = 35;"""
      assert.equal topic, expected

  'Simple SELECT * query to retrieve a record by id':
    topic: new sql.Query()
      .selectAll()
      .from('roundtable')
      .where
        clique: 'stoners'
        id: 2363245
      .limit(1)
      .toString()
    'should be correct': (topic) ->
      expected = """SELECT * FROM roundtable WHERE clique = 'stoners' AND id = 2363245 LIMIT 1;"""
      assert.equal topic, expected

