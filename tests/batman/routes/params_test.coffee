QUnit.module "Batman.Params",
  setup: ->
    @navigator =
      redirect: createSpy()
      softRedirect: createSpy()
    @params = new Batman.Params({
      foo: 'fooVal'
      bar: 'barVal'
      }, @navigator)

test "updateUrl() calls navigator softRedirect()", ->
  @params.updateUrl()

  equal @navigator.softRedirect.callCount, 1
  deepEqual @navigator.softRedirect.lastCallArguments, [@params.toObject()]

test "updateUrl() calls navigator redirect()", ->
  @params.updateUrl(false)

  equal @navigator.redirect.callCount, 1
  deepEqual @navigator.redirect.lastCallArguments, [@params.toObject()]
