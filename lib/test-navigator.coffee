{CompositeDisposable} = require 'atom'

module.exports = TestNavigatorAtom =
  subscriptions: null

  activate: (state) ->
    console.log "stuff"
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'test-navigator:navigate': => @navigate()

  deactivate: ->
    @subscriptions.dispose()

  navigate: ->
    activeTextEditor = atom.workspace.getActiveTextEditor()

    fileName = @getFileName(activeTextEditor.getTitle())

    possibleFileNames = []
    for testFilePattern in atom.config.get("test-navigator.testFilePatterns")
      console.log "#{testFilePattern}"
      possibleFileNames.push("#{fileName}#{testFilePattern}")

    console.log "#{possibleFileNames}"
    console.log "File name is #{fileName}"

  getFileName: (fileTitle) ->
    splitTitle = fileTitle.split(".")

    result = splitTitle[0]
    i = 1
    while i < splitTitle.length - 1
      result += "." + splitTitle[i]

    return result
