BSplendor.Views.CenterField = {}

class BSplendor.Views.CenterField.Base extends Backbone.View

  className: 'center-field'

  template: JST["backbone/templates/center_field/base"]

  initialize: () ->
    @model.on 'reset-end', @render, @

  render: ->
    @$el.html(@template @)
    _.each @model.cards, (locationValue, locationKey) =>
      _.each locationValue, (collection, gradeKey) =>
        cardListViewClass = if locationKey == "pack"
          BSplendor.Views.CardList.Pack
        else if locationKey == "exhibition"
          BSplendor.Views.CardList.Exhibition
        cardListView = new cardListViewClass
          collection: collection,
          level: gradeKey
        cardListView.render()
        @$el.append cardListView.el

    nobleListView = new BSplendor.Views.NobleList.Base
      collection: @model.nobles
    nobleListView.render()
    @$el.append nobleListView.el

    _.each @model.jewelChips, (collection, jewelType) =>
      jewelChipListView = new BSplendor.Views.JewelChipList.Base
        collection: collection,
        jewelType: jewelType
      jewelChipListView.render()
      @$el.append jewelChipListView.el
