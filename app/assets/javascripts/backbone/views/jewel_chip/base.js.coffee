BSplendor.Views.JewelChip = {}

class BSplendor.Views.JewelChip.Base extends Backbone.View

  events:
    'click': 'clicked'
    'mouseenter': 'mouseentered'
    'mouseleave': 'mouseleaved'

  className: 'jewel-chip-view'

  template: JST["backbone/templates/jewel_chip/base"]

  initialize: () ->

  render: ->
    @$el.addClass("jewel-chip-view-#{@collection.indexOf(@model)}") if @collection?
    @$el.html @template @
    @$el.find(".jewel-chip").addClass(@model.get("type"))

  clicked: =>
    @model.clicked()

  mouseentered: (e) =>
    return unless @collection
    game.zoomField.visualize("jewelChipList", @collection)

  mouseleaved: (e) =>
    game.zoomField.reset()
