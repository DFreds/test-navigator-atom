FileInfo = require './data/file-info'

module.exports =
class TextEditorInfo
  constructor: (@textEditor = null) ->

  getFileInfo: ->
    return null if not @textEditor?

    splitTitle = @textEditor.getTitle().split(".")

    fileName = splitTitle[0]
    i = 1
    while i < splitTitle.length - 1
      fileName += "." + splitTitle[i]

    fileType = null
    if splitTitle.length > 1
      fileType = splitTitle[splitTitle.length - 1]

    return new FileInfo(fileName, fileType)
