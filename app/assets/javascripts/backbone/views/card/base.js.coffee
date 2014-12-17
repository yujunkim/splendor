BSplendor.Views.Card = {}

class BSplendor.Views.Card.Base extends Backbone.View

  events:
    'click .purchase': 'purchase'
    'click .reserve': 'reserve'
    'click': 'cancel'
    "mousemove": "mousemoved"

  className: 'card-view'

  template: JST["backbone/templates/card/base"]

  initialize: () ->
    @model.on("change", @render, @)
    @model.on("purchasable-user-change", @changePurchasableUserClass, @)

  render: ->
    @$el.addClass("card-view-#{@collection.indexOf(@model)}") if @collection?
    @$el.html @template @
    @$el.find(".card").addClass("revealed") if @model.get("revealed")
    @changePurchasableUserClass()

  changePurchasableUserClass: =>
    @$el.find(".card").removeClass (idx, cls) ->
      cls.match("purchasable-user")
    @model.purchasableUser.forEach (user) =>
      @$el.find(".card").addClass("purchasable-user-#{user.get("id")}")
      if user.get("me")
        @$el.find(".card").addClass("purchasable-user-me")

  cancel: (e) =>
    e.stopPropagation()
    @model.cancel()

  purchase: (e) =>
    e.stopPropagation()
    @model.purchase()

  reserve: (e) =>
    e.stopPropagation()
    @model.reserve()

  mousemoved: (e) ->
    e.stopPropagation() unless @model.collection? && @model.collection.user?
    game.trigger("gameChildHovered", e, @)


