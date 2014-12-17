BSplendor.Views.User = {}

class BSplendor.Views.User.Base extends Backbone.View

  events:
    'mousemove': 'mousemoved'

  className: 'user'

  template: JST["backbone/templates/user/base"]

  initialize: () ->
    @$el.addClass(@options.position)
    if @model.get("me")
      @$el.addClass("me")
    else
      @$el.addClass("others")
    @model.on 'reset-end', @render, @
    @model.on 'change', @render, @

  addCollections: (el) ->
    _.each @model.purchased, (collection, jewelType) =>
      purchasedCardListView = new BSplendor.Views.CardList.Purchased
        collection: collection
        jewelType: jewelType
      purchasedCardListView.render()
      el.append purchasedCardListView.el

    nobleListView = new BSplendor.Views.NobleList.Base
      collection: @model.nobleList
    nobleListView.render()
    el.append nobleListView.el

    reservationCardListView = new BSplendor.Views.CardList.Reservation
      collection: @model.reservationCardList
    reservationCardListView.render()
    el.append reservationCardListView.el

    _.each @model.jewelChip, (collection, type) =>
      jewelChipListView = new BSplendor.Views.JewelChipList.Base
        collection: collection,
        type: type
      jewelChipListView.render()
      el.append jewelChipListView.el

  render: ->
    @$el.html(@template @)
    if @model.get("currentTurn")
      @$el.addClass("current-turn")
    else
      @$el.removeClass("current-turn")
    if @model.get("winner")
      @$el.addClass("winner")
    @addCollections(@$el)

  mousemoved: (e) ->
    e.stopPropagation()
    game.trigger("gameChildHovered", e, @)
