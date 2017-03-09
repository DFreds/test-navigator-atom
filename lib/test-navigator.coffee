FileInfoHelper = require './file-info-helper'
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
    fileInfoHelper = new FileInfoHelper(atom.workspace.getActiveTextEditor())
    fileFinder = new FileFinder

    if not fileInfoHelper?.isValid()
      atom.notifications.addWarning("Unable to gather file information")
      return

    possibleFileNames = fileFinder.getPossibleFileNames(
      fileInfoHelper.getFileName(),
      fileInfoHelper.getFileType()
    )

    if possibleFileNames.length is 0
      atom.notifications.addWarning("Test patterns must exist to navigate to\
       test. Please update your configuration.")
      return

    matchingFiles = fileFinder.getMatchingFiles(
      fileInfoHelper.getFileType(),
      possibleFileNames
    )

    if matchingFiles.length == 1
      @openFile(matchingFiles[0].relative)
    else if matchingFiles.length > 1
      matchingFiles = @levenshteinSort(matchingFiles, fileInfoHelper.getPath())
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

  levenshteinSort: (matchingFiles, path) ->
    levenshtein = require 'fast-levenshtein'
    _ = require 'lodash'

    for matchingFile in matchingFiles
      distance = levenshtein.get(matchingFile.filePath, path)
      matchingFile.distance = distance

    return _.sortBy(matchingFiles, 'distance')
