###
Author: PikachuEXE (Leung Ho Kuen)
Plugin name: Pika Tag
Purpose: Support Tag with preview & autocomplete & loading by AJAX (as a custom function)

Requirement:
1. jQuery 1.6+, since prop() is used
###

# Hidden variables

$.pikatag ||= {}

$.pikatag.KEYS ||= {
  UP: 38
  DOWN: 40
  DEL: 46
  TAB: 9
  ENTER: 13
  ESC: 27
  COMMA: 188
  PAGEUP: 33
  PAGEDOWN: 34
  BACKSPACE: 8
}

$.pikatag.CLASS_NAMES =
  masterContainer: 'pikatag-master-container'
  tagContainer: 'pikatag-tags-container'
  fakeInputWrapper: 'pikatag-input-wrapper'
  fakeInput: 'pikatag-fake-input'
  fakeInputWithoutBorder: 'pikatag-fake-input--without-border'
  fakeInputInvalid: 'pikatag-fake-input--invalid'
  tag: 'pikatag-tag'
  tagText: 'pikatag-tag-text'
  removeTagButton: 'pikatag-btn-remove-tag'
  autoCompleteResult: 'pikatag-autocomplete-result'
  autoCompleteResultItemSelected: 'pikatag-ac-item--selected'

$.pikatag.DATA_KEY_NAMES =
  realInput: 'pikatag-real-input'
  masterContainer: 'pikatag-master-container'
  tagContainer: 'pikatag-tags-container'
  fakeInputWrapper: 'pikatag-fake-input-wrapper'
  fakeInput: 'pikatag-fake-input'
  autoCompleteResultContainer: 'pikatag-autocomplete-result-container'
  autoCompleterefreshIntervalID: 'pikatag-ac-refresh-interval-id'
  settings: 'pikatag-settings'


$.pikatag.defaults ||=
  ###
  Global default options
  ###

  # Behaviour
  delimiter: ',' # Well you can use a space, used on tag import
  generateInput: true # Well if false that means you want to add tag by code or from other input
  customFakeInput: null # ID of the fake input if you don't want to use generated input, only effective when generateInput == false
  unique: true # if false it will give you duplicated tags
  flashOnDuplicate: true # If true will add invalid class on input and hence red background to indicate error
  minChars: 1
  maxChars: 0 # 0 means unlimited
  maxTags: 0 # Sometimes you might want to limit number of tags you want to add, 0 means unlimited

  # Appearance
  placeholder: null # Oh it will be just placeholder attribute
  # The ID of container to appendTo
  # if null, will put inside a master container inserted after the real input
  tagContainer: null

  # Key strokes
  removeWithBackspace: true # Set it to false if you want to avoid accident
  preventSubmitOnEnter: true # It should be true most of the time

  # autocomplete
  autocomplete:
    # Array or function that returns an array, null means you don't want autocomplete
    # if it's an function, I assmue you have filtered already (assumed to use AJAX) , filter_func will not be called, "this" will be query string
    # if it's an array, filter_func will be called, you can also set custom filter_func
    source: null
    refreshInterval: 500 # in ms, too short is not good
    # This is only used if source is a static array of string
    # If source is a function, this won't be called
    #
    # Cannot be null
    #
    # this = tag item (since func.call overwrite "this")
    # params:
    # query_string: well the user input, just create an simple regexp to test it, see Regexp.test
    #
    # return true or false on whether "this" should be add to result
    filter_func: (query_string) ->
      new RegExp(".*#{query_string}.*").test(this) # default just test the item (assume to be string)
    # This is the function called for autocomplete dropdown
    #
    # Cannot be null
    #
    # default: treat & render the source like ["default","list"]
    # this = "tag item"
    # you will have to set data('value') on $('li'), since it will be used for adding tag
    render_func: ->
      list_item = document.createElement('li')
      $list_item = $(list_item)

      # Set the structure of list item
      $list_item.text(this) # assume source item is string already

      # Set the text value to insert when this item is selected
      $list_item.data('value', this)

      list_item # reutrn the dom/jQuery object for append

  # debug
  # will show the real input and also log some error message in console
  debug: false

$.fn.pikatag = (options = {}) ->
  # Need deep merge!!!
  all_options = $.extend(true, {}, $.pikatag.defaults, options)

  @each ->
    $this = $(this)
    # this should be DOM object of input
    $this.hide() unless all_options.debug

    # generate an id if there is none
    unless $this.prop('id')?
      # ID for generating more IDs
      # write it and read it :o)
      id = $this.prop({
        id: "pikatag-#{new Date().getTime()}"
      }).prop("id")

    # to show that it's processed
    $this.addClass('js')

    # now data got all thing thing we need, I think
    data = all_options


    ## Generate markup
    $holder = $(document.createElement('div')).
      prop({
        class: $.pikatag.CLASS_NAMES.masterContainer
      })

    $tags_container = $(document.createElement('div')).prop({
      class: $.pikatag.CLASS_NAMES.tagContainer
    })
    if data.tagContainer?
      $tags_container.appendTo(data.tagContainer)
    else
      $tags_container.appendTo($holder)

    $input_wrapper = $(document.createElement('div')).prop({
      class: $.pikatag.CLASS_NAMES.fakeInputWrapper
    }).appendTo($holder)


    # generate one if they want, or just grab the custom fake input by ID
    $fake_input = []
    if data.generateInput
      $fake_input = $(document.createElement('input'))
        .prop({
          placeholder: data.placeholder || $this.attr('placeholder')
          autocomplete: "off"
        })
        .addClass($.pikatag.CLASS_NAMES.fakeInput)
        .addClass($.pikatag.CLASS_NAMES.fakeInputWithoutBorder)#TODO: make without border an option

      $fake_input.appendTo($input_wrapper)

      ## Events registering
      # Click on holder = focus on fake input
      $holder.click (event) ->
        realInput = $(this).data($.pikatag.DATA_KEY_NAMES.realInput)
        $realInput = $(realInput)
        fakeInput = $realInput.data($.pikatag.DATA_KEY_NAMES.fakeInput)

        $(fakeInput).focus

    else if data.customFakeInput?
      $fake_input = $(data.customFakeInput)
        .prop({
          # no class, let user do custom styling
          placeholder: data.placeholder || $this.attr('placeholder') # Still use the placeholder from the real input
          autocomplete: "off" # In case they forgot to set
        })
        .addClass($.pikatag.CLASS_NAMES.fakeInput)


    $holder.insertAfter(this) # insert the new markup after the real input

    $ac_result_container = $(document.createElement('div'))
      .addClass($.pikatag.CLASS_NAMES.autoCompleteResult)
      .append(document.createElement('ul'))

    $ac_result_container.insertAfter($fake_input) if $fake_input.length

    # Store related elements & settings before any real action
    $holder.data($.pikatag.DATA_KEY_NAMES.realInput, this)
    $input_wrapper.data($.pikatag.DATA_KEY_NAMES.realInput, this)
    $fake_input.data($.pikatag.DATA_KEY_NAMES.realInput, this) if $fake_input.length

    # Store DOM object, if you want jQuery object just wrap them again
    $this.data($.pikatag.DATA_KEY_NAMES.realInput, this)
    $this.data($.pikatag.DATA_KEY_NAMES.masterContainer, $holder[0])
    $this.data($.pikatag.DATA_KEY_NAMES.tagContainer, $tags_container[0])
    $this.data($.pikatag.DATA_KEY_NAMES.fakeInputWrapper, $input_wrapper[0])
    $this.data($.pikatag.DATA_KEY_NAMES.fakeInput, $fake_input[0]) if $fake_input.length # Could be undefined
    $this.data($.pikatag.DATA_KEY_NAMES.autoCompleteResultContainer, $ac_result_container[0])
    $this.data($.pikatag.DATA_KEY_NAMES.settings, data)




    ## Let's deal with data
    unless $this.val() is ""
      $.pikatag.importTags $this, $this.val()

    # Auto add tag
    $fake_input.length and $fake_input.keypress (event) ->
      # if user type delimiter (like comma or space) or 13(enter)
      real_input = $(this).data($.pikatag.DATA_KEY_NAMES.realInput)
      settings = $(real_input)
                    .data($.pikatag.DATA_KEY_NAMES.settings)

      triggerKeyCodes = [settings.delimiter.charCodeAt(0)]
      triggerKeyCodes.push $.pikatag.KEYS.ENTER
      if $.inArray(event.keyCode, triggerKeyCodes) >= 0 # pressed enter or delimiter
        event.preventDefault()

        $.pikatag.autocomplete._selectItem(real_input)

      true


    $fake_input.length and data.removeWithBackspace and $fake_input.keydown (event) ->

      real_input = $(this).data($.pikatag.DATA_KEY_NAMES.realInput)
      settings = $(real_input)
        .data($.pikatag.DATA_KEY_NAMES.settings)

      return unless event.keyCode is $.pikatag.KEYS.BACKSPACE

      # remove last tag with backspace
      if settings.removeWithBackspace and $(this).val() is ""
        event.preventDefault()
        last_tag_text = $($(real_input).data($.pikatag.DATA_KEY_NAMES.tagContainer)).find(".#{$.pikatag.CLASS_NAMES.tag}:last").find(".#{$.pikatag.CLASS_NAMES.tagText}").text()

        $(real_input).removeTag last_tag_text
        $(this).focus()

    # prevent submit when pressing enter with nothing inside
    $fake_input.length and data.preventSubmitOnEnter and $fake_input.keypress (event) ->
      # 13(enter)
      event.preventDefault() if event.keyCode is $.pikatag.KEYS.ENTER

    # Auto complete
    # change event = crap, so try to use these: 'change keypress paste focus textInput input'
    $fake_input.length and data.autocomplete.source? and $fake_input.on 'input', (event) ->
      real_input = $(this).data($.pikatag.DATA_KEY_NAMES.realInput)
      settings = $(real_input)
        .data($.pikatag.DATA_KEY_NAMES.settings)

      if $(this).val().length < settings.minChars
        $.pikatag.autocomplete.clear(real_input)
        return

      existing_timeoutID = $(real_input).data($.pikatag.DATA_KEY_NAMES.autoCompleterefreshIntervalID)
      clearInterval existing_timeoutID if existing_timeoutID?

#      $.pikatag.autocomplete.render(real_input)
      timeoutID = setTimeout(
        ->
          $.pikatag.autocomplete.render(real_input)
        , settings.autocomplete.refreshInterval
      )
      $(real_input).data($.pikatag.DATA_KEY_NAMES.autoCompleterefreshIntervalID, timeoutID)

    $fake_input.length and $fake_input.keyup (event) ->
      real_input = $(this).data($.pikatag.DATA_KEY_NAMES.realInput)

      if event.keyCode is $.pikatag.KEYS.UP
        $.pikatag.autocomplete.selectPrev(real_input)
      else if event.keyCode is $.pikatag.KEYS.DOWN
        $.pikatag.autocomplete.selectNext(real_input)


  # end of @each

  # return the object called upon
  this


# Params:
# tag_name: tag name
# options: options
$.fn.addTag = (tag_name, options) ->
  options = jQuery.extend(
    focus: false
    callback: true
    validate: true # When importing tag you dont need to check
    unique: true
  , options)

  @each ->
    id = $(this).prop("id")
    tags_container = $(this).data($.pikatag.DATA_KEY_NAMES.tagContainer)
    input_wrapper = $(this).data($.pikatag.DATA_KEY_NAMES.fakeInputWrapper)
    fake_input = $(this).data($.pikatag.DATA_KEY_NAMES.fakeInput)
    settings = $(this).data($.pikatag.DATA_KEY_NAMES.settings)

    tag_name_list = $(this).val().split(settings.delimiter) # Get current tag name list, trust real input
    tag_name_list = new Array() if tag_name_list[0] is "" # well spliting an empty string gives you an array with an empty string

    tag_name = jQuery.trim(tag_name)


    # Start validation
    error_msg = null

    # In any situation empty tag is not allowed
    error_msg = "Empty String" if tag_name is ""

    if options.validate
      # min char count check
      if tag_name.length < settings.minChars
        error_msg = "Too short, min length: #{settings.minChars}"

      # max char count check
      if settings.maxChars > 0 and tag_name.length > settings.maxChars
        error_msg = "Too long, max length: #{settings.maxChars}"

      # max tag count check
      if settings.maxTags > 0 and tag_name_list.length >= settings.maxTags
        error_msg = "Too many tags, max: #{settings.maxTags}"

      # Delimiter check
      if new RegExp(".*#{settings.delimiter}.*").test(tag_name)
        error_msg = "Contains delimiter: #{settings.delimiter}"

      if options.unique
        $.pikatag._flashDuplicated(this, tag_name)
        error_msg = "Duplicated" if $(this).tagExist(tag_name)


    # process error message anyway, since this method clear error if there is none
    $.pikatag._processError this, error_msg

    shouldSkipTag = error_msg? # could add something later
    return if shouldSkipTag

    # Create a tag "object"
    $tag_dom_obj = $(document.createElement('span'))
      .addClass($.pikatag.CLASS_NAMES.tag)
      .append(
        $(document.createElement('span')) # wrapper for the text & remove archor
          .addClass($.pikatag.CLASS_NAMES.tagText)
          .text(tag_name)
      ).data($.pikatag.DATA_KEY_NAMES.realInput, this)


    $tag_dom_obj.click (event) ->
      $($(this).data($.pikatag.DATA_KEY_NAMES.realInput)).removeTag(tag_name)

    $tag_dom_obj.appendTo(tags_container)
    # tag "object" operation end

    # cancel autocomplete
    existing_timeoutID = $(this).data($.pikatag.DATA_KEY_NAMES.autoCompleterefreshIntervalID)
    clearInterval existing_timeoutID if existing_timeoutID?

    tag_name_list.push tag_name

    if fake_input?
      $(fake_input).val ""

      # Focus option
      if options.focus
        $(fake_input).focus()
      else
        $(fake_input).blur()

    $.pikatag._updateTagsField this, tag_name_list

    ###
    Not in used
    ###
#    if options.callback and global_callbacks[id] and global_callbacks[id]["onAddTag"]
#      f = global_callbacks[id]["onAddTag"]
#      f.call this, tag_name
#    if global_callbacks[id] and global_callbacks[id]["onChange"]
#      f = global_callbacks[id]["onChange"]
#      f.call this, $(this), tag_name_list[tag_name_list.length - 1]

  # always return the object being called
  this

# Params:
# tag_name: tag name
#
# 1. clear all tags
# 2. Update real input value
# 3. import tags by the updated value
$.fn.removeTag = (tag_name) ->
  @each ->
    id = $(this).prop("id")
    settings = $(this).data($.pikatag.DATA_KEY_NAMES.settings)
    # #1
    $($(this).data($.pikatag.DATA_KEY_NAMES.tagContainer)).find(".#{$.pikatag.CLASS_NAMES.tag}").remove()

    # #2
    tag_name_list = $(this).val().split(settings.delimiter)

    # Reverse order make sure no item will be skipped
    # See http://stackoverflow.com/questions/9792927/javascript-array-search-and-remove-string
    i = tag_name_list.length - 1
    while i >= 0
      tag_name_list.splice(i, 1) if tag_name_list[i] is tag_name
      i--
    $.pikatag._updateTagsField this, tag_name_list


    # #3
    $.pikatag.importTags this, $(this).prop("value")

#    if global_callbacks[id] and global_callbacks[id]["onRemoveTag"]
#      f = global_callbacks[id]["onRemoveTag"]
#      f.call this, tag_name

  # always return the object being called
  this


# Params:
# tag_name: tag name
$.fn.tagExist = (tag_name) ->
  id = $(this).prop("id")
  tag_name_list = $(this).val().split($(this).data($.pikatag.DATA_KEY_NAMES.settings).delimiter)

  # No empty tag allowed anyway
  return false if tag_name is ""

  $.inArray(tag_name, tag_name_list) >= 0 #true when tag exists, false when not

# Params:
# obj: the real input DOM object
# val: of course the value you want to set, seperated by custom delimiter you set
#
# 1. Clear content
# 2. Split string by delimiter
# 3. Add tags
# 4. Trigger onChange callback if any
$.pikatag.importTags = (obj, val) ->
  $(obj).val ""

  id = $(obj).prop("id")
  tag_name_list = val.split($(obj).data($.pikatag.DATA_KEY_NAMES.settings).delimiter)
  tag_name_list = new Array() if tag_name_list[0] is "" # well spliting an empty string gives you an array with an empty string

  for tag_name in tag_name_list
    $(obj).addTag tag_name,
      focus: false
      callback: false
      validate: false

#  if global_callbacks[id] and global_callbacks[id]["onChange"]
#    f = global_callbacks[id]["onChange"]
#    f.call obj, obj, tag_name_list[i]

# Params:
# obj: the real input DOM object
# tag_name_list: JS Array object, will be joined by delimiter
#
# well updates the value of the real input
$.pikatag._updateTagsField = (obj, tag_name_list) ->
  id = $(obj).prop("id")
  $(obj).prop({value: tag_name_list.join($(obj).data($.pikatag.DATA_KEY_NAMES.settings).delimiter)})

# Params:
# obj: the real input DOM object
# err_msg: string of error message
$.pikatag._processError = (obj, err_msg = null) ->
  fake_input = $(obj).data($.pikatag.DATA_KEY_NAMES.fakeInput)
  settings = $(obj).data($.pikatag.DATA_KEY_NAMES.settings)

  # Remove class first anyway
  $(fake_input).removeClass $.pikatag.CLASS_NAMES.fakeInputInvalid

  # Give it a class to style it
  if err_msg?
    $(fake_input).addClass $.pikatag.CLASS_NAMES.fakeInputInvalid
    console.log(err_msg) if console? and settings.debug

$.pikatag._flashDuplicated = (obj, tag_name) ->
  settings = $(obj).data($.pikatag.DATA_KEY_NAMES.settings)

  return unless settings.flashOnDuplicate

  $target_tags = $.pikatag._findTag(obj, tag_name)

  $target_tags.fadeOut('fast').fadeIn('fast')

# return $ object of tag span, since operating on null is not good
$.pikatag._findTag = (obj, tag_name) ->
  tag_container = $(obj).data($.pikatag.DATA_KEY_NAMES.tagContainer)
  $all_tags = $(tag_container).children(".#{$.pikatag.CLASS_NAMES.tag}")

  $target_tags = $all_tags.filter((index) ->
    $(".#{$.pikatag.CLASS_NAMES.tagText}", this).text() == tag_name
  )

  $target_tags



###
Autocomplete section
###

$.pikatag ||= {}
$.pikatag.autocomplete ||= {}

# obj: The real input DOM object
# Get the source, must be array
$.pikatag.autocomplete._filteredSource = (obj) ->
  $this = $(obj)
  settings = $this.data($.pikatag.DATA_KEY_NAMES.settings)
  ac_settings = settings.autocomplete
  source = ac_settings.source

  return [] unless source? # When source is null, it means turn off

  query_string = $($this.data($.pikatag.DATA_KEY_NAMES.fakeInput)).val()

  return if query_string.length < settings.minChars

  if typeof source is "function" # Is a function? call it
    source(query_string, obj, (obj, results) ->
      $.pikatag.autocomplete._render(obj, results)
    )
    return [] # return empty array to end the call, and wait for callback
  else # Assume to be array, just return
    return $.pikatag.autocomplete._filteredLocalSource(obj, query_string)


# params
# tag_name_list: static string array
# query_string: keyword
#
# Just for filtering simple local tag name array
# If you do AJAX in source, that means server side has done the filtering already
# no need to call this function
$.pikatag.autocomplete._filteredLocalSource = (obj, query_string) ->
  $this = $(obj)
  settings = $this.data($.pikatag.DATA_KEY_NAMES.settings)
  ac_settings = settings.autocomplete

  source = ac_settings.source
  filter_func = ac_settings.filter_func

  tag_list = source

  return [] if query_string is ""

  results = []

  for tag in tag_list
    results.push tag if filter_func.call tag, query_string

  results

# Render the filtered source
$.pikatag.autocomplete.render = (obj) ->
  $this = $(obj)
  settings = $this.data($.pikatag.DATA_KEY_NAMES.settings)
  ac_settings = settings.autocomplete
  source = ac_settings.source
  render_func = ac_settings.render_func

  results = $.pikatag.autocomplete._filteredSource(obj) # this method handles all the source

  # reset autocomplete
  $.pikatag.autocomplete.clear(obj)

  # call internal render function
  $.pikatag.autocomplete._render(obj, results)

# Only for rendring, not clearing prev results
$.pikatag.autocomplete._render = (obj, results) ->

  # HACK: avoid unknown source undefined error
  return unless results?

  return if results.length is 0 # no result = render nothing

  $this = $(obj)
  settings = $this.data($.pikatag.DATA_KEY_NAMES.settings)
  ac_settings = settings.autocomplete
  render_func = ac_settings.render_func
  ac_result_container = $this.data($.pikatag.DATA_KEY_NAMES.autoCompleteResultContainer)
  $ac_list = $(ac_result_container).children('ul')


  for tag_item in results
    $ac_list.append(render_func.call tag_item)

  $(ac_result_container).show()

$.pikatag.autocomplete.clear = (obj) ->
  $this = $(obj)
  ac_result_container = $this.data($.pikatag.DATA_KEY_NAMES.autoCompleteResultContainer)

  $ac_list = $(ac_result_container).children('ul')
  $ac_list.empty()
  $(ac_result_container).hide()

$.pikatag.autocomplete.selectPrev = (obj) ->
  # Try to find the current selected item, if none, select the last
  $this = $(obj)
  $ac_result_container = $($this.data($.pikatag.DATA_KEY_NAMES.autoCompleteResultContainer))
  $item_list = $ac_result_container.find('ul')

  $selected_item = $item_list.find("li.#{$.pikatag.CLASS_NAMES.autoCompleteResultItemSelected}").removeClass($.pikatag.CLASS_NAMES.autoCompleteResultItemSelected)
  $prev_item = $selected_item.prev()

  $item_to_select = $item_list.find('li:last') # defualt is the last one
  $item_to_select = $prev_item if $prev_item.length > 0 # if there is a previous item

  $item_to_select.addClass($.pikatag.CLASS_NAMES.autoCompleteResultItemSelected)

$.pikatag.autocomplete.selectNext = (obj) ->
  # Try to find the current selected item, if none, select the last
  $this = $(obj)
  $ac_result_container = $($this.data($.pikatag.DATA_KEY_NAMES.autoCompleteResultContainer))
  $item_list = $ac_result_container.find('ul')

  $selected_item = $item_list.find("li.#{$.pikatag.CLASS_NAMES.autoCompleteResultItemSelected}").removeClass($.pikatag.CLASS_NAMES.autoCompleteResultItemSelected)
  $next_item = $selected_item.next()

  $item_to_select = $item_list.find('li:first') # defualt is the first one
  $item_to_select = $next_item if $next_item.length > 0 # if there is a next item

  $item_to_select.addClass($.pikatag.CLASS_NAMES.autoCompleteResultItemSelected)

# select the current item (using the tag text stored inside data)
# if none, use current fake input
$.pikatag.autocomplete._selectItem = (obj) ->
  # Try to find the current selected item, if none, select the last
  $this = $(obj)
  settings = $this.data($.pikatag.DATA_KEY_NAMES.settings)
  $ac_result_container = $($this.data($.pikatag.DATA_KEY_NAMES.autoCompleteResultContainer))
  $item_list = $ac_result_container.find('ul')

  $selected_item = $item_list.find("li.#{$.pikatag.CLASS_NAMES.autoCompleteResultItemSelected}")

  tag_name = $($this.data($.pikatag.DATA_KEY_NAMES.fakeInput)).val()
  if $selected_item.length > 0
    tag_name = $selected_item.data('value')

  $this.addTag tag_name,
    focus: true
    unique: settings.unique

  $.pikatag.autocomplete.clear obj


###
Code sample for using local source
###
#$ ->
#  $("#page-edit-my-skills .skill-input").pikatag({
#    placeholder: "Add a skill..."
#    minChars: 2
#
#    autocomplete:
#      source:
#      [
#        {text: "Rails", count: 3, description: "Ruby on Rails"}
#        {text: "Ruby", count: 15, description: "Great Dynamic Programming Language"}
#        {text: "Minecraft", count: 7, description: "You haven't heard about it!?"}
#      ]
#      filter_func: (query_string) ->
#        new RegExp(".*#{query_string}.*").test(this.text)
#      render_func: ->
#        list_item = document.createElement('li')
#        $list_item = $(list_item)
#
#        # Set the structure of list item
#        $list_item.text("#{@text} (#{@count}) - #{@description}") # assume source item is string already
#
#        # Set the text to insert when this item is selected
#        $list_item.data('value', @text)
#
#        list_item # reutrn the dom/jQuery object for append
#  })

###
Code sample for using ajax source
###
#$ ->
#  $("#page-edit-my-skills .skill-input").pikatag({
#    placeholder: "Add a skill..."
#    minChars: 2
#
#    autocomplete:
#      source: (query, obj, render_callback) ->
#
#        results = []
#
#        $.ajax
#          url: '/skills.json'
#          data:
#            q: query
#
#          success: (results) ->
#            render_callback(obj, results)
#          error: ->
#            # do nothing
#
#
#      results
#      filter_func: (query_string) ->
#        new RegExp(".*#{query_string}.*").test(this.text)
#      render_func: ->
#        list_item = document.createElement('li')
#        $list_item = $(list_item)
#
#        # Set the structure of list item
#        $list_item.text("#{@text} (#{@count}) - #{@description}") # assume source item is string already
#
#        # Set the text to insert when this item is selected
#        $list_item.data('value', @text)
#
#        list_item # reutrn the dom/jQuery object for append
#  })

