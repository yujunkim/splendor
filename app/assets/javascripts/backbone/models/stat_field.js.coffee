class BSplendor.Models.StatField extends Backbone.Model

  initialize: ->

  winner: =>
    game.dic.players[game.get("winnerId")]
