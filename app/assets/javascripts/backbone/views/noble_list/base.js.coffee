BSplendor.Views.NobleList = {}

class BSplendor.Views.NobleList.Base extends Backbone.View

  className: 'noble-list'

  template: JST["backbone/templates/noble_list/base"]

  initialize: ->
    @collection.on "remove",  @render, @
    @collection.on 'add', @addOne, @

  render: ->
    @$el.children().remove()
    @collection.forEach(@addOne, @)
    this

  addOne: (noble)->
    nobleView = new BSplendor.Views.Noble.Base(model: noble, collection: @collection)
    nobleView.render()
    @$el.append nobleView.el

