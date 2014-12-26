class BSplendor.Models.Card extends Backbone.Model

  defaults:
    className: "Card"

  initialize: ->
    @purchasablePlayer = []

  cancel: ->
    if actionField = @collection.actionField
      actionField.reset()

  purchase: ->
    if player = @collection.player
      if player.get("me") && @collection.reservation
        game.purchaseCard(@)
    else if @collection.type != "pack"
      game.purchaseCard(@)

  reserve: ->
    return if @collection.actionField || @collection.player
    game.reserveCard(@)

  updateAttributes: (attrs)->
    @set(attrs)

  setPurchasablePlayer: (player)->
    @purchasablePlayer.push(player)
    @trigger("purchasable-player-change")

  resetPurchasablePlayer: ()->
    @purchasablePlayer = []
    @trigger("purchasable-player-change")
