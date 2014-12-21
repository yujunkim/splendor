class BSplendor.Models.JewelChip extends Backbone.Model

  defaults:
    className: "JewelChip"

  initialize: ->

  pushReceive: =>

  pushReturn: =>
    game.returnJewelChip @

  popReceive: =>
    game.popActionField("receiveJewelChip", jewelChip:  @)

  popReturn: =>
    game.popActionField("returnJewelChip", jewelChip:  @)

  clicked: ->
    if @collection.centerField
      game.receiveJewelChip @
    else if @collection.actionField
      if @collection.type == "receive"
        game.actionField.popReceive(@)
      else if @collection.type == "return"
        game.actionField.popReturn(@)
    else if @collection.user && @collection.user.get("me")
      game.returnJewelChip @
