BSplendor.Views.ActionField = {}

class BSplendor.Views.ActionField.Base extends Backbone.View

  className: 'action-field'

  events:
    'click #action': 'action'

  template: JST["backbone/templates/action_field/base"]

  initialize: () ->
    @model.on 'refresh', @render, @

  render: ->
    @$el.html(@template @)
    cardListView = new BSplendor.Views.CardList.Reservation
      collection: @model.cardList
    cardListView.render()
    @$el.append cardListView.el

    [{
      collection: @model.receiveJewelChipList,
      type: "receive"
    },{
      collection: @model.returnJewelChipList,
      type: "return"
    }].forEach (jewelChipList) =>
      jewelChipListView = new BSplendor.Views.JewelChipList.Base(jewelChipList)
      jewelChipListView.render()
      @$el.append jewelChipListView.el

  action: =>
    @model.action()
