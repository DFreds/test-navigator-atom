{CompositeDisposable} = require 'atom'

module.exports = TestNavigatorAtom =
  subscriptions: null

  activate: (state) ->

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'test-navigator:navigate': => @navigate()

  deactivate: ->
    @subscriptions.dispose()

  navigate: ->
    console.log 'TestNavigatorAtom was toggled!'
