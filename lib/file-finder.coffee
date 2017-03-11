MatchingFile = require './model/matching-file'

module.exports =
class FileFinder

  constructor: ->
    @fileSystem = require 'file-system'

  getPossibleFileNames: (fileName, fileType) ->
    possibleFileNames = []

    implFileName = @getImplFileNameIfTestFile(fileName)

    if implFileName?
      possibleFileNames.push("#{implFileName}.#{fileType}")
    else
      for testFilePattern in atom.config.get("test-navigator.testFilePatterns")
        possibleFileNames.push(
          "#{fileName}#{testFilePattern}.#{fileType}"
        )

    return possibleFileNames

  getImplFileNameIfTestFile: (fileName) ->
    for testFilePattern in atom.config.get("test-navigator.testFilePatterns")
      if fileName.endsWith testFilePattern
        return fileName.split(testFilePattern)[0]

    return null

  # TODO make this find file that matches given file path closest
  getMatchingFiles: (fileType, possibleFileNames) ->
    matchingFiles = []
    projectPaths = atom.project.getPaths()

    # TODO make filters configurable
    for path in projectPaths
      @fileSystem.recurseSync(path, [
        "**/*.#{fileType}*",
        "!node_modules/**/*.#{fileType}"
      ], (filePath, relative, fileName) ->
        if possibleFileNames.includes fileName
          matchingFiles.push(new MatchingFile(filePath, relative))
      )

    return matchingFiles
