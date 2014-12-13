class BSplendor.Models.ActionField extends Backbone.Model

  initialize: ->
    @refreshData()
    [@cardList, @receiveJewelChipList, @returnJewelChipList].forEach (collection) =>
      collection.on 'all', () => @trigger('refresh')

  refreshData: =>
    options = { actionField: @ }
    @cardList = new BSplendor.Collections.CardList([], options)
    @receiveJewelChipList =
      new BSplendor.Collections.JewelChipList([], $.extend(options, type: "receive"))
    @returnJewelChipList =
      new BSplendor.Collections.JewelChipList([], $.extend(options, type: "return"))

  reset: () =>
    @changeType(undefined)
    @cardList.models.forEach (card) ->
      card.collection.remove(card)
      if card.get("userId") && card.get("reserved")
        game.users[card.get("userId")].reservationCardList.add(card)
      else
        game.centerField.exhibition[card.get("cardGrade")].add(card)
    _(@receiveJewelChipList.models.length).times () =>
      tmpJewelChip = @receiveJewelChipList.models[0]
      tmpJewelChip.collection.remove(tmpJewelChip)
      game.centerField.jewelChip[tmpJewelChip.get("type")].add(tmpJewelChip)
    _(@returnJewelChipList.models.length).times () =>
      tmpJewelChip = @returnJewelChipList.models[0]
      tmpJewelChip.collection.remove(tmpJewelChip)
      game.me.jewelChip[tmpJewelChip.get("type")].add(tmpJewelChip)

  pushCardList: (card, type) =>
    card.collection.remove(card)
    @cardList.add(card)

  pushReceive: (jewelChip) =>
    jewelChip.collection.remove(jewelChip)
    @receiveJewelChipList.add(jewelChip)

  popReceive: (jewelChip) ->
    jewelChip.collection.remove(jewelChip)
    game.centerField.jewelChip[jewelChip.get("type")].add(jewelChip)
    if @receiveJewelChipList.models.length == 0
      @reset()

  pushReturn: (jewelChip) =>
    jewelChip.collection.remove(jewelChip)
    @returnJewelChipList.add(jewelChip)

  popReturn: (jewelChip) ->
    jewelChip.collection.remove(jewelChip)
    game.me.jewelChip[jewelChip.get("type")].add(jewelChip)

  changeType: (type) =>
    return if @get("type") == type
    if @get("type") == undefined
      @set(type:  type)
    else if type == undefined
      @set(type:  type)
    else if type != undefined && @get("type") != type
      @reset()
      @set(type:  type)
    @trigger("refresh")

  getIds: (collection) =>
    _.map collection.models, (model) -> model.get("id")

  serialize: =>
    {
      card_id: @getIds(@cardList)[0]
      receive_jewel_chip_ids: @getIds(@receiveJewelChipList)
      return_jewel_chip_ids: @getIds(@returnJewelChipList)
    }

  action: =>
    switch @get("type")
      when "purchaseCard"
        splendorController.action("purchase_card", @serialize())
      when "reserveCard"
        splendorController.action("reserve_card", @serialize())
      when "receiveJewel"
        splendorController.action("receive_jewel", @serialize())
    @reset()

