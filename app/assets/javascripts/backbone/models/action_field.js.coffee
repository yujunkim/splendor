class BSplendor.Models.ActionField extends Backbone.Model

  initialize: ->
    @refreshData()
    [@cardList, @receiveJewelChipList, @returnJewelChipList].forEach (collection) =>
      collection.on 'all', () => @collectionChanged()

  collectionChanged: () =>
    @set(enable: @actionEnable())
    @trigger('refresh')

  actionEnable: ()=>
    enable = true
    switch @get("type")
      when "purchaseCard"
        card = @cardList.models[0]
        costs = []
        _.each card.get("costs"), (cost, jewelType) ->
          _(game.me.actualCost(jewelType, cost)).times () ->
            costs.push(jewelType)
        goldCount = 0
        @returnJewelChipList.models.forEach (jewelChip) ->
          return unless enable
          if jewelChip.get("jewelType") == "gold"
            goldCount++
          else
            idx = $.inArray(jewelChip.get("jewelType"), costs)
            if idx >= 0
              costs.splice idx, 1
            else
              enable = false
        enable &&= goldCount >= costs.length
      when "reserveCard"
        undefined
      when "receiveJewelChip"
        enable &&= (game.me.totalJewelChipCount() + @receiveJewelChipList.length) <= 10
      else
        enable = false
    enable

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
        game.users[card.get("userId")].reservedCards.add(card)
      else
        game.centerField.cards.exhibition[card.get("cardGrade")].add(card)
    _(@receiveJewelChipList.models.length).times () =>
      tmpJewelChip = @receiveJewelChipList.models[0]
      tmpJewelChip.collection.remove(tmpJewelChip)
      game.centerField.jewelChips[tmpJewelChip.get("jewelType")].add(tmpJewelChip)
    _(@returnJewelChipList.models.length).times () =>
      tmpJewelChip = @returnJewelChipList.models[0]
      tmpJewelChip.collection.remove(tmpJewelChip)
      game.me.jewelChips[tmpJewelChip.get("jewelType")].add(tmpJewelChip)
    @collectionChanged()

  pushCardList: (card, type) =>
    card.collection.remove(card)
    @cardList.add(card)

  pushReceive: (jewelChip) =>
    jewelChip.collection.remove(jewelChip)
    @receiveJewelChipList.add(jewelChip)

  popReceive: (jewelChip) ->
    jewelChip.collection.remove(jewelChip)
    game.centerField.jewelChips[jewelChip.get("jewelType")].add(jewelChip)
    if @receiveJewelChipList.models.length == 0
      @reset()

  pushReturn: (jewelChip) =>
    jewelChip.collection.remove(jewelChip)
    @returnJewelChipList.add(jewelChip)

  popReturn: (jewelChip) ->
    jewelChip.collection.remove(jewelChip)
    game.me.jewelChips[jewelChip.get("jewelType")].add(jewelChip)
    @collectionChanged()

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

  getJewelChipMap: (collection) =>
    map = {}
    collection.models.forEach (model) ->
      map[model.get("jewelType")] ||= 0
      map[model.get("jewelType")] += 1
    map

  serialize: =>
    {
      method: @get("type")
      d: {
        cardId: @getIds(@cardList)[0]
        receiveJewelChipMap: @getJewelChipMap(@receiveJewelChipList)
        returnJewelChipMap: @getJewelChipMap(@returnJewelChipList)
      }
    }

  action: =>
    console.log @serialize()
    game.clearAlertTimeout()
    splendorController.action(@serialize())
    @reset()

