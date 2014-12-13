class BSplendor.Models.Game extends Backbone.Model

  jewelTypes: ["diamond", "sapphire", "emerald", "ruby", "onyx", "gold"]

  events: [
    purchase: "purchase"
  ]

  initialize: (options)->
    @refreshData(options.game)

  refreshData: (game)=>
    @id = game.id
    @users = { }
    game.users.forEach (userHash) =>
      unless user = splendorController.getUser(userHash.id)
        user = splendorController.addUser(userHash)
      user.set($.extend(userHash, game: @))
      user.setupGame()
      @me = user if user.get("me")
      @users[user.get("id")] = user
    @centerField = new BSplendor.Models.CenterField(game: @)
    @actionField = new BSplendor.Models.ActionField(game: @)
    @zoomField = new BSplendor.Models.ZoomField(game: @)
    @reset(game)

  reset: (game)=>
    game.cards.forEach (card) =>
      card = new BSplendor.Models.Card(card)
      Dic.card[card.get("id")] = card
      user = Dic.user[card.get("userId")]
      if user
        if card.get("reserved")
          user.reservationCardList.add(card)
        else
          user.purchased[card.get("jewelType")].add(card)
      else
        if card.get("revealed")
          @centerField.exhibition[card.get("cardGrade")].add(card)
        else
          @centerField.pack[card.get("cardGrade")].add(card)
    game.nobles.forEach (noble) =>
      noble = new BSplendor.Models.Noble(noble)
      Dic.noble[noble.get("id")] = noble
      user = Dic.user[noble.get("userId")]
      user = @centerField unless user
      user.nobleList.add(noble)
    game.jewels.forEach (jewelChip) =>
      jewelChip = new BSplendor.Models.JewelChip(jewelChip)
      Dic.jewelChip[jewelChip.get("id")] = jewelChip
      user = Dic.user[jewelChip.get("userId")]
      user = @centerField unless user
      user.jewelChip[jewelChip.get("type")].add(jewelChip)

    @setCurrentTurnUser(game.currentTurnUserId)
    @centerField.trigger('reset-end')

  userTurn: (user) ->
    @currentTurnUserId == user.get("id")

  purchaseCard: (card) ->
    purchaseCardValidation = () =>
      able = true
      able &&= @actionField.cardList.length == 0
      goldCount = @me.ability("gold")
      _.each card.get('costs'), (cost, jewelChipType) =>
        ability = @me.ability(jewelChipType)
        return if !able || cost <= ability
        if cost <= (ability + goldCount)
          goldCount -= cost - ability
        else
          able = false
      able

    if @userTurn(@me) && purchaseCardValidation()
      @actionField.changeType("purchaseCard")
      @actionField.pushCardList(card)
      _.each card.get('costs'), (cost, jewelChipType) =>
        actualCost = @me.actualCost(jewelChipType, cost)
        jewelChips = @me.pickUpJewelChip(jewelChipType, actualCost)
        jewelChips.forEach (tmpJewelChip) =>
          @actionField.pushReturn(tmpJewelChip)

  reserveCard: (card) ->
    reserveCardValidation = () =>
      able = true
      able &&= @actionField.cardList.length == 0
      able &&= @me.reservationCardList.length < 3
      able

    if @userTurn(@me) && reserveCardValidation()
      @actionField.changeType("reserveCard")
      goldJewelChip = @centerField.jewelChip["gold"].first()
      @actionField.pushReceive(goldJewelChip) if goldJewelChip
      @actionField.pushCardList(card)

  receiveJewel: (jewelChip) ->
    receiveJewelValidation = () =>
      list = @actionField.receiveJewelChipList
      result = true
      result &&= jewelChip.get("type") != "gold"
      result &&= list.length < 3
      if result && list.length == 2
        jewelChipTypes = _.map list.models, (j) ->
          j.get("type")
        jewelChipTypes.push(jewelChip.get("type"))
        result &&= _.uniq(jewelChipTypes).length == 3
      result

    if @userTurn(@me) && receiveJewelValidation()
      @actionField.changeType("receiveJewel")
      @actionField.pushReceive(jewelChip)

  returnJewel: (jewelChip) ->
    returnJewelValidation = () ->
      true

    if @userTurn(@me) && returnJewelValidation()
      @actionField.pushReturn(jewelChip)

  actionPerformed: (type, data) =>
    user = Dic.user[data.userId]

    if data.purchasedCard && purchasedCard = Dic.card[data.purchasedCard.id]
      purchasedCard.updateAttributes(data.purchasedCard)
      purchasedCard.collection.remove(purchasedCard)
      user.purchase(purchasedCard)

    if data.reservedCard && reservedCard = Dic.card[data.reservedCard.id]
      reservedCard.updateAttributes(data.reservedCard)
      reservedCard.collection.remove(reservedCard)
      user.reserve(reservedCard)

    if data.revealedCard && revealedCard = Dic.card[data.revealedCard.id]
      revealedCard.updateAttributes(data.revealedCard)
      @centerField.exhibit(revealedCard)

    data.returnedJewelChips.forEach (jewelChip) =>
      returnedJewelChip = Dic.jewelChip[jewelChip.id]
      returnedJewelChip.collection.remove(returnedJewelChip)
      @centerField.returnJewelChip(returnedJewelChip)

    data.receivedJewelChips.forEach (jewelChip) =>
      receivedJewelChip = Dic.jewelChip[jewelChip.id]
      receivedJewelChip.collection.remove(receivedJewelChip)
      user.receive(receivedJewelChip)

    if data.hiredNoble && hiredNoble = Dic.noble[data.hiredNoble.id]
      hiredNoble.collection.remove(hiredNoble)
      hiredNoble.updateAttributes(data.hiredNoble)
      user.hire(hiredNoble)

    @setCurrentTurnUser(data.currentTurnUserId)

  setCurrentTurnUser: (currentTurnUserId) =>
    @currentTurnUserId = currentTurnUserId
    _.each @users, (user, id) =>
      if @userTurn(user)
        user.set(currentTurn: true)
      else
        user.set(currentTurn: undefined)

  highlightPurchasableCards: (user, color) =>
    _.each @centerField.exhibition, (collection, level) ->
      collection.models.forEach (card) ->
        if user.purchasable(card)
          card.set(coverColor: 'red')
    user.reservationCardList.models.forEach (card)->
      if user.purchasable(card)
        card.set(coverColor: 'red')

  resetHighlightPurchasableCards: (user) =>
    _.each @centerField.exhibition, (collection, level) ->
      collection.models.forEach (card) ->
        card.set(coverColor: undefined)
    user.reservationCardList.models.forEach (card)->
      card.set(coverColor: undefined)
