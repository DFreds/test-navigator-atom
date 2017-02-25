{CompositeDisposable} = require 'atom'

module.exports = TestNavigatorAtom =
  modalPanel: null
  subscriptions: null

  activate: (state) ->

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'test-navigator:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()

  toggle: ->
    console.log 'TestNavigatorAtom was toggled!'
