module.exports =
class FileInfoHelper
  constructor: (@textEditor = null) ->

  isValid: ->
    return @getFileName? and @getFileType?

  getPath: ->
    return null if not @textEditor?
    return @textEditor.getPath()

  getFileName: ->
    return null if not @textEditor?

    splitTitle = @textEditor.getTitle().split(".")

    fileName = splitTitle[0]
    i = 1
    while i < splitTitle.length - 1
      fileName += "." + splitTitle[i]

    return fileName

  getFileType: ->
    fileType = null

    splitTitle = @textEditor.getTitle().split(".")

    if splitTitle.length > 1
      fileType = splitTitle[splitTitle.length - 1]

    return fileType
