class BSplendor.Models.Card extends Backbone.Model

  initialize: ->

  clicked: ->
    if actionField = @collection.actionField
      actionField.reset()
    else if user = @collection.user
      if user.get("me") && @collection.reservation
        game.purchaseCard(@)
    else if @collection.type != "pack"
      game.purchaseCard(@)

  contextmenued: ->
    return if @collection.actionField || @collection.user
    game.reserveCard(@)

  updateAttributes: (attrs)->
    @set(attrs)
