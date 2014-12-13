BSplendor.Views.CardList = {}

class BSplendor.Views.CardList.Base extends Backbone.View

  className: 'card-list'

  template: JST["backbone/templates/card_list/base"]

  initialize: ->
    @collection.on "remove",  @render, @
    @collection.on 'add', @addOne, @
    @$el.addClass("level#{@options.level}") if @options.level

  render: ->
    @$el.addClass(@options.jewelType)
    @$el.children().remove()
    @collection.forEach(@addOne, @)
    this

  addOne: (card)->
    cardView = new BSplendor.Views.Card.Base(model: card, collection: @collection)
    cardView.render()
    @$el.append cardView.el

