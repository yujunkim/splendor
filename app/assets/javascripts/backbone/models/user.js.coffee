class BSplendor.Models.User extends Backbone.Model

  initialize: ->

  setupGame: =>
    options = { user: @ }
    @reservationCardList =
      new BSplendor.Collections.CardList [], user: @, reservation: true
    @nobleList = new BSplendor.Collections.NobleList([], options)
    @purchased = {}
    @get("game").jewelTypes.forEach (jewelType) =>
      cardListOptions = $.extend(options, jewelType: jewelType)
      @purchased[jewelType] =
        new BSplendor.Collections.CardList([], cardListOptions)
    @jewelChip = {}
    @get("game").jewelTypes.forEach (jewelType) =>
      jewelChipListOptions = $.extend(options, type: jewelType)
      @jewelChip[jewelType] =
        new BSplendor.Collections.JewelChipList([], jewelChipListOptions)

  purchase: (card) =>
    @purchased[card.get('jewelType')].add(card)

  reserve: (card) =>
    @reservationCardList.add(card)

  receive: (jewelChip) =>
    @jewelChip[jewelChip.get("type")].add(jewelChip)

  hire: (noble) =>
    @nobleList.add(noble)

  ability: (jewelType) =>
    @jewelChip[jewelType].length + @purchased[jewelType].length

  actualCost: (jewelType, count) =>
    count -= @purchased[jewelType].length
    count = 0 if count < 0
    count

  purchasable: (card) =>
    able = true
    goldCount = @jewelChip["gold"].length
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
    jewelChips = @jewelChip[jewelType].first(count)
    goldCount = count - jewelChips.length
    if goldCount > 0
      jewelChips = _.union jewelChips,
                           @jewelChip["gold"].first(goldCount)
    jewelChips

  setCurrentTurn: () =>
    @set(currentTurn: true)

  unsetCurrentTurn: ()=>
    @set(currentTurn: undefined)

