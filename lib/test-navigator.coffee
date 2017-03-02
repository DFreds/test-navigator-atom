TextEditorInfo = require './text-editor-info'
SelectFileView = require './select-file-view'
{CompositeDisposable} = require 'atom'

module.exports = TestNavigatorAtom =
  selectFileView: null
  subscriptions: null
  fileSystem: null

  activate: (state) ->
    @selectFileView = new SelectFileView
    @subscriptions = new CompositeDisposable
    @fileSystem = require 'file-system'

    @addAtomCommands()
    @handleViewEvents()

  deactivate: ->
    @subscriptions.dispose()

  addAtomCommands: ->
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'test-navigator:navigate': => @navigate()

  handleViewEvents: ->
    @subscriptions.add @selectFileView.onConfirmed(
      @openFile.bind(@)
    )

  navigate: ->
    textEditorInfo = new TextEditorInfo(atom.workspace.getActiveTextEditor())

    fileName = textEditorInfo.getFileName()
    fileType = textEditorInfo.getFileType()

    if not fileName? or not fileType?
      atom.notifications.addError("Unable to gather file information")

    possibleFileNames = @getPossibleFileNames(fileName, fileType)

    if possibleFileNames.length is 0
      atom.notifications.addError("Test patterns must exist to navigate to test\
      Please modify your configuration.")
      return

    matchingFiles = @getMatchingFiles(fileType, possibleFileNames)

    if matchingFiles.length == 1
      console.log "one file only"
      @openFile(matchingFiles[0])
    else
      console.log "multiple files"
      @displaySelectView(matchingFiles)

  getPossibleFileNames: (fileName, fileType) ->
    possibleFileNames = []

    implFileName = @getImplFileNameIfTestFile(fileName)

    if implFileName?
      possibleFileNames.push("#{implFileName}.#{fileType}")
    else
      for testFilePattern in atom.config.get("test-navigator.testFilePatterns")
        possibleFileNames.push("#{fileName}#{testFilePattern}.#{fileType}")

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

    # TODO find a way to ignore things like node_modules
    for path in projectPaths
      @fileSystem.recurseSync(path, [
        "**/*.#{fileType}*"
      ], (filePath, relative, fileName) ->
        if possibleFileNames.includes fileName
          matchingFiles.push(filePath)
      )

    return matchingFiles

  openFile: (filePath) ->
    openConfig = {
      searchAllPanes: true
    }

    splitLocation = atom.config.get("test-navigator.location")

    if splitLocation != "none"
      openConfig.split = splitLocation

    atom.workspace.open(filePath, openConfig)

  displaySelectView: (matchingFiles) ->
    @selectFileView.populateAndShow(matchingFiles)
