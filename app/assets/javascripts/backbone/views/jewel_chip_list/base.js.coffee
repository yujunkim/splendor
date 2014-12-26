BSplendor.Views.JewelChipList = {}

class BSplendor.Views.JewelChipList.Base extends Backbone.View

  className: 'jewel-chip-list'

  template: JST["backbone/templates/jewel_chip_list/base"]

  initialize: ->
    @$el.addClass(@options.jewelType)
    @collection.on('add', @addOne, @)
    @collection.on('remove', @render, @)

  render: ->
    @$el.children().remove()
    @collection.forEach(@addOne, @)
    this

  addOne: (jewelChip)->
    jewelChipView = new BSplendor.Views.JewelChip.Base(model: jewelChip, collection: @collection)
    jewelChipView.render()
    @$el.append jewelChipView.el

