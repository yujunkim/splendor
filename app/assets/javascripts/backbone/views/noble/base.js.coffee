BSplendor.Views.Noble = {}

class BSplendor.Views.Noble.Base extends Backbone.View

  events:
    'mouseenter': 'mouseentered'
    'mouseleave': 'mouseleaved'

  className: 'noble-view'

  template: JST["backbone/templates/noble/base"]

  initialize: (options) ->

  render: ->
    @$el.addClass("noble-view-#{@collection.indexOf(@model)}") if @collection?
    @$el.html @template @

  mouseentered: (e) =>
    game.zoomField.visualize("noble", @model)
    e.stopPropagation()

  mouseleaved: (e) =>
    game.zoomField.reset()
    e.stopPropagation()
