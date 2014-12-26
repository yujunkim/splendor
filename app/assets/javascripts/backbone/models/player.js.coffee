class BSplendor.Models.Player extends Backbone.Model

  defaults:
    className: "Player"

  initialize: () ->
    @refreshData()
    $("head .player-style-#{@get("id")}").remove()
    @addStyle("background-color")
    @addStyle("color")

  refreshData: () =>
    game = @get("game")

    game.dic.players[@get("id")] = @

    options = { player: @ }
    @reservedCards = new BSplendor.Collections.CardList [], player: @, reservation: true
    @nobles = new BSplendor.Collections.NobleList([], options)

    @purchasedCards = {}
    @get("game").jewelTypes.forEach (jewelType) =>
      cardListOptions = $.extend(options, jewelType: jewelType)
      @purchasedCards[jewelType] =
        new BSplendor.Collections.CardList([], cardListOptions)

    @jewelChips = {}
    @get("game").jewelTypes.forEach (jewelType) =>
      jewelChipListOptions = $.extend(options, type: jewelType)
      @jewelChips[jewelType] =
        new BSplendor.Collections.JewelChipList([], jewelChipListOptions)

    _.each @get("purchasedCards"), (cards, jewelType) =>
      cards.forEach (card) =>
        card = new BSplendor.Models.Card(card)
        game.dic.cards[card.get("id")] = card
        @purchasedCards[jewelType].add(card)

    @get("reservedCards").forEach (card) =>
      card = new BSplendor.Models.Card(card)
      game.dic.cards[card.get("id")] = card
      @reservedCards[jewelType].add(card)

    @get("nobles").forEach (noble) =>
      noble = new BSplendor.Models.Noble(noble)
      game.dic.nobles[noble.get("id")] = noble
      @nobles.add(noble)

    _.each @get("jewelChips"), (jewelChips, jewelType) =>
      jewelChips.forEach (jewelChip) =>
        jewelChip = new BSplendor.Models.JewelChip(jewelChip)
        game.dic.jewelChips[jewelChip.get("id")] = jewelChip
        @jewelChips[jewelType].add(jewelChip)


  name: =>
    if @get("user")
      @get("user").get("name")
    else if @get("isRobot")
      "Robot"

  purchase: (card) =>
    @purchasedCards[card.get('jewelType')].add(card)

  reserve: (card) =>
    @reservedCards.add(card)

  receive: (jewelChip) =>
    @jewelChips[jewelChip.get("jewelType")].add(jewelChip)

  hire: (noble) =>
    @nobles.add(noble)

  totalJewelChipCount: ()=>
    count = 0
    _.each @jewelChip, (collection, jewelType) ->
      count += collection.length
    count

  totalCardCount: ()=>
    count = 0
    _.each @purchasedCards, (collection, jewelType) ->
      count += collection.length
    count

  totalPoint: ()=>
    point = 0
    _.each @purchasedCards, (collection, jewelType) ->
      collection.models.forEach (card) ->
        point += card.get("point")
    @nobles.forEach (noble) ->
      point += noble.get("point")
    point

  ability: (jewelType) =>
    @jewelChips[jewelType].length + @purchasedCards[jewelType].length

  actualCost: (jewelType, count) =>
    count -= @purchasedCards[jewelType].length
    count = 0 if count < 0
    count

  purchasable: (card) =>
    able = true
    goldCount = @jewelChips["gold"].length
    _.each card.get("costs"), (cost, jewelType) =>
      return unless able
      abilityCache = @ability(jewelType)
      if cost > abilityCache + goldCount
        able = false
        return
      else
        lackCount = cost - abilityCache
        goldCount -= lackCount if lackCount > 0
    able

  pickUpJewelChip: (jewelType, count) =>
    jewelChips = @jewelChips[jewelType].first(count)
    goldCount = count - jewelChips.length
    if goldCount > 0
      jewelChips = _.union jewelChips,
                           @jewelChips["gold"].first(goldCount)
    jewelChips

  setCurrentTurn: () =>
    @set(currentTurn: true)

  unsetCurrentTurn: ()=>
    @set(currentTurn: undefined)

  addStyle: (style) ->
    $("head").append("<style class='player-style-#{@get("id")}'> .player.hovered .player-#{style}-#{@get("id")} {#{style}: #{@get("color")} !important }</style>");
