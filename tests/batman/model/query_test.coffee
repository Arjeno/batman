QUnit.module "Batman.Query",
  setup: ->
    @query = new Batman.Query(Batman.Model)

test "All option methods return a query object for chaining", ->
  for option in Batman.Query.METHODS
    ok @query[option]() instanceof Batman.Query

test "Query::where can be called with an object or key and value", ->
  query = @query.where(foo: 'bar')
  equal query.get('options.where.foo'), 'bar'

  query = @query.where('foo', 'baz')
  equal query.get('options.where.foo'), 'baz'

test "Query::where mixes in constraints to the existing list", ->
  query = @query.where(foo: 'bar')
                .where(bar: 'foo')
                .where(a: 1, b: 2, foo: 'baz')

  equal query.get('options.where.a'), 1
  equal query.get('options.where.foo'), 'baz'

test "Mixing in Queryable defines methods which return new Queries", ->
  class Test extends Batman.Object
    @classMixin Batman.Queryable

  ok Test.limit(5) instanceof Batman.Query

test "Query::toParams returns an Object with nested where", ->
  query = @query.where(foo: 'bar')
                .where(a: 1, b: 2)
                .limit(10)

  params = query.toParams()
  equal params.foo, 'bar'
  equal params.a, 1
  equal params.b, 2
  equal params.limit, 10

test "Query::only deletes other option keys", ->
  query = @query.where(foo: 'bar').limit(10)
  query = query.only('limit')

  equal query.get('options.where'), undefined
  equal query.get('options.limit'), 10

test "Query::except deletes given option keys", ->
  query = @query.where(foo: 'bar').limit(10)
  query = query.except('where')

  equal query.get('options.where'), undefined
  equal query.get('options.limit'), 10

test "Chaining methods does not overwrite the previous options", ->
  query1 = @query.where(foo: 'bar')
  query2 = query1.where(bar: 'foo')

  deepEqual query1.toParams(), { foo: 'bar' }
  deepEqual query2.toParams(), { foo: 'bar', bar: 'foo' }

test "All methods should return a different query object", ->
  set = new Batman.Set

  for option in Batman.Query.METHODS
    set.add @query[option]().hashKey()

  equal set.length, Batman.Query.METHODS.length
