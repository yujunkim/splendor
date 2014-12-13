BSplendor.Views.CenterField = {}

class BSplendor.Views.CenterField.Base extends Backbone.View

  className: 'center-field'

  template: JST["backbone/templates/center_field/base"]

  initialize: () ->
    @model.on 'reset-end', @render, @

  render: ->
    @$el.html(@template @)
    _.each @model.pack, (collection, level) =>
      packCardListView = new BSplendor.Views.CardList.Pack
        collection: collection,
        level: level
      packCardListView.render()
      @$el.append packCardListView.el

    _.each @model.exhibition, (collection, level) =>
      exhibitionCardListView = new BSplendor.Views.CardList.Exhibition
        collection: collection,
        level: level
      exhibitionCardListView.render()
      @$el.append exhibitionCardListView.el

    nobleListView = new BSplendor.Views.NobleList.Base
      collection: @model.nobleList
    nobleListView.render()
    @$el.append nobleListView.el

    _.each @model.jewelChip, (collection, type) =>
      jewelChipListView = new BSplendor.Views.JewelChipList.Base
        collection: collection,
        type: type
      jewelChipListView.render()
      @$el.append jewelChipListView.el
