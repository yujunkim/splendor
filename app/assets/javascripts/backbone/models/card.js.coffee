class BSplendor.Models.Card extends Backbone.Model

  initialize: ->
    @purchasableUser = []

  cancel: ->
    if actionField = @collection.actionField
      actionField.reset()

  purchase: ->
    if user = @collection.user
      if user.get("me") && @collection.reservation
        game.purchaseCard(@)
    else if @collection.type != "pack"
      game.purchaseCard(@)

  reserve: ->
    return if @collection.actionField || @collection.user
    game.reserveCard(@)

  updateAttributes: (attrs)->
    @set(attrs)

  setPurchasableUser: (user)->
    @purchasableUser.push(user)
    @trigger("purchasable-user-change")

  resetPurchasableUser: ()->
    @purchasableUser = []
    @trigger("purchasable-user-change")
