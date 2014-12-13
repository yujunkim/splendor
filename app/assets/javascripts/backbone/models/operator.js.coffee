class BSplendor.Models.Operator extends Backbone.Model
  events:
    purchase: "purchase"

  initialize: (options)->
    @chatList = new BSplendor.Collections.ChatList([], { operator: @ })

  newMessage: (message) ->
    @chatList.add(message)

