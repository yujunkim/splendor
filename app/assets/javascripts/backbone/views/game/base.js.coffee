BSplendor.Views.Game = {}

class BSplendor.Views.Game.Base extends Backbone.View

  className: 'game-view'

  template: JST["backbone/templates/game/base"]

  initialize: () ->
    @model.on 'reset-end', @render, @

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

    i = 0
    _.each @model.users, (user, type) =>
      view = BSplendor.Views.User.Base
      userView = new view
        model: user
        position: ["top", "right", "left"][i]
      userView.render()
      game.append userView.el
      i += 1 unless user.get('me')

