class BSplendor.Models.Operator extends Backbone.Model
  events:
    purchase: "purchase"

  initialize: (options)->
    @chatList = new BSplendor.Collections.ChatList([], { operator: @ })

  newMessage: (message) ->
    user = splendorController.getUser(message.userId)
    message["user"] = user
    @chatList.add(message)

