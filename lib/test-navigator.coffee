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

    fileInfo = textEditorInfo.getFileInfo()

    if not fileInfo?.isValid()
      atom.notifications.addWarning("Unable to gather file information")
      return

    possibleFileNames = @getPossibleFileNames(fileInfo)

    if possibleFileNames.length is 0
      atom.notifications.addWarning("Test patterns must exist to navigate to\
       test. Please update your configuration.")
      return

    matchingFiles = @getMatchingFiles(fileInfo.fileType, possibleFileNames)

    if matchingFiles.length == 1
      @openFile(matchingFiles[0])
    else if matchingFiles.length > 1
      @displaySelectView(matchingFiles)
    else
      atom.notifications.addWarning("Did not find any matching files")

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
