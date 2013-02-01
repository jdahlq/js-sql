'use strict'
reporter = require '../node_modules/vows/lib/vows/reporters/spec.js'
vows = require 'vows'
assert = require 'assert'

suites = [
  './tests'
]

for suiteAddress in suites
  suite = require suiteAddress
  if suite.tests?
    suite.tests(vows.describe(suite.name), assert).run reporter: reporter
  else
    suite.run reporter: reporter
