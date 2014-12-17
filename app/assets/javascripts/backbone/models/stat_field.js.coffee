class BSplendor.Models.StatField extends Backbone.Model

  initialize: ->

  winner: =>
    game.users[game.get("winnerId")]
