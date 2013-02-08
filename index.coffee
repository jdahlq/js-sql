###
# New record
new sql.Query
  .insertInto(@tableName)
  .values(@serialize)


# Fetch record
new sql.Query
  .select('*')
  .from(@tableName)
  .where
    group: @group
    name: @name

# Update record
new sql.Query
  .update(@tableName)
  .set(@serialize)

# List puzzles
new sql.Query
  .select(
    'name'
    'author'
    'dateCreated'
  )
  .from(@tableName)
  .where
    group: 'mesii'
    dateCreated:
      '>': startDate
      '<': endDate
    sql.or
      status: 'unsolved'
      mode: 'timeless'
  .orderBy(
    sql.desc('dateCreated')
    'name'
  )
  .limit(50)
###

# Match chars that should be followed by an underscore
CAMEL_TO_UNDERSCORE_REGEX = ///
  (
      [^A-Z0-9]               # Match lowercase/non-num...
      (?=[A-Z0-9])            # ... only if it is followed by uppercase/num
    |                       # OR
      [A-Z0-9]                # Match uppercase/num...
      (?=[A-Z0-9][^A-Z0-9])   # ... only if it is followed by uppercase/num then lowercase/non-num
  )
///g

class exports.Query

  constructor: ->
    @clauses = []

  toString: ->
    @clauses.join(' ') + ';'

  from: (table) ->
    console.fail 'table undefined in "from" func' unless table?
    console.fail '"from" func received non-string arg, not yet implemented' if typeof table != 'string'
    @addClause "FROM #{table}"

  insertInto: (table) ->
    console.fail 'table undefined in "insertInto" func' unless table?
    console.fail '"into" func received non-string arg, not yet implemented' if typeof table != 'string'
    @addClause "INSERT INTO #{table}"

  limit: (num) ->
    console.fail 'requires a number' unless typeof num == 'number'
    @addClause "LIMIT #{num}"

  select: (fields...) ->
    console.fail 'select func received no args' if fields.length == 0
    @addClause "SELECT #{fields.join(', ')}"

  selectAll: () ->
    @addClause "SELECT *"

  set: (hash) ->
    console.fail 'values func received no args' unless hash?
    sets = ("#{@camelCaseToUnderscore key} = #{@wrap val}" for key, val of hash)
    @addClause "SET " + sets.join(', ')


  values: (hash) ->
    console.fail 'values func received no args' unless hash?
    keys = []
    vals = []
    for key, val of hash
      keys.push @camelCaseToUnderscore key
      vals.push @wrap val

    @addClause "(#{keys.join(', ')}) VALUES (#{vals.join(', ')})"

  update: (table) ->
    console.fail 'table undefined in "update" func' unless table?
    console.fail '"update" func received non-string arg' if typeof table != 'string'
    @addClause "UPDATE #{table}"


  where: (conditions...) ->
    @addClause "WHERE #{@and conditions}"

  returning: (fields...) ->
    console.fail '#returning func received no args' if fields.length == 0
    @addClause "RETURNING #{fields.join(', ')}"

  and: (conditions...) ->
    (@parseConditions conditions).join(' AND ')


  # UTILITY

  parseConditions: (conditionSoup) ->
    conditions = []
    for condition in conditionSoup
      if typeof condition is 'string'
        conditions.push condition
      else if condition instanceof Array
        conditions.push (@parseConditions condition)...
      else
        for key, val of condition
          conditions.push @formatKeyValOp key, val

    conditions

  addClause: (clause) ->
    @clauses.push clause
    @

  formatKeyValOp: (key, val, op='=') ->
    "#{@camelCaseToUnderscore key} #{op} #{@wrap val}"

  wrap: (val) ->
    if !val?
      'DEFAULT'
    else if typeof val is 'number'
      val
    else if val instanceof Array
      @wrapArray val
    else if typeof val is 'string'
      "'#{val}'"
    else if val.constructor.name == 'Buffer'
      hexString = val.toString 'hex'
      "decode('#{hexString}','hex')"
    else
      @wrapObject val

  camelCaseToUnderscore: (val) ->
    val.replace(CAMEL_TO_UNDERSCORE_REGEX, (m) -> "#{m}_").toLowerCase()

  wrapArray: (arr) ->
    elements = for element in arr
      if typeof element is 'number'
        element
      else if typeof element is 'string'
        "'#{element}'"
      else
        @wrapObject element

    "ARRAY[#{elements.join(', ')}]"

  wrapObject: (obj) ->
    "json'#{JSON.stringify obj}'"