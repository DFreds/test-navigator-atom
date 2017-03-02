{Emitter} = require 'atom'
{SelectListView} = require 'atom-space-pen-views'

module.exports =
class SelectFileView extends SelectListView
  initialize: ->
    super
    @addClass('overlay from-top')

    @emitter = new Emitter
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.hide()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    @emitter.emit 'confirmed', item
    @panel.hide()

  cancelled: ->
    @panel.hide()

  onConfirmed: (callback) ->
    @emitter.on 'confirmed', callback

  populateAndShow: (items) ->
    @setItems(items)
    @populateList()
    @panel.show()
    @focusFilterEditor()
