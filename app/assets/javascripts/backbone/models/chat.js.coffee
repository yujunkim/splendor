class BSplendor.Models.Chat extends Backbone.Model
  events:
    purchase: "purchase"

  initialize: (options)->
    @refreshData(options.game)

  refreshData: (game)=>

  me: ()=>
    operator.get("id") == @get("userId")
