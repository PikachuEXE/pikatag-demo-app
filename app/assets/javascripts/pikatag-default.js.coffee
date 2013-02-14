jQuery ($) ->
  $('#pikatag-default').pikatag()

  $('#pikatag-with-custom-input').pikatag
    generateInput: false
    customFakeInput: '#the-custom-input'

  $('#pikatag-with-limit').pikatag
    minChars: 3
    maxChars: 10
    maxTags: 5
    debug: true

  $('#pikatag-with-tag-container').pikatag
    tagContainer: '#the-tag-container'

  $('#pikatag-without-backspace').pikatag
    removeWithBackspace: false

  $('#pikatag-with-autocomplete').pikatag
    autocomplete:
      source: ['Tag1', 'Tag2', 'Tag3', 'Ruby on Rails', 'Rails', 'Ruby']

  $('#pikatag-with-debug').pikatag
    debug: true