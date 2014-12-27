class BSplendor.Models.Game extends Backbone.Model

  jewelTypes: ["diamond", "sapphire", "emerald", "ruby", "onyx", "gold"]

  initialize: (game)->
    @dic = {
      players: {}
      cards: {},
      jewelChips: {},
      nobles: {}
    }
    @players = []
    @on "gameChildHovered", @childElementHovered
    @refreshData(game)

  refreshData: (game) =>
    @id = game.id
    @turnCount = game.turnCount
    game.players.forEach (playerHash) =>
      user = null
      if playerHash.user
        unless user = splendorController.getUser(playerHash.user.id)
          user = new BSplendor.Models.User(playerHash.user)
      player = new BSplendor.Models.Player($.extend(playerHash, user: user, game: @))
      @me = player if player.get("isMe")
      @players.push(player)
      @chief = player if player.get("isChief")
    @centerField = new BSplendor.Models.CenterField($.extend(game.centerField, game: @))
    @actionField = new BSplendor.Models.ActionField(game: @)
    @zoomField = new BSplendor.Models.ZoomField(game: @)
    @statField = new BSplendor.Models.StatField(game: @) if game.winnerId

    @setCurrentTurnPlayer(@players[0].get("id"))
    @setCardPurchasable()
    @centerField.trigger('reset-end')

  playerTurn: (player) ->
    @currentTurnPlayerId == player.get("id")

  purchaseCard: (card) ->
    purchaseCardValidation = () =>
      able = true
      able &&= @actionField.cardList.length == 0
      able &&= @me.purchasable(card)
      able

    if @playerTurn(@me) && purchaseCardValidation()
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
      able &&= @me.reservedCards.length < 3
      able

    if @playerTurn(@me) && reserveCardValidation()
      @actionField.changeType("reserveCard")
      goldJewelChip = @centerField.jewelChips["gold"].first()
      @actionField.pushReceive(goldJewelChip) if goldJewelChip
      @actionField.pushCardList(card)

  receiveJewelChip: (jewelChip) ->
    receiveJewelChipValidation = () =>
      able = true
      receiveJewelChipList = @actionField.receiveJewelChipList
      returnJewelChipList = @actionField.returnJewelChipList
      wantJewelType = jewelChip.get("jewelType")
      able &&= wantJewelType != "gold"
      able &&= receiveJewelChipList.length < 3
      able &&= (@me.totalJewelChipCount() + receiveJewelChipList.length) < 10
      if able && receiveJewelChipList.length == 1 && wantJewelType == receiveJewelChipList.models[0].get("jewelType")
        able &&= @centerField.jewelChips[wantJewelType].length > 2
      if able && receiveJewelChipList.length == 2
        jewelChipTypes = _.map receiveJewelChipList.models, (j) ->
          j.get("jewelType")
        jewelChipTypes.push(wantJewelType)
        able &&= _.uniq(jewelChipTypes).length == 3
      able

    if @playerTurn(@me) && receiveJewelChipValidation()
      @actionField.changeType("receiveJewelChip")
      @actionField.pushReceive(jewelChip)

  returnJewelChip: (jewelChip) ->
    returnJewelChipValidation = () ->
      true

    if @playerTurn(@me) && returnJewelChipValidation()
      @actionField.pushReturn(jewelChip)

  gameOver: (winnerId)->
    player = @dic.players[winnerId]
    player.set(winner: true)
    game.set(winnerId: winnerId)
    @resetCardPurchasable()
    @clearAlertTimeout()
    @clearRobotTimeout()
    @statField = new BSplendor.Models.StatField(game: @)
    @trigger("game.over")

  actionPerformed: (type, data) =>
    @resetCardPurchasable()
    @clearAlertTimeout()
    @clearRobotTimeout()
    player = @dic.players[data.playerId]
    @turnCount = game.turnCount
    $("#turn-count").html(data.turnCount)

    if data.purchasedCard && purchasedCard = @dic.cards[data.purchasedCard.id]
      purchasedCard.updateAttributes(data.purchasedCard)
      purchasedCard.collection.remove(purchasedCard)
      player.purchase(purchasedCard)

    if data.reservedCard && reservedCard = @dic.cards[data.reservedCard.id]
      reservedCard.updateAttributes(data.reservedCard)
      reservedCard.collection.remove(reservedCard)
      player.reserve(reservedCard)

    if data.revealedCard && revealedCard = @dic.cards[data.revealedCard.id]
      revealedCard.updateAttributes(data.revealedCard)
      @centerField.exhibit(revealedCard)

    data.returnedJewelChips.forEach (jewelChip) =>
      returnedJewelChip = @dic.jewelChips[jewelChip.id]
      returnedJewelChip.collection.remove(returnedJewelChip)
      @centerField.returnJewelChip(returnedJewelChip)

    data.receivedJewelChips.forEach (jewelChip) =>
      receivedJewelChip = @dic.jewelChips[jewelChip.id]
      receivedJewelChip.collection.remove(receivedJewelChip)
      player.receive(receivedJewelChip)

    if data.hiredNoble && hiredNoble = @dic.nobles[data.hiredNoble.id]
      hiredNoble.collection.remove(hiredNoble)
      hiredNoble.updateAttributes(data.hiredNoble)
      player.hire(hiredNoble)

    @setCurrentTurnPlayer(data.currentTurnPlayerId)
    @setCardPurchasable()

  setCurrentTurnPlayer: (currentTurnPlayerId) =>
    @currentTurnPlayerId = currentTurnPlayerId
    @players.forEach (player) =>
      if @playerTurn(player)
        player.set(currentTurn: true)
        if player.get("isRobot") && @chief == @me
          @setRobotTimeout()
      else
        player.set(currentTurn: undefined)
    if @playerTurn(@me)
      @alertTimeout = setTimeout( ->
        $("body").addClass("alert-opacity")
      , 5000)

  clearAlertTimeout: ()=>
    if @alertTimeout
      clearTimeout(@alertTimeout)
      @alertTimeout = undefined
      $("body").removeClass("alert-opacity")

  clearRobotTimeout: ()=>
    if @robotTimeout
      clearTimeout(@robotTimeout)
      @robotTimeout = undefined

  setRobotTimeout: =>
    @robotTimeout = setTimeout(=>
      if game.get("id")
        $.ajax
          url: "/games/#{game.get("id")}/run",
          success: ->
      #@setRobotTimeout()
    , 5000)

  setCardPurchasable: () =>
    @players.forEach (player) =>
      _.each @centerField.cards.exhibition, (collection, level) ->
        collection.models.forEach (card) ->
          if player.purchasable(card)
            card.setPurchasablePlayer(player)
      player.reservedCards.models.forEach (card)->
        if player.purchasable(card)
          card.setPurchasablePlayer(player)

  resetCardPurchasable: ()=>
    _.each @centerField.cards.exhibition, (collection, level) ->
      collection.models.forEach (card) ->
        card.resetPurchasablePlayer()
    @players.forEach (player) ->
      player.reservedCards.models.forEach (card)->
        card.resetPurchasablePlayer()

  highlightPurchasableCards: (player) ->
    $(".card.purchasable-player-#{player.get("id")}").css("border-color": "red")

  resetHighlightPurchasableCards: (player) ->
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
        when "Player"
          @zoomField.visualize("player", view.model)

    if view.model.get("className")
      view.$el.find(".background").addClass("player-background-color player-background-color-#{view.model.get("id")}")
      game.resetHighlightPurchasableCards()
      game.highlightPurchasableCards(view.model)
    else
      view.$el.find(".background").removeClass (idx, cls) ->
        cls.match("player-background-color")
      game.resetHighlightPurchasableCards()
