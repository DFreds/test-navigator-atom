
module.exports =
class TextEditorInfo
  constructor: (@textEditor = null) ->

  getFileName: ->
    return null if not @textEditor?

    splitTitle = @textEditor.getTitle().split(".")

    result = splitTitle[0]
    i = 1
    while i < splitTitle.length - 1
      result += "." + splitTitle[i]

    return result
    
  getFileType: ->
    return null if not @textEditor?

    splitTitle = @textEditor.getTitle().split(".")

    if splitTitle.length > 1
      return splitTitle[splitTitle.length - 1]
    else
      return null
