class BSplendor.Collections.ChatList extends Backbone.Collection
  model: BSplendor.Models.Chat

  initialize: (models, options)->
    if options
      _.each options, (value, key) =>
        @[key] = value

