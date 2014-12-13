class BSplendor.Collections.JewelChipList extends Backbone.Collection
  model: BSplendor.Models.JewelChip

  initialize: (models, options)->
    if options
      _.each options, (value, key) =>
        @[key] = value
