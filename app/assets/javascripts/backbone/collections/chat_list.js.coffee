class BSplendor.Collections.ChatList extends Backbone.Collection
  model: BSplendor.Models.Chat

  initialize: (models, options)->
    if options
      _.each options, (value, key) =>
        @[key] = value
    $(window).on "user.updated", @updateChatUsers

  updateChatUsers: ()=>
    @models.forEach (model) ->
      uid = model.get("userId")
      updatedUser = splendorController.getUser(uid)
      if updatedUser
        model.set(user: updatedUser)
        model.trigger('user.updated')

