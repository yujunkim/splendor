BSplendor.Views.Card = {}

class BSplendor.Views.Card.Base extends Backbone.View

  events:
    'click': 'clicked'
    'contextmenu': 'contextmenued'
    'mouseenter': 'mouseentered'
    'mouseleave': 'mouseleaved'

  className: 'card-view'

  template: JST["backbone/templates/card/base"]

  initialize: () ->
    @model.on("change", @render, @)

  render: ->
    @$el.addClass("card-view-#{@collection.indexOf(@model)}") if @collection?
    @$el.html @template @
    @$el.find(".card").addClass("revealed") if @model.get("revealed")
    if @model.get("coverColor")
      @$el.find(".card").css "border-color": @model.get("coverColor")

  clicked: =>
    @model.clicked()

  contextmenued: =>
    @model.contextmenued()

  mouseentered: (e) =>
    if @collection && @collection.type == "pack"
      game.zoomField.visualize("packCardList", @collection)
    else
      game.zoomField.visualize("card", @model)

  mouseleaved: (e) =>
    game.zoomField.reset()


