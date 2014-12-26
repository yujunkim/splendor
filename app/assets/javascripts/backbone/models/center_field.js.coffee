class BSplendor.Models.CenterField extends Backbone.Model

  initialize: ->
    @refreshData()

  refreshData: =>
    @nobles = new BSplendor.Collections.NobleList([], { centerField: @ })

    @cards = {
      pack: {},
      exhibition: {}
    }
    @jewelChips = {}
    game = @get("game")

    _(3).times (i) =>
      cardGrade = i+1
      @cards.pack[cardGrade] = new BSplendor.Collections.CardList [],
        centerField: @, type: "pack", cardGrade: cardGrade
      @cards.exhibition[cardGrade] = new BSplendor.Collections.CardList [],
        centerField: @, type: "exhibition", cardGrade: cardGrade

    game.jewelTypes.forEach (jewelType) =>
      jewelChipListOptions = { centerField: @, type: jewelType }
      @jewelChips[jewelType] = new BSplendor.Collections.JewelChipList([], jewelChipListOptions)

    _.each @get("cards"), (locationValue, locationKey) =>
      _.each locationValue, (cards, gradeKey) =>
        cards.forEach (card) =>
          card = new BSplendor.Models.Card(card)
          game.dic.cards[card.get("id")] = card
          @cards[locationKey][gradeKey].add(card)

    @get("nobles").forEach (noble) =>
      noble = new BSplendor.Models.Noble(noble)
      game.dic.nobles[noble.get("id")] = noble
      @nobles.add(noble)

    _.each @get("jewelChips"), (jewelChips, jewelType) =>
      jewelChips.forEach (jewelChip) =>
        jewelChip = new BSplendor.Models.JewelChip(jewelChip)
        game.dic.jewelChips[jewelChip.get("id")] = jewelChip
        @jewelChips[jewelType].add(jewelChip)

  exhibit: (card) ->
    card.collection.remove(card)
    card.set(revealed: true)
    @cards.exhibition[card.get('cardGrade')].add(card)

  pickOnePackCard: (level)->
    sample = @cards.pack[level].shuffle()[0]
    @cards.pack[level].remove(sample)
    @cards.exhibition[level].add(sample)

  returnJewelChip: (jewelChip) =>
    @jewelChips[jewelChip.get("jewelType")].add jewelChip

