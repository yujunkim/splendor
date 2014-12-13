class BSplendor.Collections.NobleList extends Backbone.Collection
  model: BSplendor.Models.Noble

  initialize: (models, options)->
    if options
      _.each options, (value, key) =>
        @[key] = value
