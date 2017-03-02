module.exports =
class FileInfo
  constructor: (@fileName, @fileType) ->

  isValid: ->
    return @fileName? and @fileType?
