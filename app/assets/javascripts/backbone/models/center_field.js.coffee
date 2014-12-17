class BSplendor.Models.CenterField extends Backbone.Model

  initialize: ->
    @refreshData()

  refreshData: =>
    @nobleList = new BSplendor.Collections.NobleList([], { centerField: @ })

    @pack = {}
    @exhibition = {}
    @jewelChip = {}

    _(3).times (i) =>
      cardGrade = i+1
      @pack[cardGrade] = new BSplendor.Collections.CardList [],
        centerField: @, type: "pack", cardGrade: cardGrade
      @exhibition[cardGrade] = new BSplendor.Collections.CardList [],
        centerField: @, type: "exhibition", cardGrade: cardGrade

    @get("game").jewelTypes.forEach (jewelType) =>
      jewelChipListOptions = { centerField: @, type: jewelType }
      @jewelChip[jewelType] = new BSplendor.Collections.JewelChipList([], jewelChipListOptions)

  exhibit: (card) ->
    card.collection.remove(card)
    card.set(revealed: true)
    @exhibition[card.get('cardGrade')].add(card)

  pickOnePackCard: (level)->
    sample = @pack[level].shuffle()[0]
    @pack[level].remove(sample)
    @exhibition[level].add(sample)

  returnJewelChip: (jewelChip) =>
    @jewelChip[jewelChip.get("jewelType")].add jewelChip

