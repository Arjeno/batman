#= require ../object

class Batman.Query extends Batman.Object
  @OPTION_KEYS = ['limit', 'offset', 'order', 'where', 'distinct']

  constructor: (@base, options = {}) ->
    options.where ||= {}
    @set('options', new Batman.Object(options))
    @set('params', @toJSON())

  where: (key, value) ->
    constraints = @_singleOrMultipleConstraints(key, value)

    @set('options.where', Batman.mixin({}, @get('options.where'), constraints))
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

  only: (onlyOptions...) ->
    options = @get('options')

    for option in @constructor.OPTION_KEYS
      if onlyOptions.indexOf(option) == -1
        @unset("options.#{option}")

    return this

  except: (exceptOptions...) ->
    options = @get('options')

    for option in exceptOptions
      @unset("options.#{option}")

    return this

  toJSON: -> @options.toJSON()

  toParams: ->
    params = @toJSON()

    for type in ['where']
      data = params[type]
      delete(params[type])

      params = Batman.mixin(params, data)

    params

  for option in @OPTION_KEYS
    @::observe "options.#{option}", ->
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
