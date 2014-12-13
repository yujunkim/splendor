class BSplendor.Models.ZoomField extends Backbone.Model

  initialize: ->

  visualize: (type, instance) ->
    @set(type: type)
    @set(instance: instance)
    @trigger("refresh")

  reset: ()->
    @set(type: undefined)
    @set(visualizeModel: undefined)
    @trigger("refresh")
