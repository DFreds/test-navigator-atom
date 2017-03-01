TextEditorInfo = require './text-editor-info'
{CompositeDisposable} = require 'atom'

module.exports = TestNavigatorAtom =
  subscriptions: null
  fileSystem: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @fileSystem = require 'file-system'

    @addAtomCommands()

  deactivate: ->
    @subscriptions.dispose()

  addAtomCommands: ->
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'test-navigator:navigate': => @navigate()

  navigate: ->
    textEditorInfo = new TextEditorInfo(atom.workspace.getActiveTextEditor())

    fileName = textEditorInfo.getFileName()
    fileType = textEditorInfo.getFileType()

    possibleFileNames = @getPossibleFileNames(fileName, fileType)

    if possibleFileNames.length is 0
      atom.notifications.addError("Test patterns must exist to navigate to test\
      Please modify your configuration.")
      return

    matchingFiles = @getMatchingFiles(fileType, possibleFileNames)

    # TODO make split location configurable
    # TODO should this only open the first one? or maybe show a list of options?
    for matchingFile in matchingFiles
      atom.workspace.open(matchingFile, {split: "right"})

  getPossibleFileNames: (fileName, fileType) ->
    possibleFileNames = []
    for testFilePattern in atom.config.get("test-navigator.testFilePatterns")
      possibleFileNames.push("#{fileName}#{testFilePattern}.#{fileType}")

    return possibleFileNames

  # TODO make this find file that matches given file path closest
  getMatchingFiles: (fileType, possibleFileNames) ->
    matchingFiles = []
    projectPaths = atom.project.getPaths()

    # TODO find a way to ignore things like node_modules
    for path in projectPaths
      @fileSystem.recurseSync(path, [
        "**/*.#{fileType}*"
      ], (filePath, relative, fileName) ->
        if possibleFileNames.includes fileName
          matchingFiles.push(filePath)
      )

    return matchingFiles
