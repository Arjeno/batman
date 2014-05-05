#= require ../object

class Batman.Query extends Batman.Object
  @OPTION_KEYS = ['limit', 'offset', 'order', 'where', 'distinct', 'not']

  constructor: (@base, options = {}) ->
    options.where ||= {}
    @set('options', new Batman.Object(options))
    @set('params', @toJSON())

  where: (key, value) ->
    constraints = @_singleOrMultipleConstraints(key, value)

    @set('options.where', Batman.mixin({}, @get('options.where'), constraints))
    return this

  not: (key, value) ->
    constraints = @_singleOrMultipleConstraints(key, value)

    for key, value of constraints
      constraints[key] = "!#{value}"

    @set('options.not', Batman.mixin({}, @get('options.not'), constraints))
    return this

  uniq: ->
    return @limit(1)

  limit: (amount) ->
    @set('options.limit', amount)
    return this

  offset: (amount) ->
    @set('options.offset', amount)
    return this

  order: (order) ->
    @set('options.order', order)
    return this

  distinct: ->
    @set('options.distinct', true)
    return this

  load: (callback) ->
    @base.search(this, callback)

  toJSON: -> @options.toJSON()

  toParams: ->
    params = @toJSON()

    for type in ['where', 'not']
      data = params[type]
      delete(params[type])

      params = Batman.mixin(params, data)

    params

  for name in @OPTION_KEYS
    @::observe "options.#{name}", ->
      @set('params', @toParams())

  _singleOrMultipleConstraints: (key, value) ->
    constraints = {}

    if Batman.typeOf(key) == 'String'
      constraints[key] = value
    else
      constraints = key

    constraints

Batman.Queryable =
  initialize: ->
    for name in Batman.Query.OPTION_KEYS
      do (name) =>
        @[name] = ->
          query = new Batman.Query(this)
          query[name].apply(query, arguments)
          return query

Batman.QueryAccess =
  initialize: ->
    for name in Batman.Query.OPTION_KEYS
      do (name) =>
        @[name] = ->
          query = @get('query')
          query[name].apply(query, arguments)
          return this
