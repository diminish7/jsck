module.exports =

  # handlers

  maxItems: (value, context) ->
    self = @
    (data, runtime) ->
      if self.test_type "array", data
        if data.length > value
          runtime.error context, data

  minItems: (value, context) ->
    self = @
    (data, runtime) ->
      if self.test_type "array", data
        if data.length < value
          runtime.error context, data

  items: (definition, context) ->
    self = @
    if self.test_type "array", definition
      test = self._tuple_items definition, context
    else if self.test_type "object", definition
      test = self.compile(context, definition)
      # TODO check for array data?
      (data, runtime) ->
        for item, i in data
          test item, runtime.child(i)
        null
    else
      throw new Error "The 'items' attribute must be an object or an array"

  _additionalItems: (definition, context) ->
    self = @
    if self.test_type "object", definition
      test = self.compile(context, definition)
    else if definition == false
      test = (data, runtime) ->
        runtime.error context, data
    else if definition == true
      # valid
    else
      throw new Error "The 'additionalItems' attribute must be an object or false"
    (data, runtime) ->
      for item, i in data
        test item, runtime.child(i)
      null

  _tuple_items: (definition, context) ->
    self = @
    {additionalItems} = context.modifiers

    if additionalItems?
      add_item_test = self._additionalItems additionalItems,
        context.sibling "additionalItems"
    else
      add_item_test = null

    tests = []
    for schema, i in definition
      unless self.test_type "object", schema
        throw new Error "The 'items' attribute must be an object or an array"

      tests.push self.compile context.child(i), schema

    (data, runtime) ->
      if self.test_type "array", data
        for test, i in tests
          test data[i], runtime.child(i)

        if (data.length > tests.length) && add_item_test
          add_item_test data.slice(tests.length), runtime

  uniqueItems: (definition, context) ->
    console.error "uniqueItems is a no-op"
    null
