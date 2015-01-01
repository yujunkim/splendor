BSplendor.Views.Card = {}

class BSplendor.Views.Card.Base extends Backbone.View

  events:
    'click .purchase': 'purchase'
    'click .reserve': 'reserve'
    'click': 'cancel'
    "mousemove": "mousemoved"

  className: 'card-view'

  template: JST["backbone/templates/card/base"]

  initialize: () ->
    @model.on("change", @render, @)
    @model.on("purchasable-player-change", @changePurchasablePlayerClass, @)

  render: ->
    @$el.addClass("card-view-#{@collection.indexOf(@model)}") if @collection?
    @$el.html @template @
    @$el.find(".card").addClass("revealed") if @model.get("revealed")
    @changePurchasablePlayerClass()

  changePurchasablePlayerClass: =>
    @$el.find(".card").removeClass () ->
      ret = ""
      @className.split(' ').forEach (cls) ->
        ret += cls + " " if cls.match("purchasable-player")
      ret
    @model.purchasablePlayer.forEach (player) =>
      @$el.find(".card").addClass("purchasable-player-#{player.get("id")}")
      if player.get("isMe")
        @$el.find(".card").addClass("purchasable-player-me")

  cancel: (e) =>
    e.stopPropagation()
    @model.cancel()

  purchase: (e) =>
    e.stopPropagation()
    @model.purchase()

  reserve: (e) =>
    e.stopPropagation()
    @model.reserve()

  mousemoved: (e) ->
    e.stopPropagation() unless @model.collection? && @model.collection.player?
    game.trigger("gameChildHovered", e, @)


