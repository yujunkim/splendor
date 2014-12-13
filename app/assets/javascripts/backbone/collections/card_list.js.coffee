class BSplendor.Collections.CardList extends Backbone.Collection
  model: BSplendor.Models.Card

  initialize: (models, options)->
    if options
      _.each options, (value, key) =>
        @[key] = value

