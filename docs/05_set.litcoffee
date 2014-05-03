# /api/Data Structures/Batman.Set

`Set` is an observable, `Batman.Object` wrapper around `SimpleSet`. `Set` also extends [`Batman.Enumerable`](/docs/api/batman.enumerable.html), which provides [many useful methods](/docs/api/batman.enumerable.html).

### SimpleSet vs Set

`SimpleSet` and `Set` are two distinct classes in Batman. `SimpleSet` implements the basic set semantics, but it is *not* a `Batman.Object`, so properties on it (like its `length` or `toArray`) cannot be bound. `Set` is a `Batman.Object`, so it can be observed, and thus plays nicely with the accessor system. Use a `SimpleSet` only when you know nothing will need to be observed on the set you are creating, which usually isn't a valid assumption. If it is in fact valid, consider using a native array as well, as iteration and membership checks will be faster.

## constructor(items...)

When creating a `Set`, items forming the initial set can be passed as separate arguments to the constructor

    test 'new Set constructor can be called without arguments', ->
      set = new Batman.Set
      deepEqual set.toArray(), []

    test 'new Set constructor can be passed items to add to the set.', ->
      set = new Batman.Set(['a', 'b', 'c'])
      deepEqual set.toArray().sort(), ['a', 'b', 'c']

## length : number

A count of the items in a `Set` can be found at its `length` property.

## isEmpty : boolean

Observable property for `isEmpty()`

## toArray : Array

Observable property for `toArray()`. Whenever items are added or removed on the set, the `toArray` property will change. This is the mechanism by which Batman's view bindings get notified of collection updates.

    test 'observers on the toArray property fire when the set changes', ->
      results = null
      set = new Batman.Set(['a', 'b', 'c'])
      set.observe('toArray', (newArray) -> results = newArray.sort())
      deepEqual set.add('d'), ['d']
      deepEqual results, ['a', 'b', 'c', 'd']
      deepEqual set.remove('b'), ['b']
      deepEqual results, ['a', 'c', 'd']

## has(item) : Boolean

`has` returns a boolean describing if the given `item` is a member of the set.

_Note_: Using `has(item)` in an accessor body will register the set `has` is called upon as a source of the property being calculated. This so that whenever the set changes, the property will be recalculated, because the set may now have or not have the item in question.

    test 'Set::has indicates if an item is a member of the set or not.', ->
      set = new Batman.Set(['a', 'b', 'c'])
      ok set.has('a')
      equal set.has('d'), false

    test 'Set::has registers the set as a source of an accessor', ->
      class Team extends Batman.Object
        constructor: ->
          @awards = new Batman.Set()

        @accessor 'bestEver?', -> @get('awards').has('Stanley Cup')

      result = null
      team = new Team
      team.observeAndFire 'bestEver?', (status) -> result = status
      team.get('awards').add 'Eastern Conference Champs'
      equal result, false
      team.get('awards').add 'Stanley Cup'
      equal result, true

## add(items...)

`add` adds 0 or more new items to the set. `add` returns an array of the items which have been newly added to the set, which is to say the intersection of the argument items and the set's complement before addition.

`add` fires the `itemsWereAdded` event with the list of items newly added to the set if that list has length greater than 0. This is to say the event will not be fired if the items passed to add were all already members of the set.

    test 'Set::add adds an item to the set', ->
      set = new Batman.Set()
      equal set.has('a'), false
      deepEqual set.add('a'), ['a']
      equal set.has('a'), true

    test 'Set::add returns only the new items that weren\'t previously in the set', ->
      set = new Batman.Set(['a', 'b'])
      deepEqual set.add('b','c','d').sort(), ['c', 'd']
      deepEqual set.toArray().sort(), ['a', 'b', 'c', 'd']

    test 'Set::add fires the itemsWereAdded event with the items newly added to the set', ->
      results = null
      set = new Batman.Set(['a', 'b'])
      set.on('itemsWereAdded', (item) -> results = item)
      set.add('b','c','d')
      deepEqual results.sort(), ['c','d']

    test 'Set::add does not fire the itemsWereAdded event if the added items were already in the set.', ->
      results = undefined
      set = new Batman.Set(['a', 'b'])
      set.on('itemsWereAdded', (items) -> results = items)
      set.add('a', 'b')
      equal typeof results, 'undefined'

## remove(items...)

`remove` removes 0 or more items from the set. `remove` returns an array of the items which were successfully removed from the set, which is to say the intersection of the argument items and the set itself before removal.

`remove` fires the `itemsWereRemoved` event with the list of removed items if that list has length greater than 0. This is to say the event will not be fired if none of the passed items were members of the set.

    test 'Set::remove removes an item from the set', ->
      set = new Batman.Set(['a'])
      equal set.has('a'), true
      deepEqual set.remove('a'), ['a']
      equal set.has('a'), false

    test 'Set::remove returns only the new items that were previously in the set', ->
      set = new Batman.Set(['a', 'b'])
      deepEqual set.remove('b','c','d').sort(), ['b']
      deepEqual set.toArray(), ['a']

    test 'Set::remove fires the itemsWereRemoved event with the items removed to the set', ->
      results = null
      set = new Batman.Set(['a', 'b', 'c'])
      set.on('itemsWereRemoved', (items) -> results = items)
      set.remove('b','c')
      deepEqual results.sort(), ['b','c']

    test 'Set::remove does not fire the itemsWereRemoved event if the removed items were not already members of the set.', ->
      results = undefined
      set = new Batman.Set(['a', 'b'])
      set.on('itemsWereRemoved', (items) -> results = items)
      set.remove('c', 'd')
      equal typeof results, 'undefined'

## find(testFunction : function) : [Object]

`find` returns the first item within the set for which the `testFunction` called with the item returns `true`, or `undefined` if no item passes the test.

_Note_: `find` returns the first item the test passes for, but since set iteration has no specified order, no guarantee can be made about which item will be returned if more than one item in the set passes the test. However, set iteration order is stable, so `find` called on the same set twice should return the same item.


    test 'Set::find returns the first item for which the test function passes', ->
      set = new Batman.Set([1, 2, 3])
      equal set.find((x) -> x % 2 == 0), 2

    test 'Set::find returns undefined if no items pass the test function', ->
      set = new Batman.Set([1, 2, 3])
      equal typeof set.find((x) -> x > 5), 'undefined'

## forEach(iteratorFunction : function[, context: Object])

`forEach` calls the `iteratorFunction` with each item in the set, optionally executing the `iteratorFunction` in the passed context. Returns `undefined`.

_Note_: Set iteration order is not defined, thus Set client code cannot rely on one item being iterated over before another, regardless of when the Set's items were added. If you need an ordered set, Batman provides `SetSort` for exactly this, while including the added benefit of observability. If you need a one time ordering of a set, you can get the array representation with `toArray` and then use vanilla JavaScript `sort` on that array.

_Note_: Using `forEach()` in an accessor body will register the set iterated over as a source of the property being calculated. This so that whenever the set changes, the property will be recalculated. This can become an issue if you iterate over a set and modify the set's items, as when the property recalculates that modification will potentially happen on items it's happened on previously.

    test 'Set::forEach iterates over each item in the set', ->
      sum = 0
      set = new Batman.Set([1,2,3])
      set.forEach (x) -> sum += x
      equal sum, 6

    test 'Set::forEach iterates over each item in the set optionally in the provided context', ->
      context = {sum: 0}
      set = new Batman.Set([1,2,3])
      set.forEach((x) ->
        @sum += x
      , context)
      equal context.sum, 6

    test 'Set::forEach registers the set as a source if called in an accessor body', ->
      class Team extends Batman.Object
        constructor: ->
          @players = new Batman.Set()
        @accessor 'willWinTheCup?', ->
          sedinCount = 0
          @players.forEach (player) ->
            sedinCount++ if player.split(' ')[1] == 'Sedin'
          sedinCount >= 2

      result = null
      team = new Team()
      team.observeAndFire 'willWinTheCup?', (status) -> result = status
      equal team.get('willWinTheCup?'), false
      team.get('players').add 'Henrik Sedin'
      equal result, false
      team.get('players').add 'Daniel Sedin'
      equal result, true

## isEmpty() : boolean

`isEmpty` returns a boolean: `true` if the set has no items, and `false` if it has any items.

_Note_: Using `isEmpty()` in an accessor body will register the set `isEmpty` is called on as a source of the property being calculated, so that whenever the set changes the property will be recalculated.

    test 'Set::isEmpty returns true if the set has no items', ->
      set = new Batman.Set()
      ok set.isEmpty()
      set.add('a')
      equal set.isEmpty(), false

    test 'Set::isEmpty registers the set as a source of an accessor', ->
      class Team extends Batman.Object
        constructor: ->
          @games = new Batman.Set()
        @accessor 'seasonStarted?', -> !@games.isEmpty()

      team = new Team
      equal team.get('seasonStarted?'), false
      team.get('games').add({win: true})
      equal team.get('seasonStarted?'), true

## clear() : Array

`clear` removes all items from a set. Returns an array of all the items in the set.

`clear` will fire the `itemsWereRemoved` event once with all the items in the set.

_Note_: Set iteration order is not defined, so the order of the array of items returned by `clear` is undefined.

    test 'Set::clear empties the set', ->
      set = new Batman.Set(['a', 'b', 'c'])
      equal set.isEmpty(), false
      deepEqual set.clear().sort(), ['a', 'b', 'c']
      ok set.isEmpty()

    test 'Set::clear fires the itemsWereRemoved event with all the items in the set', ->
      result = null
      set = new Batman.Set(['a', 'b', 'c'])
      set.on('itemsWereRemoved', (items) -> result = items)
      set.clear()
      deepEqual result.sort(), ['a', 'b', 'c']

## replace(collection : Enumerable) : Array

`replace` removes all the items in a set and then adds all the items found in another `collection`. The other collection must have a `toArray` function which returns an array representation of the collection. Returns the array of items added.

`replace` will fire the `itemsWereRemoved` event once with all the items in the set, and then the `itemsWereAdded` event once with the items from the incoming collection.

    test 'Set::replace empties the set and then adds items from a different collection', ->
      set = new Batman.Set(['a', 'b', 'c'])
      secondSet = new Batman.Set(['d', 'e', 'f'])
      set.replace(secondSet)
      deepEqual set.toArray().sort(), ['d', 'e', 'f']

    test 'Set::replace fires the itemsWereRemoved event with all the items in the set', ->
      result = null
      set = new Batman.Set(['a', 'b', 'c'])
      set.on('itemsWereRemoved', (items) -> result = items)
      set.replace(new Batman.SimpleSet())
      deepEqual result.sort(), ['a', 'b', 'c']

    test 'Set::replace fires the itemsWereAdded event with all the items in the incoming set', ->
      result = null
      set = new Batman.Set()
      set.on('itemsWereAdded', (items) -> result = items)
      set.replace(new Batman.SimpleSet(['a', 'b', 'c']))
      deepEqual result.sort(), ['a', 'b', 'c']

## toArray() : Array

`toArray` returns an array representation of the set.

_Note_: Set iteration order is not defined, so the order in which the set's items appear in the array is not defined. It is however stable, so the order of the items in two successive `toArray` calls where the set was not modified in between should be the same.

_Note_: `toArray` is also an observable property.

_Note_: Using `toArray()` in an accessor body will register the set `toArray` is called on as a source of the property being calculated, so that whenever the set changes the property will be recalculated.

    test 'Set::toArray returns an array representation of the set', ->
      set = new Batman.Set()
      deepEqual set.toArray(), []
      set.add('a', 'b', 'c')
      deepEqual set.toArray().sort(), ['a', 'b', 'c']

## merge(collections... : Enumerable) : Set

`merge` adds all the items in a set and all the items in the passed `collections` to a new set and returns it. A `collection` is an object which has a `forEach` function. `merge` is a non-destructive collection union, so the set `merge` is called on and each `collection` passed to `merge` are unaffected by the call.

_Note_: Be careful about using `merge` within accessors. Calling `merge` in an accessor function body will register the set `merge` is called upon as a source of the property being calculated, which means when the set changes, that accessor will be recalculated. This means the O(n * m) merge will occur again each time, and return an entirely new `Set` instance. If the previously returned `Set` instance is retained after recalculation, this is a big memory leak. Instead of merging in accessors, try to use a `SetUnion` or a `SetIntersection`.

    test 'Set::merge returns a new set with the items of the original set and the passed set', ->
      abc = new Batman.Set(['a', 'b', 'c'])
      def = new Batman.Set(['d', 'e', 'f'])
      equal Batman.typeOf(set = abc.merge(def)), 'Object'
      deepEqual set.toArray().sort(), ['a', 'b', 'c', 'd', 'e', 'f']

## indexedBy(key : String) : SetIndex

`indexedBy` returns a hash of sets which buckets all the items in the callee set by the value of a particular `key`. The value of the passed `key` is `get`ted from each object in the set, and then a hash of each value to a set of the items with that value at the `key` is built. This hash of sets is a smart object called a `SetIndex` which will continue to observe the set and the value of the `key` on each item in the set to ensure the set index remains up to date. `SetIndex` also has a friend named `UniqueSetIndex` which will give you a hash of items instead of a hash of sets with items for easy access if you know each item's value at the `key` is unique.

    test 'Set::indexedBy returns a new SetIndex with the items bucketed by the value of the key', ->
      set = new Batman.Set([Batman(colour: 'blue'), Batman(colour: 'green'), Batman(colour: 'blue')])
      index = set.indexedBy('colour')
      ok index.get('blue') instanceof Batman.Set
      equal index.get('blue').get('length'), 2
      equal index.get('green').get('length'), 1

    test 'Set::indexedBy returns a new SetIndex which observes the set for new additions and stays up to date', ->
      set = new Batman.Set([Batman(colour: 'blue'), Batman(colour: 'green')])
      index = set.indexedBy('colour')
      equal index.get('blue').get('length'), 1
      newItem = Batman(colour: 'blue')
      set.add(newItem)
      equal index.get('blue').get('length'), 2
      ok index.get('blue').has(newItem)
      set.remove(newItem)
      equal index.get('blue').get('length'), 1

    test 'Set::indexedBy returns a new SetIndex which observes the items in the set for changes to the observed key', ->
      itemA = Batman(colour: 'blue')
      itemB = Batman(colour: 'green')
      set = new Batman.Set([itemA, itemB])
      index = set.indexedBy('colour')
      equal index.get('blue').get('length'), 1
      equal index.get('green').get('length'), 1
      itemA.set('colour', 'green')
      equal index.get('blue').get('length'), 0
      equal index.get('green').get('length'), 2

`SetIndex`es can be created by calling the `indexedBy` function on the `Set`, as well as by `get`ting a `key` on the `indexedBy` property.

    test "Set::get('indexedBy.someKey') returns a new SetIndex for 'someKey'", ->
      set = new Batman.Set([Batman(colour: 'blue'), Batman(colour: 'green')])
      index = set.get('indexedBy.colour')
      equal index.get('blue').get('length'), 1

## indexedByUnique(key : String) : UniqueSetIndex

`indexedByUnique` returns a hash of items keyed by the value of the given `key` on each item from the callee set. The value of the passed `key` is `get`ted from each object in the set, and then a hash of each value to an item with that value at the `key` is built. This hash of items is a smart object called a `UniqueSetIndex` which will continue to observe the set and the value of the `key` on each item in the set to ensure the index remains up to date. Note that the semantics for which item ends up in the hash if two items have the same value for the `key` are undefined, so it is wise to only use `UniqueSetIndex`es on keys who's values are going to be unique in the set. If the values are not going to be unique, you may be interested in `SetIndex` and `Set::indexedBy`.

    test 'Set::indexedByUnique returns a new UniqueSetIndex with the items hashed by the value of the key', ->
      greenItem = Batman(colour: 'green')
      blueItem = Batman(colour: 'blue')
      set = new Batman.Set([greenItem, blueItem])
      index = set.indexedByUnique('colour')
      ok blueItem == index.get('blue')
      ok greenItem == index.get('green')
      equal undefined, index.get('red')

    test 'Set::indexedByUnique returns a new UniqueSetIndex which observes the set for new additions and stays up to date', ->
      set = new Batman.Set([Batman(colour: 'blue'), Batman(colour: 'green')])
      index = set.indexedByUnique('colour')
      newItem = Batman(colour: 'red')
      set.add(newItem)
      ok newItem == index.get('red')
      set.remove(newItem)
      equal undefined, index.get('red')

    test 'Set::indexedByUnique returns a new UniqueSetIndex which observes the items in the set for changes to the observed key', ->
      itemA = Batman(colour: 'blue')
      itemB = Batman(colour: 'green')
      set = new Batman.Set([itemA, itemB])
      index = set.indexedByUnique('colour')
      equal index.get('blue')?, true
      equal index.get('green')?, true
      equal index.get('red')?, false
      itemA.set('colour', 'red')
      equal index.get('blue')?, false
      equal index.get('green')?, true
      equal index.get('red')?, true

`UniqueSetIndex`es can be created by calling the `indexedByUnique` function on the `Set`, as well as by `get`ting a `key` on the `indexedByUnique` property.

    test "Set::get('indexedByUnique.someKey') returns a new UniqueSetIndex for 'someKey'", ->
      set = new Batman.Set([Batman(colour: 'blue'), Batman(colour: 'green')])
      index = set.get('indexedByUnique.colour')
      equal 'blue', index.get('blue').get('colour')

## sortedBy(key: String [, order: String]) : SetSort

`sortedBy` returns a `Set` like object containing all the items of the callee set but with a defined iteration order (unlike `Set`). The iteration order is defined as the alpha numeric sorting of the values of the passed `key` gotten from each item. The direction of the sort can be controlled with the `order` argument, which defaults to `asc` (short for ascending) or can be passed as `desc` (short for descending). This `Set` like object is a `SetSort` which encapsulates the logic to get the values from each item at the passed `key` and traverse the `Set` in the values sorted order.

`SetSort`s are useful for getting a transform of a `Set` which sorted, but also because the sort stays up to date as items are added or removed to the sorted set, or the value at the `key` changes on any of the items in the set.

    test 'Set::sortedBy returns a new SetSort who can be iterated in the sorted order of the value of the key on each item', ->
      set = new Batman.Set([Batman(place: 3, name: 'Harry'), Batman(place: 1, name: 'Tom'), Batman(place: 2, name: 'Camilo')])
      sort = set.sortedBy('place')
      deepEqual sort.toArray().map((item) -> item.get('name')), ['Tom', 'Camilo', 'Harry']

    test 'Set::sortedBy returns a new SetSort which observes the callee set for additions or removals and puts new items in the sorted order', ->
      set = new Batman.Set([Batman(place: 3, name: 'Harry'), Batman(place: 1, name: 'Tom'), Batman(place: 2, name: 'Camilo')])
      sort = set.sortedBy('place')
      deepEqual sort.toArray().map((item) -> item.get('name')), ['Tom', 'Camilo', 'Harry']
      burke = Batman(place: 1.5, name: 'Burke')
      set.add(burke)
      deepEqual sort.toArray().map((item) -> item.get('name')), ['Tom', 'Burke', 'Camilo', 'Harry']

    test 'Set::sortedBy returns a new SetSort which observes each item in the callee set for changes to the sort key', ->
      harry = Batman(place: 2, name: 'Harry')
      tom = Batman(place: 1, name: 'Tom')
      set = new Batman.Set([harry, tom])
      sort = set.sortedBy('place')
      deepEqual sort.toArray().map((item) -> item.get('name')), ['Tom', 'Harry']
      tom.set('place', 3)
      deepEqual sort.toArray().map((item) -> item.get('name')), ['Harry', 'Tom']

`SetSort`s can be created by calling the `sortedBy` function on the `Set`, as well as by `get`ting a `key` on the `sortedBy` property. Note that with this instantiation form you can't pass an order to the `SetSort`.

    test "Set::get('sortedBy.someKey') returns a new SetSort onn 'someKey'", ->
      set = new Batman.Set([Batman(place: 3, name: 'Harry'), Batman(place: 1, name: 'Tom'), Batman(place: 2, name: 'Camilo')])
      sort = set.get('sortedBy.place')
      equal 'Harry', sort.get('toArray')[2].get('name')
