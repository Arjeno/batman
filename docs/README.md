# batman.js API Documentation

The API documentation is the primary reference for batman.js. It contains a
listing and description of public functionality, along with tests to serve as
usage examples.

These files are processed by a [script](https://github.com/batmanjs/batmanjs.github.io/blob/master/bin/generate_docs) in the batmanjs.github.io repository.

The current version is readable [here](http://batmanjs.org/docs/api/).

You can contribute by improving existing entries or adding new entries!

## Modifying a File

To edit an existing entry, find the the first-level heading for the class you want to modify. For example, if you want to modify the `Batman.AbstractBinding` docs, you would search for:

```
# /api/App Internals/Batman.AbstractBinding
```

Then, you can find a specific function by looking for a second-level heading under that:

```
## ::%filteredValue
```

Then, you can modify the description for that function!

## Adding a File

If you want to document a new class, you can add a file for it. Here are some considerations:

- First-level headings define where the page will be on the website. They should take the form:

  ```
  # /api/{Grouping Name}/{Class Name}/{Optional: Subclass Name}
  ```

  If `Subclass Name` is provided, that will be treated as the class name and `Class Name` will be treated as a "parent folder".

  For example,

  ```
  # /api/App Components/Batman.View/Batman.View Filters
  ```

  Will create a `batman.view_filters.html` page which is nested under App Components > Batman.View.

- Filenames have leading digits to ensure that they're parsed in the right order. Make sure your file comes after the existing files (unless it belongs somewhere higher).

## Automatic Links

Markdown like ``Batman.SomeClass`` will automatically be converted to a link to the API page for `Batman.SomeClass` if the page exists.

## Function Heading Format

Second-level headings (i.e. `##` in markdown) must follow a certain format to
allow for parsing metadata. If the heading is intended to document a function,
property, or accessor, it should follow this specification:

```
## XYname(args)[= default] : Type
```

- `X` is `@` for a class-level member, and `::` for a prototype-level member
- `Y` is `.` for a property, `%` for a batman accessor, and empty for a function
- `name` is the name of the member
- `(args)` is used for functions only, and is a comma separated list of arguments
  - e.g. `## ::remove(index, offset)`
- `[= default]` is optional, and documents the default value of a property
  - e.g. `## ::.disabled[= false]`
- ` : Type` is optional, and documents the return type if a function/accessor, or the type if a property
  - e.g. `## ::add(x) : number`


For documenting method signatures, follow these guidelines:

- Add the expected type of arguments separated by a colon if they're not obvious
  - e.g. `## @filter(filter : String)`
  - e.g. `## ::filter(filter : [String|Function|RegExp])`
- When documenting multiple accepted signatures, use the square-brackety way:
  - e.g. `## ::forEach(iterator : Function[, context: Object])`
  - e.g. `## @encode(keys...[, encoder : [Object|Function]])`
  - e.g. `## @beforeAction([options : [string|Object], ]filter : [string|Function])`
  - If the signatures are different enough, use a third level heading (###) within the description, with a bit more description of why it exists


Example:

```coffee
class X extends Batman.Object
  @someClassProperty: false

  @classAccessor 'classAccess', -> @someClassProperty
  @accessor 'instanceAccess', -> @someInstanceString

  method: (a, b) ->
    @someInstanceString = a
    @someInstanceFunction = b if b?
    @someInstanceBoolean

```

```markdown
# X

## Regular second-level headings are still OK

## @.someClassProperty : Boolean
You'll set this in the class declaration and access it by `X.someProperty`.

## @%classAccess : Boolean
This is a class accessor. It will be defined in the class declaration and accessed by `X.get("classAccess")`.

## ::%instanceAccess : String
This is also defined in the class declaration, but will be accessed from an instance of the class, like:

   instance = new X
   instance.get('instanceAccess')

## ::method(a : String[, b : Function]) : Boolean
This is an instance method. It's defined in the class declaration and called on the instance directly, like:

   instance = new X
   instance.method "some string", (arg) ->
   console.log("instance method was called!", arg)

```

If you're (rightfully) confused, look to the existing API docs for further examples.

The parsing code is [here](https://github.com/batmanjs/batmanjs.github.io/blob/master/bin/generate_docs) if you'd like to take a look.

