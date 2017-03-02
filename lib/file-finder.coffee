module.exports =
class FileFinder

  constructor: ->
    @fileSystem = require 'file-system'

  getPossibleFileNames: (fileInfo) ->
    possibleFileNames = []

    implFileName = @getImplFileNameIfTestFile(fileInfo.fileName)

    if implFileName?
      possibleFileNames.push("#{implFileName}.#{fileInfo.fileType}")
    else
      for testFilePattern in atom.config.get("test-navigator.testFilePatterns")
        possibleFileNames.push(
          "#{fileInfo.fileName}#{testFilePattern}.#{fileInfo.fileType}"
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
        console.log "#{relative}"
        if possibleFileNames.includes fileName
          matchingFiles.push(relative)
      )

    return matchingFiles
