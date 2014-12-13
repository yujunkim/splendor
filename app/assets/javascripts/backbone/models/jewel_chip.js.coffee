class BSplendor.Models.JewelChip extends Backbone.Model

  defaults:
    type: 'diamond'

  initialize: ->

  pushReceive: =>

  pushReturn: =>
    game.returnJewel @

  popReceive: =>
    game.popActionField("receiveJewel", jewelChip:  @)

  popReturn: =>
    game.popActionField("returnJewel", jewelChip:  @)

  clicked: ->
    if @collection.centerField
      game.receiveJewel @
    else if @collection.actionField
      if @collection.type == "receive"
        game.actionField.popReceive(@)
      else if @collection.type == "return"
        game.actionField.popReturn(@)
    else if @collection.user && @collection.user.get("me")
      game.returnJewel @
