BSplendor.Views.Noble = {}

class BSplendor.Views.Noble.Base extends Backbone.View

  events:
    "mousemove": "mousemoved"

  className: 'noble-view'

  template: JST["backbone/templates/noble/base"]

  initialize: (options) ->

  render: ->
    @$el.addClass("noble-view-#{@collection.indexOf(@model)}") if @collection?
    @$el.html @template @

  mousemoved: (e) ->
    e.stopPropagation() unless @model.collection? && @model.collection.user?
    game.trigger("gameChildHovered", e, @)
