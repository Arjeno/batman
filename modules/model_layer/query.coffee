{BatmanObject} = require 'foundation'

module.exports = class Query extends BatmanObject
  @OPTION_KEYS = ['limit', 'offset', 'order', 'where', 'distinct', 'action', 'uniq']
  @METHODS = @OPTION_KEYS.concat(['only', 'except'])

  @Queryable =
    initialize: ->
      for name in Query.OPTION_KEYS
        do (name) =>
          @[name] = ->
            query = new Query(this)
            query["_#{name}"].apply(query, arguments)

  constructor: (@base, options = {}) ->
    options.where ||= {}
    @set('options', new Batman.Object(options))
    @set('params', @toParams())

  duplicate: (block) ->
    options = Batman.mixin({}, @get('options').toJSON())
    query = new @constructor(@base, options)
    block.call(query)

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

  only: (onlyOptions...) ->
    for option in @constructor.OPTION_KEYS
      if onlyOptions.indexOf(option) == -1
        @unset("options.#{option}")

    return this

  except: (exceptOptions...) ->
    for option in exceptOptions
      @unset("options.#{option}")

    return this

  action: (action) ->
    @set('options.action', action)
    return this

  for name in @METHODS
    alias = "_#{name}"
    @::[alias] = @::[name]

    do (name) =>
      @::[name] = ->
        args = arguments

        @duplicate ->
          @["_#{name}"].apply(@, args)

  load: (callback) ->
    @base.search(this, callback)

  toJSON: -> @options.toJSON()

  toParams: ->
    params = @toJSON()
    params = Batman.mixin(params, params.where)

    for type in ['where', 'action']
      delete(params[type])

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
