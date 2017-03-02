TextEditorInfo = require './text-editor-info'
SelectFileView = require './select-file-view'
FileFinder = require './file-finder'
{CompositeDisposable} = require 'atom'

module.exports = TestNavigatorAtom =
  selectFileView: null
  subscriptions: null

  activate: (state) ->
    @selectFileView = new SelectFileView
    @subscriptions = new CompositeDisposable

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
    fileFinder = new FileFinder

    fileInfo = textEditorInfo.getFileInfo()

    if not fileInfo?.isValid()
      atom.notifications.addWarning("Unable to gather file information")
      return

    possibleFileNames = fileFinder.getPossibleFileNames(fileInfo)

    if possibleFileNames.length is 0
      atom.notifications.addWarning("Test patterns must exist to navigate to\
       test. Please update your configuration.")
      return

    matchingFiles = fileFinder.getMatchingFiles(
      fileInfo.fileType,
      possibleFileNames
    )

    if matchingFiles.length == 1
      @openFile(matchingFiles[0])
    else if matchingFiles.length > 1
      @displaySelectView(matchingFiles)
    else
      atom.notifications.addWarning("Did not find any matching files")

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
