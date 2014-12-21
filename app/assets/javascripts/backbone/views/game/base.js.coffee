BSplendor.Views.Game = {}

class BSplendor.Views.Game.Base extends Backbone.View

  events:
    "mousemove": "mousemoved"
    #"click #run-robot": "robotRun"
    "click #layout-buttons .layout-full-view": "fullView"
    "click #layout-buttons .layout-my-view": "myView"

  className: 'game-view'

  template: JST["backbone/templates/game/base"]

  initialize: () ->
    @model.on 'reset-end', @render, @
    @model.on 'game.over', @addStatField, @

  mousemoved: (e)->
    game.resetHighlightPurchasableCards()
    @model.zoomField.reset()
    @model.hoverAlone(@$el)

  render: ->
    @$el.html(@template @)
    game = @$el.find(".game")

    [
      [BSplendor.Views.CenterField.Base, @model.centerField],
      [BSplendor.Views.ActionField.Base, @model.actionField],
      [BSplendor.Views.ZoomField.Base, @model.zoomField]
    ].forEach (arr) =>
      cls = arr[0]
      model = arr[1]
      view = new cls
        model: model
      view.render()
      game.append view.el

    orderUserIds = @model.get("orderUserIds")
    game.addClass("game-#{orderUserIds.length}users")

    userPositions = switch orderUserIds.length
      when 2 then ["bottom", "top"]
      when 3 then ["bottom", "left", "right"]
      when 4 then ["bottom", "left", "top", "right"]

    myId = @model.me.get("id")
    myOrder = @model.get("orderUserIds").indexOf(myId)
    _.each @model.users, (user, type) =>
      order = orderUserIds.indexOf(user.get("id"))
      relativeOrder = order - myOrder
      relativeOrder += orderUserIds.length if relativeOrder < 0
      view = BSplendor.Views.User.Base
      userView = new view
        model: user
        position: userPositions[relativeOrder]
      userView.render()
      game.append userView.el
    @addStatField()

  addStatField: ->
    if @model.statField
      view = new BSplendor.Views.StatField.Base
        model: @model.statField
      view.render()
      @$el.find(".game").append view.el

  #robotRun: ->
  #  if @model.get("id")
  #    $.ajax
  #      url: "/games/#{@model.get("id")}/run",
  #      success: ->

  fullView: ->
    @$el.find(".game").addClass("full-view").removeClass("my-view")

  myView: ->
    @$el.find(".game").addClass("my-view").removeClass("full-view")


