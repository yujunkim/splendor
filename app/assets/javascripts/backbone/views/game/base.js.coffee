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
    @model.on 'game.turn.me', @addMyTurnClass, @
    @model.on 'game.turn.others', @addOthersTurnClass, @

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

    game.addClass("game-#{@model.players.length}players")
    if @model.playerTurn(@model.me)
      game.addClass("my-turn")
    else
      game.addClass("others-turn")

    playerPositions = switch @model.players.length
      when 2 then ["bottom", "top"]
      when 3 then ["bottom", "left", "right"]
      when 4 then ["bottom", "left", "top", "right"]

    myOrder = @model.players.indexOf(@model.me)
    _.each @model.players, (player, type) =>
      order = @model.players.indexOf(player)
      relativeOrder = order - myOrder
      relativeOrder += @model.players.length if relativeOrder < 0
      view = BSplendor.Views.Player.Base
      playerView = new view
        model: player
        position: playerPositions[relativeOrder]
      playerView.render()
      game.append playerView.el
    @addStatField()

  addStatField: ->
    if @model.statField
      view = new BSplendor.Views.StatField.Base
        model: @model.statField
      view.render()
      @$el.find(".game").append view.el

  addMyTurnClass: (e) ->
    @$el.find(".game").removeClass("others-turn").addClass("my-turn")

  addOthersTurnClass: (e) ->
    @$el.find(".game").removeClass("my-turn").addClass("others-turn")

  fullView: ->
    @$el.find(".game").addClass("full-view").removeClass("my-view")

  myView: ->
    @$el.find(".game").addClass("my-view").removeClass("full-view")


