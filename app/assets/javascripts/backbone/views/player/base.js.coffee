BSplendor.Views.Player = {}

class BSplendor.Views.Player.Base extends Backbone.View

  events:
    'mousemove': 'mousemoved'

  className: 'player'

  template: JST["backbone/templates/player/base"]

  initialize: () ->
    @$el.addClass(@options.position)
    if @model.get("isMe")
      @$el.addClass("me")
    else
      @$el.addClass("others")
    @model.on 'reset-end', @render, @
    @model.on 'change', @render, @

  render: ->
    @$el.html(@template @)
    if @model.get("currentTurn")
      @$el.addClass("current-turn")
    else
      @$el.removeClass("current-turn")
    if @model.get("winner")
      @$el.addClass("winner")

    _.each @model.purchasedCards, (collection, jewelType) =>
      purchasedCardListView = new BSplendor.Views.CardList.Purchased
        collection: collection
        jewelType: jewelType
      purchasedCardListView.render()
      @$el.append purchasedCardListView.el

    nobleListView = new BSplendor.Views.NobleList.Base
      collection: @model.nobles
    nobleListView.render()
    @$el.append nobleListView.el

    reservedCardsView = new BSplendor.Views.CardList.Reservation
      collection: @model.reservedCards
    reservedCardsView.render()
    @$el.append reservedCardsView.el

    _.each @model.jewelChips, (collection, jewelType) =>
      jewelChipListView = new BSplendor.Views.JewelChipList.Base
        collection: collection,
        jewelType: jewelType
      jewelChipListView.render()
      @$el.append jewelChipListView.el

  mousemoved: (e) ->
    e.stopPropagation()
    game.trigger("gameChildHovered", e, @)
