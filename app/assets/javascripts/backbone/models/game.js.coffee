class BSplendor.Models.Game extends Backbone.Model

  jewelTypes: ["diamond", "sapphire", "emerald", "ruby", "onyx", "gold"]

  initialize: (game)->
    @dic = {
      card: {},
      jewelChip: {},
      noble: {}
    }
    @refreshData(game)
    @on "gameChildHovered", @childElementHovered

  refreshData: (game) =>
    @id = game.id
    @users = { }
    game.users.forEach (userHash) =>
      unless user = splendorController.getUser(userHash.id)
        user = new BSplendor.Models.User(userHash)
      user.set($.extend(userHash, game: @))
      user.setupGame()
      @me = user if user.get("me")
      @users[user.get("id")] = user
    @centerField = new BSplendor.Models.CenterField(game: @)
    @actionField = new BSplendor.Models.ActionField(game: @)
    @zoomField = new BSplendor.Models.ZoomField(game: @)
    @statField = new BSplendor.Models.StatField(game: @) if game.winnerId
    @reset(game)

  reset: (game)=>
    game.cards.forEach (card) =>
      card = new BSplendor.Models.Card(card)
      @dic.card[card.get("id")] = card
      user = @users[card.get("userId")]
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
      @dic.noble[noble.get("id")] = noble
      user = @users[noble.get("userId")]
      user = @centerField unless user
      user.nobleList.add(noble)
    game.jewelChips.forEach (jewelChip) =>
      jewelChip = new BSplendor.Models.JewelChip(jewelChip)
      @dic.jewelChip[jewelChip.get("id")] = jewelChip
      user = @users[jewelChip.get("userId")]
      user = @centerField unless user
      user.jewelChip[jewelChip.get("jewelType")].add(jewelChip)

    @setCurrentTurnUser(game.currentTurnUserId)
    @setCardPurchasable()
    @centerField.trigger('reset-end')

  userTurn: (user) ->
    @currentTurnUserId == user.get("id")

  purchaseCard: (card) ->
    purchaseCardValidation = () =>
      able = true
      able &&= @actionField.cardList.length == 0
      able &&= @me.purchasable(card)
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

  receiveJewelChip: (jewelChip) ->
    receiveJewelChipValidation = () =>
      able = true
      receiveJewelChipList = @actionField.receiveJewelChipList
      returnJewelChipList = @actionField.returnJewelChipList
      able &&= jewelChip.get("jewelType") != "gold"
      able &&= receiveJewelChipList.length < 3
      able &&= (@me.totalJewelChipCount() + receiveJewelChipList.length) < 10
      if able && receiveJewelChipList.length == 2
        jewelChipTypes = _.map receiveJewelChipList.models, (j) ->
          j.get("jewelType")
        jewelChipTypes.push(jewelChip.get("jewelType"))
        able &&= _.uniq(jewelChipTypes).length == 3
      able

    if @userTurn(@me) && receiveJewelChipValidation()
      @actionField.changeType("receiveJewelChip")
      @actionField.pushReceive(jewelChip)

  returnJewelChip: (jewelChip) ->
    returnJewelChipValidation = () ->
      true

    if @userTurn(@me) && returnJewelChipValidation()
      @actionField.pushReturn(jewelChip)

  gameOver: (winner)->
    user = @users[winner.id]
    user.set(winner: true)
    game.set(winnerId: winner.id)
    @statField = new BSplendor.Models.StatField(game: @)
    @trigger("game.over")

  actionPerformed: (type, data) =>
    @resetCardPurchasable()
    @clearAlertTimeout()
    user = @users[data.userId]

    if data.purchasedCard && purchasedCard = @dic.card[data.purchasedCard.id]
      purchasedCard.updateAttributes(data.purchasedCard)
      purchasedCard.collection.remove(purchasedCard)
      user.purchase(purchasedCard)

    if data.reservedCard && reservedCard = @dic.card[data.reservedCard.id]
      reservedCard.updateAttributes(data.reservedCard)
      reservedCard.collection.remove(reservedCard)
      user.reserve(reservedCard)

    if data.revealedCard && revealedCard = @dic.card[data.revealedCard.id]
      revealedCard.updateAttributes(data.revealedCard)
      @centerField.exhibit(revealedCard)

    data.returnedJewelChips.forEach (jewelChip) =>
      returnedJewelChip = @dic.jewelChip[jewelChip.id]
      returnedJewelChip.collection.remove(returnedJewelChip)
      @centerField.returnJewelChip(returnedJewelChip)

    data.receivedJewelChips.forEach (jewelChip) =>
      receivedJewelChip = @dic.jewelChip[jewelChip.id]
      receivedJewelChip.collection.remove(receivedJewelChip)
      user.receive(receivedJewelChip)

    if data.hiredNoble && hiredNoble = @dic.noble[data.hiredNoble.id]
      hiredNoble.collection.remove(hiredNoble)
      hiredNoble.updateAttributes(data.hiredNoble)
      user.hire(hiredNoble)

    @setCurrentTurnUser(data.currentTurnUserId)
    @setCardPurchasable()

  setCurrentTurnUser: (currentTurnUserId) =>
    @currentTurnUserId = currentTurnUserId
    _.each @users, (user, id) =>
      if @userTurn(user)
        user.set(currentTurn: true)
      else
        user.set(currentTurn: undefined)
    if @userTurn(@me)
      @alertTimeout = setTimeout( ->
        $("body").addClass("alert-opacity")
      , 5000)

  clearAlertTimeout: ()=>
    if @alertTimeout
      clearTimeout(@alertTimeout)
      @alertTimeout = undefined
      $("body").removeClass("alert-opacity")

  setCardPurchasable: () =>
    _.each @users, (user, userId) =>
      _.each @centerField.exhibition, (collection, level) ->
        collection.models.forEach (card) ->
          if user.purchasable(card)
            card.setPurchasableUser(user)
      user.reservationCardList.models.forEach (card)->
        if user.purchasable(card)
          card.setPurchasableUser(user)

  resetCardPurchasable: ()=>
    _.each @centerField.exhibition, (collection, level) ->
      collection.models.forEach (card) ->
        card.resetPurchasableUser()
    _.each @users, (user, userId) ->
      user.reservationCardList.models.forEach (card)->
        card.resetPurchasableUser()

  highlightPurchasableCards: (user) ->
    $(".card.purchasable-user-#{user.get("id")}").css("border-color": "red")

  resetHighlightPurchasableCards: (user) ->
    $(".card").css("border-color": "")

  hoverAlone: (el) ->
    $(".hovered").removeClass("hovered")
    el.addClass("hovered")

  hoverWith: (el) ->
    el.addClass("hovered")

  childElementHovered: (event, view) =>
    @clearAlertTimeout()
    alreadyProcessedEvent = @recentEvent? && @recentEvent.originalEvent == event.originalEvent
    if alreadyProcessedEvent
      @hoverWith(view.$el)
    else
      @hoverAlone(view.$el)
      @recentEvent = event
      switch view.model.get("className")
        when "Card"
          if view.collection && view.collection.type == "pack"
            @zoomField.visualize("packCardList", view.collection)
          else
            @zoomField.visualize("card", view.model)
        when "Noble"
          @zoomField.visualize("noble", view.model)
        when "JewelChip"
          @zoomField.visualize("jewelChipList", view.collection)
        when "User"
          @zoomField.visualize("user", view.model)

    if view.model.constructor.name == "User"
      view.$el.find(".background").addClass("user-background-color user-background-color-#{view.model.get("id")}")
      game.resetHighlightPurchasableCards()
      game.highlightPurchasableCards(view.model)
    else
      view.$el.find(".background").removeClass (idx, cls) ->
        cls.match("user-background-color")
      game.resetHighlightPurchasableCards()
