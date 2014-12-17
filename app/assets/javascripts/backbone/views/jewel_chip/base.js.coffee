BSplendor.Views.JewelChip = {}

class BSplendor.Views.JewelChip.Base extends Backbone.View

  events:
    'click': 'clicked'
    "mousemove": "mousemoved"

  className: 'jewel-chip-view'

  template: JST["backbone/templates/jewel_chip/base"]

  initialize: () ->

  render: ->
    @$el.addClass("jewel-chip-view-#{@collection.indexOf(@model)}") if @collection?
    @$el.html @template @
    @$el.find(".jewel-chip").addClass(@model.get("jewelType"))

  clicked: =>
    @model.clicked()

  mousemoved: (e) ->
    return unless @collection
    e.stopPropagation() unless @model.collection? && @model.collection.user?
    game.trigger("gameChildHovered", e, @)
