#= require_tree ../hash

class Batman.Params extends Batman.Hash
  constructor: (@hash, @navigator) ->
    super

  updateUrl: (soft = true) ->
    if soft
      @navigator.softRedirect(@toObject())
    else
      @navigator.redirect(@toObject())
